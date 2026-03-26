-- [[ MARKDOWN LATEX SNIPPETS ]]
-- Port of obsidian-latex-suite/data.json for LuaSnip in markdown files.
--
-- OPTIONS KEY (obsidian → LuaSnip):
--   m  = math only       → condition = in_mathzone
--   t  = text only       → condition = not_in_mathzone
--   A  = auto-expand     → in `auto` table (returned as 2nd value)
--   w  = word boundary   → wordTrig = true
--   (no w)               → wordTrig = false  ← default for math snippets!
--   r  = regex trigger   → regTrig = true, Lua pattern

local ls  = require 'luasnip'
local s   = ls.snippet
local t   = ls.text_node
local i   = ls.insert_node
local f   = ls.function_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep

-- =============================================================================
-- MATH CONTEXT DETECTION
-- Scans all text up to the cursor counting unescaped $ / $$ delimiters.
-- =============================================================================
local function in_mathzone()
	local pos = vim.api.nvim_win_get_cursor(0)
	local row, col = pos[1] - 1, pos[2]
	local lines = vim.api.nvim_buf_get_lines(0, 0, row + 1, false)
	lines[#lines] = lines[#lines]:sub(1, col)

	-- Treesitter fallback if available
	local has_ts, ts = pcall(require, 'vim.treesitter')
	if has_ts then
		local node = ts.get_node({ bufnr = 0, pos = { row, col } })
		while node do
			if node:type() == 'math_environment' or node:type() == 'latex_block' or node:type() == 'inline_formula' or node:type() == 'math' then
				return true
			end
			node = node:parent()
		end
	end

	local display_math = false
	local inline_math = false

	for _, line in ipairs(lines) do
		inline_math = false
		line = line:gsub('\\%$', '  ')
		line = line:gsub('`[^`]*`', function(m) return string.rep(' ', #m) end)

		local idx = 1
		while idx <= #line do
			if line:sub(idx, idx + 1) == '$$' then
				if not inline_math then
					display_math = not display_math
				end
				idx = idx + 2
			elseif line:sub(idx, idx) == '$' then
				if not display_math then
					inline_math = not inline_math
				end
				idx = idx + 1
			else
				idx = idx + 1
			end
		end
	end

	return display_math or inline_math
end

local function not_in_mathzone() return not in_mathzone() end

-- Check if a trigger is preceded by a backslash or a letter (to avoid double-prefixing)
local function no_prefix(_, _, captures)
	local c1 = captures[1]
	if not c1 or c1 == "" then return true end
	return not c1:match("[\\%a]$")
end


-- =============================================================================
-- REGULAR SNIPPETS  (Tab required to expand)
-- =============================================================================
local regular = {
	-- \sum / \prod / \int  with limits (typed after the macro is already in the buffer)
	s({ trig = [[\sum]], wordTrig = false, condition = in_mathzone },
		fmt([[\sum_{{{} = {}}}^{{{}}} {}]], { i(1, 'i'), i(2, '1'), i(3, 'N'), i(4) })),
	s({ trig = [[\prod]], wordTrig = false, condition = in_mathzone },
		fmt([[\prod_{{{} = {}}}^{{{}}} {}]], { i(1, 'i'), i(2, '1'), i(3, 'N'), i(4) })),
	s({ trig = [[\int]], wordTrig = false, condition = in_mathzone },
		fmt([[\int {} \, d{} {}]], { i(1), i(2, 'x'), i(3) })),
	s({ trig = 'lim', wordTrig = false, condition = in_mathzone },
		fmt([[\lim_{{ {} \to {} }} {}]], { i(1, 'n'), i(2, [[\infty]]), i(3) })),

	-- Partial derivatives (non-auto: you choose when to expand)
	s({ trig = 'par', wordTrig = false, condition = in_mathzone },
		fmt([[\frac{{ \partial {} }}{{ \partial {} }} {}]], { i(1, 'y'), i(2, 'x'), i(3) })),
	s({
			trig = 'pa([A-Za-z])([A-Za-z])',
			regTrig = true,
			wordTrig = false,
			condition = in_mathzone
		},
		f(function(_, snip)
			return [[\frac{ \partial ]] .. snip.captures[1]
			    .. [[ }{ \partial ]] .. snip.captures[2] .. ' } '
		end)),

	-- Code blocks (text mode, word boundary, NOT auto – require Tab)
	s({ trig = 'pypy', wordTrig = true, condition = not_in_mathzone },
		fmt('```python\n{}\n```', { i(1) })),
	s({ trig = 'jmain', wordTrig = true, condition = not_in_mathzone },
		fmt(
			'```java\npublic class {} {{\n    public static void main(String[] args) {{\n        {}\n    }}\n}}\n```',
			{ i(1, 'Main'), i(2) })),
	s({ trig = 'cpp', wordTrig = true, condition = not_in_mathzone },
		fmt('```cpp\n{}\n```', { i(1) })),
	s({ trig = '#!', wordTrig = false, condition = not_in_mathzone },
		fmt('```bash\n{}\n```', { i(1) })),
}

-- =============================================================================
-- AUTOSNIPPETS  (fire immediately when trigger is typed)
-- =============================================================================
local auto = {

	-- ── MATH ENTRY ──────────────────────────────────────────────────────────────
	-- mk: tA (text, auto, no word boundary)
	s({ trig = 'mk', wordTrig = false, condition = not_in_mathzone },
		fmt('${}$', { i(1) })),
	-- dm: tAw (text, auto, word boundary)
	s({ trig = 'dm', wordTrig = true, condition = not_in_mathzone },
		fmt('$$\n{}\n$$', { i(1) })),
	-- beg: mA (math, auto, no word boundary)
	s({ trig = 'beg', wordTrig = false, condition = in_mathzone },
		fmt([[\begin{{{}}}
{}
\end{{{}}}]], { i(1), i(2), rep(1) })),

	-- ── OBSIDIAN CALLOUTS ( tAw ) ───────────────────────────────────────────────
	s({ trig = 'cdef', wordTrig = true, condition = not_in_mathzone },
		fmt('> [!definition] {}\n> {}', { i(1, 'Definition'), i(2) })),
	s({ trig = 'cex', wordTrig = true, condition = not_in_mathzone },
		fmt('> [!example] {}\n> {}', { i(1, 'Example'), i(2) })),
	s({ trig = 'csol', wordTrig = true, condition = not_in_mathzone },
		fmt('> [!success]- {}\n> {}', { i(1, 'Solution'), i(2) })),
	s({ trig = 'cimp', wordTrig = true, condition = not_in_mathzone },
		fmt('> [!warning] {}\n> {}', { i(1, 'Important'), i(2) })),
	s({ trig = 'cque', wordTrig = true, condition = not_in_mathzone },
		fmt('> [!question] {}\n> {}', { i(1, 'Question'), i(2) })),
	s({ trig = 'cc', wordTrig = true, condition = not_in_mathzone },
		fmt('> [!{}] {}\n> {}', { i(1, 'info'), i(2, 'Title'), i(3) })),
	s({ trig = 'cabs', wordTrig = true, condition = not_in_mathzone },
		fmt('> [!abstract] {}\n> {}', { i(1, 'Abstract'), i(2) })),

	-- Universal Callout Picker
	s({ trig = 'ccall', wordTrig = true, condition = not_in_mathzone },
		fmt('> [!{}] {}\n> {}', {
			ls.choice_node(1, {
				t 'info', t 'todo', t 'tip', t 'abstract', t 'success',
				t 'question', t 'warning', t 'failure', t 'danger', t 'bug', t 'quote'
			}),
			i(2, 'Title'),
			i(3, 'Content')
		})),


	-- ── MARKDOWN / OBSIDIAN TOOLS ───────────────────────────────────────────────
	s({ trig = 'cweb', wordTrig = true, condition = not_in_mathzone },
		fmt('<iframe src="{}" width="100%" height="{}" style="border:none; border-radius: 8px;"></iframe>\n{}',
			{ i(1, 'URL'), i(2, '500px'), i(3) })),
	s({ trig = '-c ', wordTrig = false, condition = not_in_mathzone },
		fmt('- [ ] {}', { i(1) })),
	s({ trig = 'ii', wordTrig = false, condition = not_in_mathzone },
		fmt('`{}`{}', { i(1), i(2) })),
	s({ trig = 'clog', wordTrig = true, condition = not_in_mathzone },
		fmt('```c\n{}\n```', { i(1) })),

	-- ── GREEK LETTERS ( mA, no word boundary ) ──────────────────────────────────
	s({ trig = '@a', wordTrig = false, condition = in_mathzone }, t [[\alpha]]),
	s({ trig = '@b', wordTrig = false, condition = in_mathzone }, t [[\beta]]),
	s({ trig = '@g', wordTrig = false, condition = in_mathzone }, t [[\gamma]]),
	s({ trig = '@G', wordTrig = false, condition = in_mathzone }, t [[\Gamma]]),
	s({ trig = '@d', wordTrig = false, condition = in_mathzone }, t [[\delta]]),
	s({ trig = '@D', wordTrig = false, condition = in_mathzone }, t [[\Delta]]),
	s({ trig = '@e', wordTrig = false, condition = in_mathzone }, t [[\epsilon]]),
	s({ trig = ':e', wordTrig = false, condition = in_mathzone }, t [[\varepsilon]]),
	s({ trig = '@z', wordTrig = false, condition = in_mathzone }, t [[\zeta]]),
	s({ trig = '@h', wordTrig = false, condition = in_mathzone }, t [[\eta]]),
	s({ trig = '@t', wordTrig = false, condition = in_mathzone }, t [[\theta]]),
	s({ trig = '@T', wordTrig = false, condition = in_mathzone }, t [[\Theta]]),
	s({ trig = ':t', wordTrig = false, condition = in_mathzone }, t [[\vartheta]]),
	s({ trig = '@i', wordTrig = false, condition = in_mathzone }, t [[\iota]]),
	s({ trig = '@k', wordTrig = false, condition = in_mathzone }, t [[\kappa]]),
	s({ trig = '@l', wordTrig = false, condition = in_mathzone }, t [[\lambda]]),
	s({ trig = '@L', wordTrig = false, condition = in_mathzone }, t [[\Lambda]]),
	s({ trig = '@m', wordTrig = false, condition = in_mathzone }, t [[\mu]]),
	s({ trig = '@n', wordTrig = false, condition = in_mathzone }, t [[\nu]]),
	s({ trig = '@x', wordTrig = false, condition = in_mathzone }, t [[\xi]]),
	s({ trig = '@X', wordTrig = false, condition = in_mathzone }, t [[\Xi]]),
	s({ trig = '@p', wordTrig = false, condition = in_mathzone }, t [[\pi]]),
	s({ trig = '@r', wordTrig = false, condition = in_mathzone }, t [[\rho]]),
	s({ trig = '@s', wordTrig = false, condition = in_mathzone }, t [[\sigma]]),
	s({ trig = '@S', wordTrig = false, condition = in_mathzone }, t [[\Sigma]]),
	s({ trig = '@u', wordTrig = false, condition = in_mathzone }, t [[\upsilon]]),
	s({ trig = '@U', wordTrig = false, condition = in_mathzone }, t [[\Upsilon]]),
	s({ trig = '@f', wordTrig = false, condition = in_mathzone }, t [[\phi]]),
	s({ trig = ':f', wordTrig = false, condition = in_mathzone }, t [[\varphi]]),
	s({ trig = '@F', wordTrig = false, condition = in_mathzone }, t [[\Phi]]),
	s({ trig = '@y', wordTrig = false, condition = in_mathzone }, t [[\psi]]),
	s({ trig = '@Y', wordTrig = false, condition = in_mathzone }, t [[\Psi]]),
	s({ trig = '@o', wordTrig = false, condition = in_mathzone }, t [[\omega]]),
	s({ trig = '@O', wordTrig = false, condition = in_mathzone }, t [[\Omega]]),
	s({ trig = 'ome', wordTrig = false, condition = in_mathzone }, t [[\omega]]),
	s({ trig = 'Ome', wordTrig = false, condition = in_mathzone }, t [[\Omega]]),

	-- ── TEXT ENVIRONMENT ( mA ) ──────────────────────────────────────────────────
	s({ trig = 'text', wordTrig = false, condition = in_mathzone },
		fmt([[\text{{{}}}{}]], { i(1), i(2) })),
	-- " → \text{} (obsidian shorthand)
	s({ trig = '"', wordTrig = false, condition = in_mathzone },
		fmt([[\text{{{}}}{}]], { i(1), i(2) })),

	-- ── BASIC OPERATIONS ( mA, no word boundary ) ──────────────────────────────
	s({ trig = 'sr', wordTrig = false, condition = in_mathzone }, t '^{2}'),
	s({ trig = 'cb', wordTrig = false, condition = in_mathzone }, t '^{3}'),
	s({ trig = 'rd', wordTrig = false, condition = in_mathzone },
		fmt('^{{{}}}{}', { i(1), i(2) })),
	s({ trig = 'us', wordTrig = false, condition = in_mathzone },
		fmt('_{{{}}}{}', { i(1), i(2) })),
	s({ trig = 'sts', wordTrig = false, condition = in_mathzone },
		fmt([[_\text{{{}}}]], { i(1) })),
	s({ trig = 'sq', wordTrig = false, condition = in_mathzone },
		fmt([[\sqrt{{ {} }}{}]], { i(1), i(2) })),
	s({ trig = 'nsq', wordTrig = false, condition = in_mathzone },
		fmt([[\sqrt[{}]{{{}}}{}]], { i(1, 'n'), i(2), i(3) })),
	s({ trig = '//', wordTrig = false, condition = in_mathzone },
		fmt([[\frac{{{}}}{{{}}}{}]], { i(1), i(2), i(3) })),
	-- [060b] Auto-capture Fraction (mA)
	-- Logic: Grabs the "word" before / and moves it into the numerator
	s({ trig = "([%w\\%^%_%{%}%(%)%[%]]+)/", regTrig = true, wordTrig = false, condition = in_mathzone },
		fmt([[\frac{{{}}}{{{}}}]], {
			f(function(_, snip) return snip.captures[1] end),
			i(1)
		})
	),
	s({ trig = 'ee', wordTrig = false, condition = in_mathzone },
		fmt([[e^{{ {} }}{}]], { i(1), i(2) })),
	s({ trig = 'invs', wordTrig = false, condition = in_mathzone }, t '^{-1}'),
	s({ trig = 'conj', wordTrig = false, condition = in_mathzone }, t '^{*}'),
	s({ trig = 'Re', wordTrig = false, condition = in_mathzone }, t [[\mathrm{Re}]]),
	s({ trig = 'Im', wordTrig = false, condition = in_mathzone }, t [[\mathrm{Im}]]),
	s({ trig = 'bf', wordTrig = false, condition = in_mathzone },
		fmt([[\mathbf{{{}}}]], { i(1) })),
	s({ trig = 'rm', wordTrig = false, condition = in_mathzone },
		fmt([[\mathrm{{{}}}{}]], { i(1), i(2) })),
	s({ trig = 'trace', wordTrig = false, condition = in_mathzone }, t [[\mathrm{Tr}]]),

	-- ── SYMBOLS ( mA ) ──────────────────────────────────────────────────────────
	s({ trig = 'ooo', wordTrig = false, condition = in_mathzone }, t [[\infty]]),
	s({ trig = 'sum', wordTrig = false, condition = in_mathzone }, t [[\sum]]),
	s({ trig = 'prod', wordTrig = false, condition = in_mathzone }, t [[\prod]]),
	s({ trig = '+-', wordTrig = false, condition = in_mathzone }, t [[\pm]]),
	s({ trig = '-+', wordTrig = false, condition = in_mathzone }, t [[\mp]]),
	s({ trig = '...', wordTrig = false, condition = in_mathzone }, t [[\dots]]),
	s({ trig = 'nabl', wordTrig = false, condition = in_mathzone }, t [[\nabla]]),
	s({ trig = 'del', wordTrig = false, condition = in_mathzone }, t [[\nabla]]),
	s({ trig = 'xx', wordTrig = false, condition = in_mathzone }, t [[\times]]),
	s({ trig = '**', wordTrig = false, condition = in_mathzone },
		fmt([[\cdot {}]], { i(1) })),
	s({ trig = 'para', wordTrig = false, condition = in_mathzone }, t [[\parallel]]),
	s({ trig = '===', wordTrig = false, condition = in_mathzone }, t [[\equiv]]),
	s({ trig = '!=', wordTrig = false, condition = in_mathzone }, t [[\neq]]),
	s({ trig = '>=', wordTrig = false, condition = in_mathzone }, t [[\geq]]),
	s({ trig = '<=', wordTrig = false, condition = in_mathzone }, t [[\leq]]),
	s({ trig = '>>', wordTrig = false, condition = in_mathzone }, t [[\gg]]),
	s({ trig = '<<', wordTrig = false, condition = in_mathzone }, t [[\ll]]),
	s({ trig = 'simm', wordTrig = false, condition = in_mathzone }, t [[\sim]]),
	s({ trig = 'sim=', wordTrig = false, condition = in_mathzone }, t [[\simeq]]),
	s({ trig = 'prop', wordTrig = false, condition = in_mathzone }, t [[\propto]]),
	s({ trig = '~~', wordTrig = false, condition = in_mathzone }, t [[\approx]]),

	-- ── ARROWS ( mA ) ────────────────────────────────────────────────────────────
	s({ trig = '<->', wordTrig = false, condition = in_mathzone }, t [[\leftrightarrow ]]),
	s({ trig = '->', wordTrig = false, condition = in_mathzone }, t [[\to]]),
	s({ trig = '!>', wordTrig = false, condition = in_mathzone }, t [[\mapsto]]),
	s({ trig = '=>', wordTrig = false, condition = in_mathzone }, t [[\implies]]),
	s({ trig = '=<', wordTrig = false, condition = in_mathzone }, t [[\impliedby]]),

	-- ── SETS / LOGIC ( mA ) ──────────────────────────────────────────────────────
	s({ trig = 'and', wordTrig = false, condition = in_mathzone }, t [[\cap]]),
	s({ trig = 'orr', wordTrig = false, condition = in_mathzone }, t [[\cup]]),
	s({ trig = 'inn', wordTrig = false, condition = in_mathzone }, t [[\in]]),
	s({ trig = 'notin', wordTrig = false, condition = in_mathzone }, t [[\not\in]]),
	s({ trig = 'sub=', wordTrig = false, condition = in_mathzone }, t [[\subseteq]]),
	s({ trig = 'sup=', wordTrig = false, condition = in_mathzone }, t [[\supseteq]]),
	s({ trig = 'eset', wordTrig = false, condition = in_mathzone }, t [[\emptyset]]),
	s({ trig = 'set', wordTrig = false, condition = in_mathzone },
		fmt([[\{{ {} \}}{}]], { i(1), i(2) })),
	s({ trig = '&&', wordTrig = false, condition = in_mathzone }, t [[\quad \land \quad]]),
	s({ trig = 'LL', wordTrig = false, condition = in_mathzone }, t [[\mathcal{L}]]),
	s({ trig = 'HH', wordTrig = false, condition = in_mathzone }, t [[\mathcal{H}]]),
	s({ trig = 'CC', wordTrig = false, condition = in_mathzone }, t [[\mathbb{C}]]),
	s({ trig = 'RR', wordTrig = false, condition = in_mathzone }, t [[\mathbb{R}]]),
	s({ trig = 'ZZ', wordTrig = false, condition = in_mathzone }, t [[\mathbb{Z}]]),
	s({ trig = 'NN', wordTrig = false, condition = in_mathzone }, t [[\mathbb{N}]]),
	s({ trig = 'QQ', wordTrig = false, condition = in_mathzone }, t [[\mathbb{Q}]]),

	-- ── LOGICAL ARGUMENTS ( mA ) ──────────────────────────────────────────────────
	s({ trig = '?fa', wordTrig = false, condition = in_mathzone },
		fmt([[\forall {}]], { i(1) })),
	s({ trig = '?ex', wordTrig = false, condition = in_mathzone },
		fmt([[\exists {}]], { i(1) })),
	s({ trig = '?tf', wordTrig = false, condition = in_mathzone },
		fmt([[\therefore {}]], { i(1) })),
	s({ trig = '?be', wordTrig = false, condition = in_mathzone },
		fmt([[\because {}]], { i(1) })),
	s({ trig = 'neg', wordTrig = false, condition = in_mathzone }, t [[\neg]]),
	s({ trig = '?qed', wordTrig = false, condition = in_mathzone }, t [[\square]]),
	s({ trig = '?st', wordTrig = false, condition = in_mathzone }, t [[\text{ s.t. }]]),
	s({ trig = '?ue', wordTrig = false, condition = in_mathzone },
		fmt([[\exists! {}]], { i(1) })),
	s({ trig = 'iff', wordTrig = false, condition = in_mathzone }, t [[\iff]]),



	-- ── DECORATORS ( mA, no word boundary ) ──────────────────────────────────────
	s({ trig = 'hat', wordTrig = false, condition = in_mathzone },
		fmt([[\hat{{{}}}{}]], { i(1), i(2) })),
	s({ trig = 'bar', wordTrig = false, condition = in_mathzone },
		fmt([[\bar{{{}}}{}]], { i(1), i(2) })),
	s({ trig = 'dot', wordTrig = false, condition = in_mathzone },
		fmt([[\dot{{{}}}{}]], { i(1), i(2) })),
	s({ trig = 'ddot', wordTrig = false, condition = in_mathzone },
		fmt([[\ddot{{{}}}{}]], { i(1), i(2) })),
	s({ trig = 'cdot', wordTrig = false, condition = in_mathzone }, t [[\cdot]]),
	s({ trig = 'tilde', wordTrig = false, condition = in_mathzone },
		fmt([[\tilde{{{}}}{}]], { i(1), i(2) })),
	s({ trig = 'und', wordTrig = false, condition = in_mathzone },
		fmt([[\underline{{{}}}{}]], { i(1), i(2) })),
	s({ trig = 'vec', wordTrig = false, condition = in_mathzone },
		fmt([[\vec{{{}}}{}]], { i(1), i(2) })),

	-- ── MISC SUBSCRIPT SHORTHANDS ( mA ) ─────────────────────────────────────────
	s({ trig = 'xnn', wordTrig = false, condition = in_mathzone }, t 'x_{n}'),
	s({ trig = 'xjj', wordTrig = false, condition = in_mathzone }, t 'x_{j}'),
	s({ trig = 'xp1', wordTrig = false, condition = in_mathzone }, t 'x_{n+1}'),
	s({ trig = 'ynn', wordTrig = false, condition = in_mathzone }, t 'y_{n}'),
	s({ trig = 'yii', wordTrig = false, condition = in_mathzone }, t 'y_{i}'),
	s({ trig = 'yjj', wordTrig = false, condition = in_mathzone }, t 'y_{j}'),

	s({ trig = 'infi', wordTrig = false, condition = in_mathzone },
		fmt([[\int_{{-\infty}}^{{\infty}} {} \, d{} {}]], { i(1), i(2, 'x'), i(3) })),

	-- ── INTEGRALS / DERIVATIVES ( mA ) ───────────────────────────────────────────
	s({ trig = 'ddt', wordTrig = false, condition = in_mathzone }, t [[\frac{d}{dt} ]]),
	s({ trig = 'dint', wordTrig = false, condition = in_mathzone },
		fmt([[\int_{{{}}}^{{{}}} {} \, d{} {}]],
			{ i(1, '0'), i(2, '1'), i(3), i(4, 'x'), i(5) })),
	s({ trig = 'iiint', wordTrig = false, condition = in_mathzone }, t [[\iiint]]),
	s({ trig = 'iint', wordTrig = false, condition = in_mathzone }, t [[\iint]]),
	s({ trig = 'oint', wordTrig = false, condition = in_mathzone }, t [[\oint]]),
	s({ trig = 'oinf', wordTrig = false, condition = in_mathzone },
		fmt([[\int_{{0}}^{{\infty}} {} \, d{} {}]], { i(1), i(2, 'x'), i(3) })),
	s({ trig = 'infi', wordTrig = false, condition = in_mathzone },
		fmt([[\int_{{-\infty}}^{{\infty}} {} \, d{} {}]], { i(1), i(2, 'x'), i(3) })),

	-- ── QUANTUM MECHANICS / PHYSICS ( mA ) ───────────────────────────────────────
	s({ trig = 'dag', wordTrig = false, condition = in_mathzone }, t [[^{\dagger}]]),
	s({ trig = 'o+', wordTrig = false, condition = in_mathzone }, t [[\oplus ]]),
	s({ trig = 'ox', wordTrig = false, condition = in_mathzone }, t [[\otimes ]]),
	s({ trig = 'bra', wordTrig = false, condition = in_mathzone },
		fmt([[\bra{{{}}} {}]], { i(1), i(2) })),
	s({ trig = 'ket', wordTrig = false, condition = in_mathzone },
		fmt([[\ket{{{}}} {}]], { i(1), i(2) })),
	s({ trig = 'brk', wordTrig = false, condition = in_mathzone },
		fmt([[\braket{{ {} | {} }} {}]], { i(1), i(2), i(3) })),
	s({ trig = 'outer', wordTrig = false, condition = in_mathzone },
		fmt([[\ket{{{}}} \bra{{{}}} {}]], { i(1, [[\psi]]), rep(1), i(2) })),
	s({ trig = 'kbt', wordTrig = false, condition = in_mathzone }, t 'k_{B}T'),
	s({ trig = 'msun', wordTrig = false, condition = in_mathzone }, t [[M_{\odot}]]),

	-- ── CHEMISTRY ( mA ) ─────────────────────────────────────────────────────────
	s({ trig = 'pu', wordTrig = false, condition = in_mathzone },
		fmt([[\pu{{ {} }}]], { i(1) })),
	s({ trig = 'cee', wordTrig = false, condition = in_mathzone },
		fmt([[\ce{{ {} }}]], { i(1) })),
	s({ trig = 'he4', wordTrig = false, condition = in_mathzone }, t '{}^{4}_{2}He '),
	s({ trig = 'he3', wordTrig = false, condition = in_mathzone }, t '{}^{3}_{2}He '),
	s({ trig = 'iso', wordTrig = false, condition = in_mathzone },
		fmt('{{}}^{{{}}}_{{{}}}{} ', { i(1, '4'), i(2, '2'), i(3, 'He') })),

	-- ── ENVIRONMENTS ( mA ) ──────────────────────────────────────────────────────
	s({ trig = 'pmat', wordTrig = false, condition = in_mathzone },
		fmt('\\begin{{pmatrix}}\n{}\n\\end{{pmatrix}}', { i(1) })),
	s({ trig = 'bmat', wordTrig = false, condition = in_mathzone },
		fmt('\\begin{{bmatrix}}\n{}\n\\end{{bmatrix}}', { i(1) })),
	s({ trig = 'Bmat', wordTrig = false, condition = in_mathzone },
		fmt('\\begin{{Bmatrix}}\n{}\n\\end{{Bmatrix}}', { i(1) })),
	s({ trig = 'vmat', wordTrig = false, condition = in_mathzone },
		fmt('\\begin{{vmatrix}}\n{}\n\\end{{vmatrix}}', { i(1) })),
	s({ trig = 'Vmat', wordTrig = false, condition = in_mathzone },
		fmt('\\begin{{Vmatrix}}\n{}\n\\end{{Vmatrix}}', { i(1) })),
	s({ trig = 'matrix', wordTrig = false, condition = in_mathzone },
		fmt('\\begin{{matrix}}\n{}\n\\end{{matrix}}', { i(1) })),
	s({ trig = 'cases', wordTrig = false, condition = in_mathzone },
		fmt('\\begin{{cases}}\n{}\n\\end{{cases}}', { i(1) })),
	s({ trig = 'align', wordTrig = false, condition = in_mathzone },
		fmt('\\begin{{align}}\n{}\n\\end{{align}}', { i(1) })),
	s({ trig = 'array', wordTrig = false, condition = in_mathzone },
		fmt('\\begin{{array}}\n{}\n\\end{{array}}', { i(1) })),

	-- ── BRACKETS ( mA ) ──────────────────────────────────────────────────────────
	s({ trig = 'avg', wordTrig = false, condition = in_mathzone },
		fmt([[\langle {} \rangle {}]], { i(1), i(2) })),
	s({ trig = 'norm', wordTrig = false, condition = in_mathzone },
		fmt([[\lvert {} \rvert {}]], { i(1), i(2) })),
	s({ trig = 'Norm', wordTrig = false, condition = in_mathzone },
		fmt([[\lVert {} \rVert {}]], { i(1), i(2) })),
	s({ trig = 'ceil', wordTrig = false, condition = in_mathzone },
		fmt([[\lceil {} \rceil {}]], { i(1), i(2) })),
	s({ trig = 'floor', wordTrig = false, condition = in_mathzone },
		fmt([[\lfloor {} \rfloor {}]], { i(1), i(2) })),
	s({ trig = 'mod', wordTrig = false, condition = in_mathzone },
		fmt('|{}|{}', { i(1), i(2) })),
	s({ trig = 'lr(', wordTrig = false, condition = in_mathzone },
		fmt([[\left( {} \right) {}]], { i(1), i(2) })),
	s({ trig = 'lr{', wordTrig = false, condition = in_mathzone },
		fmt([[\left\{{ {} \right\}} {}]], { i(1), i(2) })),
	s({ trig = 'lr[', wordTrig = false, condition = in_mathzone },
		fmt([[\left[ {} \right] {}]], { i(1), i(2) })),
	s({ trig = 'lr|', wordTrig = false, condition = in_mathzone },
		fmt([[\left| {} \right| {}]], { i(1), i(2) })),
	s({ trig = 'lra', wordTrig = false, condition = in_mathzone },
		fmt([[\left< {} \right> {}]], { i(1), i(2) })),

	-- ── SEQUENCES & SERIES ( mA ) ────────────────────────────────────────────────
	s({ trig = 'seq', wordTrig = false, condition = in_mathzone },
		fmt([[\{{{}_{{{} = {}}}\}}^{{\infty}} {}]],
			{ i(1, 'a_n'), i(2, 'n'), i(3, '1'), i(4) })),
	s({ trig = 'sumn', wordTrig = false, condition = in_mathzone },
		fmt([[sum_{{{} = {}}}^{{\infty}} {}]], { i(1, 'n'), i(2, '1'), i(3) })),
	s({ trig = 'sumk', wordTrig = false, condition = in_mathzone },
		fmt([[sum_{{{} = {}}}^{{{}}} {}]], { i(1, 'k'), i(2, '1'), i(3, 'n'), i(4) })),
	s({ trig = 'limn', wordTrig = false, condition = in_mathzone },
		fmt([[\lim_{{{} \to \infty}} {}]], { i(1, 'n'), i(2) })),
	s({ trig = 'limsup', wordTrig = false, condition = in_mathzone },
		fmt([[\limsup_{{{} \to \infty}} {}]], { i(1, 'n'), i(2) })),
	s({ trig = 'liminf', wordTrig = false, condition = in_mathzone },
		fmt([[\liminf_{{{} \to \infty}} {}]], { i(1, 'n'), i(2) })),
	s({ trig = 'geom', wordTrig = false, condition = in_mathzone },
		fmt([[{} \cdot {}^{{{}-1}} {}]], { i(1, 'a'), i(2, 'r'), i(3, 'n'), i(4) })),
	s({ trig = 'arith', wordTrig = false, condition = in_mathzone },
		fmt([[{} + ({} - 1){} {}]], { i(1, 'a'), i(2, 'n'), i(3, 'd'), i(4) })),

	-- ── CUSTOM / MISC ( mA ) ─────────────────────────────────────────────────────
	s({ trig = 'tayl', wordTrig = false, condition = in_mathzone },
		fmt([[{}({} + {}) = {}({}) + {}'({}){}  + {}''({}) \frac{{{}^{{2}}}}{{2!}} + \dots{}]],
			{ i(1, 'f'), i(2, 'x'), i(3, 'h'),
				rep(1), rep(2),
				rep(1), rep(2), rep(3),
				rep(1), rep(2), rep(3),
				i(4) })),

	-- ── TRIG FUNCTIONS ( moved to end to prevent shadowing specific snippets like 'dint' ) ──
	s({ trig = '(.-)(arcsin)', regTrig = true, wordTrig = false, condition = no_prefix },
		f(function(_, snip) return snip.captures[1] .. [[\arcsin]] end)),
	s({ trig = '(.-)(arccos)', regTrig = true, wordTrig = false, condition = no_prefix },
		f(function(_, snip) return snip.captures[1] .. [[\arccos]] end)),
	s({ trig = '(.-)(arctan)', regTrig = true, wordTrig = false, condition = no_prefix },
		f(function(_, snip) return snip.captures[1] .. [[\arctan]] end)),
	s({ trig = '(.-)(sin)', regTrig = true, wordTrig = false, condition = no_prefix },
		f(function(_, snip) return snip.captures[1] .. [[\sin]] end)),
	s({ trig = '(.-)(cos)', regTrig = true, wordTrig = false, condition = no_prefix },
		f(function(_, snip) return snip.captures[1] .. [[\cos]] end)),
	s({ trig = '(.-)(tan)', regTrig = true, wordTrig = false, condition = no_prefix },
		f(function(_, snip) return snip.captures[1] .. [[\tan]] end)),
	s({ trig = '(.-)(csc)', regTrig = true, wordTrig = false, condition = no_prefix },
		f(function(_, snip) return snip.captures[1] .. [[\csc]] end)),
	s({ trig = '(.-)(sec)', regTrig = true, wordTrig = false, condition = no_prefix },
		f(function(_, snip) return snip.captures[1] .. [[\sec]] end)),
	s({ trig = '(.-)(cot)', regTrig = true, wordTrig = false, condition = no_prefix },
		f(function(_, snip) return snip.captures[1] .. [[\cot]] end)),
	-- s({ trig = '(.-)(sinh)', regTrig = true, wordTrig = false, condition = no_prefix }, f(function(_, snip) return snip.captures[1] .. [[\sinh]] end)),
	-- s({ trig = '(.-)(cosh)', regTrig = true, wordTrig = false, condition = no_prefix }, f(function(_, snip) return snip.captures[1] .. [[\cosh]] end)),
	-- s({ trig = '(.-)(tanh)', regTrig = true, wordTrig = false, condition = no_prefix }, f(function(_, snip) return snip.captures[1] .. [[\tanh]] end)),
	s({ trig = '(.-)(exp)', regTrig = true, wordTrig = false, condition = no_prefix },
		f(function(_, snip) return snip.captures[1] .. [[\exp]] end)),
	s({ trig = '(.-)(log)', regTrig = true, wordTrig = false, condition = no_prefix },
		f(function(_, snip) return snip.captures[1] .. [[\log]] end)),
	s({ trig = '(.-)(ln)', regTrig = true, wordTrig = false, condition = no_prefix },
		f(function(_, snip) return snip.captures[1] .. [[\ln]] end)),
	s({ trig = '(.-)(det)', regTrig = true, wordTrig = false, condition = no_prefix },
		f(function(_, snip) return snip.captures[1] .. [[\det]] end)),
	s({ trig = '(.-)(int)', regTrig = true, wordTrig = false, condition = no_prefix },
		f(function(_, snip) return snip.captures[1] .. [[\int]] end)),



	-- ── REGEX AUTOSNIPPETS ( mA, no word boundary ) ───────────────────────────────
	-- Auto letter subscript: x2 → x_{2}
	s({
			trig = '([A-Za-z])(%d)',
			regTrig = true,
			wordTrig = false,
			condition = in_mathzone
		},
		f(function(_, snip)
			return snip.captures[1] .. '_{' .. snip.captures[2] .. '}'
		end)),

	-- Double-digit subscript: x12 → x_{12}
	s({
			trig = '([A-Za-z])_(%d%d)',
			regTrig = true,
			wordTrig = false,
			condition = in_mathzone
		},
		f(function(_, snip)
			return snip.captures[1] .. '_{' .. snip.captures[2] .. '}'
		end)),

	-- Postfix decorators on single letters: xhat → \hat{x}
	s({ trig = '([a-zA-Z])hat', regTrig = true, wordTrig = false, condition = in_mathzone },
		f(function(_, snip) return [[\hat{]] .. snip.captures[1] .. '}' end)),
	s({ trig = '([a-zA-Z])bar', regTrig = true, wordTrig = false, condition = in_mathzone },
		f(function(_, snip) return [[\bar{]] .. snip.captures[1] .. '}' end)),
	s({ trig = '([a-zA-Z])dot', regTrig = true, wordTrig = false, condition = in_mathzone },
		f(function(_, snip) return [[\dot{]] .. snip.captures[1] .. '}' end)),
	s({ trig = '([a-zA-Z])ddot', regTrig = true, wordTrig = false, condition = in_mathzone },
		f(function(_, snip) return [[\ddot{]] .. snip.captures[1] .. '}' end)),
	s({ trig = '([a-zA-Z])tilde', regTrig = true, wordTrig = false, condition = in_mathzone },
		f(function(_, snip) return [[\tilde{]] .. snip.captures[1] .. '}' end)),
	s({ trig = '([a-zA-Z])und', regTrig = true, wordTrig = false, condition = in_mathzone },
		f(function(_, snip) return [[\underline{]] .. snip.captures[1] .. '}' end)),
	s({ trig = '([a-zA-Z])vec', regTrig = true, wordTrig = false, condition = in_mathzone },
		f(function(_, snip) return [[\vec{]] .. snip.captures[1] .. '}' end)),

	-- Subscripts on decorated letters: \hat{x}2 → \hat{x}_{2}
	s({ trig = '\\hat{([A-Za-z])}(%d)', regTrig = true, wordTrig = false, condition = in_mathzone },
		f(function(_, snip) return [[\hat{]] .. snip.captures[1] .. '}_{' .. snip.captures[2] .. '}' end)),
	s({ trig = '\\vec{([A-Za-z])}(%d)', regTrig = true, wordTrig = false, condition = in_mathzone },
		f(function(_, snip) return [[\vec{]] .. snip.captures[1] .. '}_{' .. snip.captures[2] .. '}' end)),
	s({ trig = '\\mathbf{([A-Za-z])}(%d)', regTrig = true, wordTrig = false, condition = in_mathzone },
		f(function(_, snip) return [[\mathbf{]] .. snip.captures[1] .. '}_{' .. snip.captures[2] .. '}' end)),
}

return regular, auto

