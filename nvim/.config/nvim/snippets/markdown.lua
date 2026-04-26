local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
--
-- -- Collect all snippets into a local table first so we can append to it
-- -- Could also return the whold table as
-- -- return {Your snippets}
-- local snips = {
--
--  -- Expands "python" → fenced python block
--  s("python", {
--      t({ "```python", "" }), -- "```python" then newline
--      i(1, "# Code Here"), -- cursor lands here
--      t({ "", "```" }), -- newline then closing fence
--  }),
--
--  -- Expands "code" → fenced block with language and body as insert nodes
--  s("code", fmt("```{}\n{}\n```", { i(1, "language"), i(2, "# Code Here") })),
--
--  -- Expands "fm" → YAML front matter scaffold
--  s(
--      "fm",
--      fmt(
--          [[
-- ---
-- title: {}
-- date: {}
-- tags: [{}]
-- ---]],
--          { i(1, "Title"), i(2, "YYYY-MM-DD"), i(3) }
--      )
--  ),
-- }
--
-- -- Programmatic: builds h1-h6 at runtime and appends to the same table
-- -- h1 → "# Heading", h2 → "## Heading", etc.
-- for level = 1, 6 do
--  snips[#snips + 1] = s("h" .. level, {
--      t(string.rep("#", level) .. " "),
--      i(1, "Heading"),
--  })
-- end
--
-- return snips
