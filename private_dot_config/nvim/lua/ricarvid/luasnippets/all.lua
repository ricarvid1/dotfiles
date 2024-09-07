-- Place this in ${HOME}/.config/nvim/LuaSnip/all.lua

-- This is the `get_visual` function I've been talking about.
-- ----------------------------------------------------------------------------
-- Summary: When `LS_SELECT_RAW` is populated with a visual selection, the function
-- returns an insert node whose initial text is set to the visual selection.
-- When `LS_SELECT_RAW` is empty, the function simply returns an empty insert node.
local get_visual = function(args, parent)
  if #parent.snippet.env.LS_SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end
-- ----------------------------------------------------------------------------

return {
  -- A snippet that expands the trigger "hi" into the string "Hello, world!".
  -- require("luasnip").snippet({ trig = "hi" }, { t("Hello, world!") }),
  -- Example: how to set snippet parameters
  -- require("luasnip").snippet(
  --   { -- Table 1: snippet parameters
  --     trig = "hi",
  --     dscr = "An autotriggering snippet that expands 'hi' into 'Hello, world!'",
  --     regTrig = false,
  --     priority = 100,
  --     snippetType = "autosnippet",
  --   },
  --   { -- Table 2: snippet nodes (don't worry about this for now---we'll cover nodes shortly)
  --     t("Hello, world!"), -- A single text node
  --   }
  --   -- Table 3, the advanced snippet options, is left blank.
  -- ),

  -- To return multiple snippets, use one `return` statement per snippet file
  -- and return a table of Lua snippets.
  -- require("luasnip").snippet({ trig = "foo" }, { t("Another snippet.") }),

  -- Examples of Greek letter snippets, autotriggered for efficiency
  -- s({ trig = ";a", snippetType = "autosnippet" }, {
  --   t("\\alpha"),
  -- }),
  -- s({ trig = ";b", snippetType = "autosnippet" }, {
  --   t("\\beta"),
  -- }),
  -- s({ trig = ";g", snippetType = "autosnippet" }, {
  --   t("\\gamma"),
  -- }),
  -- Example of a multiline text node
  -- s({ trig = "lines", dscr = "Demo: a text node with three lines." }, {
  --   t({ "Line 1", "Line 2", "Line 3" }),
  -- }),
  -- Combining text and insert nodes to create basic LaTeX commands
  -- \texttt
  -- s({ trig = "tt", dscr = "Expands 'tt' into '\texttt{}'" }, {
  --   t("\\texttt{"), -- remember: backslashes need to be escaped
  --   i(1),
  --   t("}"),
  -- }),
  -- Yes, these jumbles of text nodes and insert nodes get messy fast, and yes,
  -- there is a much better, human-readable solution: ls.fmt, described shortly.
  -- \frac
  -- s({ trig = "ff", dscr = "Expands 'ff' into '\frac{}{}'" }, {
  --   t("\\frac{"),
  --   i(1), -- insert node 1
  --   t("}{"),
  --   i(2), -- insert node 2
  --   t("}"),
  -- }),
  -- Equation
  -- s(
  --   { trig = "eq", dscr = "Expands 'eq' into an equation environment" },
  --   fmta(
  --     [[
  --      \begin{equation*}
  --          <>
  --      \end{equation*}
  --    ]],
  --     { i(0) }
  --   )
  -- ),
  -- Code for environment snippet
  -- s(
  --   { trig = "env", snippetType = "autosnippet" },
  --   fmta(
  --     [[
  --     \begin{<>}
  --         <>
  --     \end{<>}
  --   ]],
  --     {
  --       i(1),
  --       i(2),
  --       rep(1), -- this node repeats insert node i(1)
  --     }
  --   )
  -- ),
  -- Example use of insert node placeholder text
  -- s(
  --   { trig = "hr", dscr = "The hyperref package's href{}{} command (for url links)" },
  --   fmta([[\href{<>}{<>}]], {
  --     i(1, "url"),
  --     i(2, "display name"),
  --   })
  -- ),
  -- Example: italic font implementing visual selection
  -- s(
  --   { trig = "tii", dscr = "Expands 'tii' into LaTeX's textit{} command." },
  --   fmta("\\textit{<>}", {
  --     d(1, get_visual),
  --   })
  -- ),
  -- Using regular expressions
  -- s(
  --   { trig = "([^%a])mm", wordTrig = false, regTrig = true },
  --   fmta("<>$<>$", {
  --     f(function(_, snip)
  --       return snip.captures[1]
  --     end),
  --     d(1, get_visual),
  --   })
  -- ),
}
