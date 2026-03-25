# Adding Snippets to markdown.lua

All custom markdown snippets live in:
[markdown.lua](./markdown.lua)

The file returns two tables — `regular` and `auto` — which LuaSnip loads:
```lua
return regular, auto  -- at the bottom of the file
```

---

## Which table do I add to?

| Table | Trigger key | Use for |
|---|---|---|
| `regular` | **Tab** (via `expandable()`) | Snippets you deliberately expand, e.g. `\int`, `dm` |
| `auto` | **fires instantly** as you type | Greek letters, operators, callouts |

> [!TIP]
> If in doubt, put it in `auto`. Most obsidian-latex-suite snippets were `A` (auto).

---

## The building blocks

```lua
local s   = ls.snippet       -- define a snippet
local t   = ls.text_node     -- static text
local i   = ls.insert_node   -- cursor stop / placeholder
local f   = ls.function_node -- compute text from captures or other nodes
local fmt = require('luasnip.extras.fmt').fmt  -- format-string style
local rep = require('luasnip.extras').rep      -- mirror another insert node
```

---

## Snippet anatomy

```lua
s( SPEC, BODY )
```

**SPEC** — a table of options:

| Key | Values | Meaning |
|---|---|---|
| `trig` | `'mk'`, `'@a'`, `'([A-Za-z])(%d)'` | The trigger text |
| `wordTrig` | `true` / `false` | `false` = fire anywhere (math ops); `true` = word boundary (callouts) |
| `regTrig` | `true` | Treat `trig` as a Lua pattern; use `snip.captures[n]` in body |
| `condition` | `in_mathzone` / `not_in_mathzone` | Only fire inside / outside `$...$` or `$$...$$` |

**BODY** — one of:

| Form | Example |
|---|---|
| single node | `t [[\alpha]]` |
| node table | `{ t 'prefix', i(1,'placeholder'), t 'suffix' }` |
| `fmt(...)` | `fmt([[\frac{{{}}}{{{}}}{}]], { i(1), i(2), i(3) })` |

---

## `fmt` format strings

`{}` is a placeholder for a node. Use `{{` / `}}` for literal braces.

```lua
-- \frac{█}{█}█
fmt([[\frac{{{}}}{{{}}}{}]], { i(1), i(2), i(3) })

-- \hat{█}█
fmt([[\hat{{{}}}{}]], { i(1), i(2) })
```

> [!IMPORTANT]
> Use regular strings `'...'` (not raw `[[...]]`) when you need **real newlines**:
> ```lua
> -- RIGHT — \n is a real newline in a quoted string:
> fmt('\\\\begin{{align}}\n{}\n\\\\end{{align}}', { i(1) })
>
> -- WRONG — \n is literal backslash-n in a raw string:
> fmt([[\begin{{align}}\n{}\n\end{{align}}]], { i(1) })
> ```

---

## `i()` — insert nodes (cursor stops)

```lua
i(1)           -- empty placeholder, numbered for Tab-jump order
i(1, 'text')   -- placeholder with default text
i(0)           -- final cursor position (always last)
```

Tab / `<C-l>` jumps through them in order: `i(1)` → `i(2)` → … → `i(0)`.

`rep(n)` mirrors whatever you typed in `i(n)`:
```lua
-- \begin{█}  body  \end{█}  (both update together)
fmt('\\\\begin{{{}}}\n{}\n\\\\end{{{}}}', { i(1), i(2), rep(1) })
```

---

## `f()` — function nodes (for regex captures)

```lua
-- regex trigger: ([a-zA-Z])hat  →  \hat{x}
s({ trig = '([a-zA-Z])hat', regTrig = true, wordTrig = false,
    condition = in_mathzone },
  f(function(_, snip) return [[\hat{]] .. snip.captures[1] .. '}' end))
```

`snip.captures[n]` holds capture group `n` from the Lua pattern.

---

## Common patterns

### Static text (no jumps)

```lua
s({ trig = '@a', wordTrig = false, condition = in_mathzone },
  t [[\alpha]])
```

### One placeholder

```lua
s({ trig = 'bf', wordTrig = false, condition = in_mathzone },
  fmt([[\mathbf{{{}}}]], { i(1) }))
```

### Two placeholders

```lua
s({ trig = 'hat', wordTrig = false, condition = in_mathzone },
  fmt([[\hat{{{}}}{}]], { i(1), i(2) }))
```

### Text-mode callout ( `tAw` equivalent )

```lua
s({ trig = 'cmyblock', wordTrig = true, condition = not_in_mathzone },
  fmt('> [!note] {}\n> {}', { i(1, 'Title'), i(2) }))
-- → put in `auto` table
```

### Multiline environment

```lua
s({ trig = 'myenv', wordTrig = false, condition = in_mathzone },
  fmt('\\\\begin{{myenv}}\n{}\n\\\\end{{myenv}}', { i(1) }))
-- → put in `auto` table
```

### Code block

```lua
s({ trig = 'pyblock', wordTrig = true, condition = not_in_mathzone },
  fmt('```python\n{}\n```', { i(1) }))
-- → put in `regular` table (Tab to expand)
```

### Regex auto-subscript style

```lua
-- xhat → \hat{x}
s({ trig = '([a-zA-Z])myop', regTrig = true, wordTrig = false,
    condition = in_mathzone },
  f(function(_, snip) return [[\myop{]] .. snip.captures[1] .. '}' end))
-- → put in `auto` table
```

---

## Quick checklist for a new snippet

1. **Where?** math → `condition = in_mathzone`; text → `condition = not_in_mathzone`
2. **Auto or Tab?** auto-fire → `auto` table; explicit Tab → `regular` table
3. **Word boundary?** callouts/code = `wordTrig = true`; math operators = `wordTrig = false`
4. **Newlines?** use `'\\\\begin...\n...'` quoted string, not `[[\n]]`
5. **Test:** reload with `:source %` on [markdown.lua](./markdown.lua) or restart Neovim
