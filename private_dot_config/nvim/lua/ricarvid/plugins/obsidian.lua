local function get_vaults()
	local vaults = {}
	-- Expand the home directory path
	local path = vim.fn.expand("~/vaults")

	-- globpath returns a string of paths separated by newlines
	-- The '1' as the third argument tells Neovim to return a list (table) instead
	local folders = vim.fn.globpath(path, "*", 0, 1)

	for _, folder_path in ipairs(folders) do
		-- Check if it's actually a directory (and not a loose file)
		if vim.fn.isdirectory(folder_path) == 1 then
			-- Get the folder name (the last part of the path)
			local folder_name = vim.fn.fnamemodify(folder_path, ":t")

			table.insert(vaults, {
				name = folder_name,
				-- We use the original path or re-format with ~ for consistency
				path = "~/vaults/" .. folder_name,
			})
		end
	end
	return vaults
end

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	-- ft = "markdown",
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	event = {
		-- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
		-- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
		"BufReadPre "
			.. vim.fn.expand("~")
			.. "/vaults/**.md",
		"BufNewFile " .. vim.fn.expand("~") .. "/vaults/**.md",
	},
	---@module 'obsidian'
	---@type obsidian.config
	opts = {
		legacy_commands = false,
		-- Workspace
		workspaces = get_vaults(),
		-- Template configuration
		templates = {
			folder = "templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",
			substitutions = {
				year_month = function()
					return os.date("%Y-%m")
				end,
			},
		},

		-- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
		completion = {
			-- Enables completion using blink.cmp
			blink = true,
			-- Trigger completion at 2 chars.
			min_chars = 2,
		},

		-- see below for full list of options 👇
		-- Either 'wiki' or 'markdown'.
		preferred_link_style = "markdown",
		callbacks = {
			enter_note = function(note)
				vim.keymap.set("n", "<leader>oh", "<cmd>Obsidian toggle_checkbox<cr>", {
					buffer = note.bufnr,
					desc = "Checkbox",
				})
				vim.keymap.set("n", "<leader>oo", "<cmd>Obsidian open<CR>", {
					buffer = note.bufnr,
					desc = "Open",
				})
				vim.keymap.set("n", "<leader>on", "<cmd>Obsidian new<CR>", {
					buffer = note.bufnr,
					desc = "New",
				})
				vim.keymap.set("n", "<leader>os", "<cmd>Obsidian quick_switch<CR>", {
					buffer = note.bufnr,
					desc = "Switch notes",
				})
				vim.keymap.set("n", "<leader>ob", "<cmd>Obsidian backlinks<CR>", {
					buffer = note.bufnr,
					desc = "Backlinks to current",
				})
				vim.keymap.set("n", "<leader>ot", "<cmd>Obsidian tags<CR>", {
					buffer = note.bufnr,
					desc = "Tags",
				})
				vim.keymap.set("n", "<leader>ol", "<cmd>Obsidian links<CR>", {
					buffer = note.bufnr,
					desc = "Links",
				})
				vim.keymap.set("n", "<leader>ox", "<cmd>Obsidian extract_note<CR>", {
					buffer = note.bufnr,
					desc = "Extract",
				})
				vim.keymap.set("n", "<leader>ow", "<cmd>Obsidian workspace<CR>", {
					buffer = note.bufnr,
					desc = "Workspace switch",
				})
				vim.keymap.set("n", "<leader>oi", "<cmd>Obsidian paste_img<CR>", {
					buffer = note.bufnr,
					desc = "Img paste",
				})
				vim.keymap.set("n", "<leader>or", "<cmd>Obsidian rename<CR>", {
					buffer = note.bufnr,
					desc = "Rename",
				})
				vim.keymap.set("n", "<leader>oe", "<cmd>Obsidian template<CR>", {
					buffer = note.bufnr,
					desc = "Insert template",
				})
				vim.keymap.set("n", "<leader>om", "<cmd>Obsidian new_from_template<CR>", {
					buffer = note.bufnr,
					desc = "New from template",
				})
				vim.keymap.set("n", "<leader>oc", "<cmd>Obsidian toc<CR>", {
					buffer = note.bufnr,
					desc = "TOC",
				})
				vim.keymap.set("n", "<leader>of", "<cmd>Obsidian search<CR>", {
					buffer = note.bufnr,
					desc = "Find",
				})
			end,
		},
		ui = {
			enable = false, -- set to false to disable all additional syntax features
		},
	},
}
