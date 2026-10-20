local neotest_client = nil

local function patch_rust_analyzer()
  local ok_ra, ra = pcall(require, "rustaceanvim.rust_analyzer")
  if not ok_ra or not ra or ra._crates_patched then
    return
  end
  ra._crates_patched = true

  local orig_get_client = ra.get_client_for_file
  ra.get_client_for_file = function(file_path, method)
    local client = orig_get_client(file_path, method)
    if client then
      return client
    end

    local ok_os, os_mod = pcall(require, "rustaceanvim.os")
    local norm_path = ok_os and os_mod.normalize_path_on_windows(file_path) or file_path
    local clients = ra.get_active_rustaceanvim_clients(nil, { method = method })

    for _, c in ipairs(clients) do
      if c.workspace_folders then
        for _, folder in ipairs(c.workspace_folders) do
          local folder_path = folder.name or vim.uri_to_fname(folder.uri)
          if folder_path and vim.fs.relpath(folder_path, norm_path) ~= nil then
            return c
          end
        end
      end
      for bufnr, _ in pairs(c.attached_buffers or {}) do
        local bname = vim.api.nvim_buf_get_name(bufnr)
        if bname == file_path or bname == norm_path then
          return c
        end
      end
    end

    if #clients == 1 then
      return clients[1]
    end
  end
end

local function refresh_open_rust_buffers()
  if not neotest_client then
    return
  end
  local ok_nio, nio = pcall(require, "nio")
  if not ok_nio then
    return
  end
  nio.run(function()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == "rust" then
        local file_path = vim.api.nvim_buf_get_name(bufnr)
        if file_path ~= "" then
          neotest_client:_update_positions(file_path)
        end
      end
    end
  end)
end

local function patch_server_status()
  local ok_status, server_status = pcall(require, "rustaceanvim.server_status")
  if not ok_status or not server_status or server_status._crates_patched then
    return
  end
  server_status._crates_patched = true

  local orig_handler = server_status.handler
  server_status.handler = function(err, result, ctx, config)
    orig_handler(err, result, ctx, config)
    if result and result.quiescent then
      refresh_open_rust_buffers()
    end
  end
end

local function is_ignored_dir(name)
  return name == "target" or name == ".git" or name == ".cargo" or name == ".direnv"
end

local function patch_neotest_adapter()
  local ok_adapter, adapter = pcall(require, "rustaceanvim.neotest")
  if not ok_adapter or not adapter or adapter._crates_patched then
    return
  end
  adapter._crates_patched = true

  local orig_filter_dir = adapter.filter_dir
  adapter.filter_dir = function(name, rel_path, root)
    if is_ignored_dir(name) then
      return false
    end
    if orig_filter_dir then
      return orig_filter_dir(name, rel_path, root)
    end
    return true
  end

  local orig_discover = adapter.discover_positions
  adapter.discover_positions = function(file_path)
    patch_rust_analyzer()
    local ok, tree = pcall(orig_discover, file_path)
    if ok and tree then
      return tree
    end
    return nil
  end
end

local function ensure_positions_and_run(run_args)
  local neotest = require("neotest")
  local nio = require("nio")
  local file_path = vim.fn.expand("%:p")

  nio.run(function()
    local tree = neotest.run.get_tree_from_args(run_args, false)
    if (not tree or not tree:data().runnable) and neotest_client and file_path ~= "" then
      neotest_client:_update_positions(file_path)
    end
    neotest.run.run(run_args)
  end)
end

return {
  {
    "mrcjkb/rustaceanvim",
    opts = function(_, opts)
      patch_rust_analyzer()
      patch_server_status()
      return opts
    end,
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    opts = function(_, opts)
      patch_rust_analyzer()
      patch_server_status()
      patch_neotest_adapter()

      opts.consumers = opts.consumers or {}
      opts.consumers._rust_workspace = function(client)
        neotest_client = client
        return {}
      end

      opts.discovery = opts.discovery or {}
      local orig_filter = opts.discovery.filter_dir
      opts.discovery.filter_dir = function(name, rel_path, root)
        if is_ignored_dir(name) then
          return false
        end
        if orig_filter then
          return orig_filter(name, rel_path, root)
        end
        return true
      end
      return opts
    end,
    keys = {
      {
        "<leader>tr",
        function()
          ensure_positions_and_run()
        end,
        desc = "Run Nearest (Neotest)",
      },
      {
        "<leader>tt",
        function()
          ensure_positions_and_run(vim.fn.expand("%"))
        end,
        desc = "Run File (Neotest)",
      },
    },
  },
}
