return {
  -- To return multiple snippets, use one `return` statement per snippet file
  -- and return a table of Lua snippets.

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
  -- LstListing
  s(
    { trig = "ls", dscr = "Expands 'ls' into an LstListing environment" },
    fmta(
      [[
       \begin{lstlisting}[caption={<>}, label=<>]
       <>
       \end{lstlisting}
     ]],
      { i(1), i(2), i(3) }
    )
  ),
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
