# Neovim Workflow Cheatsheet

A quick reference for the keybindings and commands in this configuration.

For the full keymap list use `<leader>sk` (search keymaps via snacks.picker).

For benchmarking run `PROFILE=1 nvim` (profiler keys are dev-only, not bound globally).

---

## 1. Core Vim Muscle Memory (The "Native" Tier)

| Key Chord | Mode | Action / Command | Source |
| :--- | :---: | :--- | :--- |
| `ciw` / `caw` | N | Change inner word / change a word | Native |
| `dap` / `yap` | N | Delete / yank a paragraph | Native |
| `%` | N | Jump to matching bracket/parenthesis | Native |
| `qq` / `@q` | N | Record / Play macro (register q) | Native |
| `m[a-z]` / `'[a-z]` | N | Set / Jump to local mark | Native |
| `0` / `^` / `$` | N | Start of line / first char / end of line | Native |
| `gg` / `G` | N | Top / Bottom of file | Native |
| `*` / `#` | N | Search forward / backward for word under cursor | Native |
| `C` / `D` | N | Change / Delete to end of line | Native |
| `j` / `k` | N/X | Smart visual line movement (`gj`/`gk`) | Core |
| `n` / `N` | N | Next/Prev result (always forward/backward) | Core |
| `<` / `>` | X | Indent left/right (stay in visual) | Core |
| `,` `.` `;` | I | Insert undo break-point | Core |
| `<A-j>` / `<A-k>` | N/I | Move current line down / up | Core |
| `[q` / `]q` | N | Prev / Next quickfix item | Core |
| `<leader>K` | N | Keywordprg (man/help) | Core |
| `<leader>ui` | N | Inspect highlight under cursor | Core |
| `<leader>uI` | N | Inspect treesitter tree | Core |

---

## 2. Window, Panel & Buffer Management

| Key Chord | Mode | Action | Plugin/Source |
| :--- | :---: | :--- | :--- |
| `<C-w>v` / `<leader>\|` | N | Split window vertically | Native / Core |
| `<C-w>s` / `<leader>-` | N | Split window horizontally | Native / Core |
| `<C-w>q` / `<leader>wq` | N | Close current window | Native / Core |
| `<C-w>o` / `<leader>wo` | N | Close all other windows | Native / Core |
| `<C-w>=` / `<leader>w=` | N | Equalize all window sizes | Native / Core |
| `<C-h/j/k/l>` | N/T | Move focus to pane (Neovim ↔ Zellij) | `smart-splits` |
| `<M-h/j/k/l>` | N/T | Resize pane | `smart-splits` |
| `H` / `L` | N | Previous / Next buffer | Core |
| `<leader>bb` / `` <leader>` `` | N | Switch to alternate buffer | Core |
| `<leader>bd` | N | Delete buffer (preserves splits) | Core |
| `<leader>bo` | N | Delete all other buffers | Core |
| `<leader>bD` | N | Delete buffer + close window | Core |
| `<C-s>` | N/I/X | Save file | Core |
| `<leader>fn` | N | New empty file | Core |
| `<leader>qq` | N | Quit all | Core |
| `[b` / `]b` | N | Go to previous / next buffer | `mini.bracketed` |

---

## 3. Multi-Tiered Navigation

### Tier 1: Global (snacks.picker)

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>fd` | N | Find directory (Zoxide) | `snacks.picker` |
| `<leader>ff` | N | Find files | `snacks.picker` |
| `<leader>fs` | N | Find: Starter (open dashboard) | `mini.starter` |
| `<leader>sg` | N | Grep project | `snacks.picker` |
| `<leader>sw` | N | Grep word under cursor | `snacks.picker` |
| `<leader>sr` | N | Resume last search | `snacks.picker` |
| `<leader>sd` | N | Search diagnostics | `snacks.picker` |
| `<leader>sh` | N | Search help | `snacks.picker` |
| `<leader>sk` | N | Search keymaps | `snacks.picker` |
| `<leader>sn` | N | Search Neovim config files | `snacks.picker` |
| `<leader>su` | N | Search undo history | `snacks.picker` |
| `<leader>sN` | N | Search notification history | `snacks.picker` |
| `<leader><leader>` | N | Active buffers | `snacks.picker` |
| `<leader>fr` | N | Recent files | `snacks.picker` |
| `<leader>fc` | N | Recent files (cwd) | `snacks.picker` |

### Tier 2: File Browser

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `-` | N | Open current file's directory | `mini.files` |
| `<leader>fe` | N | Open file explorer (project root) | `mini.files` |
| `g.` | N (mini.files) | Toggle hidden files | `mini.files` |
| `<C-s>` | N (mini.files) | Open in horizontal split | `mini.files` |
| `<C-v>` | N (mini.files) | Open in vertical split | `mini.files` |

### Tier 3: Symbol Navigation (Aerial — JIT)

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>va` | N | Toggle symbol sidebar | `aerial.nvim` |
| `<leader>vj` | N | Jump to symbol (fuzzy nav) | `aerial.nvim` |

---

## 4. Editing, Refactoring & Notetaking

### Comments (mini.comment)

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `gc` | N | Comment (motion, e.g. `gcip`) | `mini.comment` |
| `gcc` | N | Comment current line | `mini.comment` |
| `gc` | V | Comment selection | `mini.comment` |
| `gco` | N | Add commented line below | `mini.comment` |
| `gcO` | N | Add commented line above | `mini.comment` |

### Text Objects (mini.ai) & Surround (mini.surround)

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `v a )` | N | Select around parentheses | `mini.ai` |
| `y i n q` | N | Yank inside next quote (`n` = next, `l` = last) | `mini.ai` |
| `i f` / `a f` | N | Inside / Around function call | `mini.ai` |
| `i F` / `a F` | N | Inside / Around function definition | `mini.ai` |
| `i c` / `a c` | N | Inside / Around class | `mini.ai` |
| `i a` / `a a` | N | Inside / Around argument (parameter) | `mini.ai` |
| `i b` / `a b` | N | Inside / Around balanced bracket | `mini.ai` |
| `i q` / `a q` | N | Inside / Around quote | `mini.ai` |
| `i i` / `a i` | N | Inside / Around indentation | `mini.ai` |
| `i g` / `a g` | N | Inside / Around entire buffer | `mini.ai` |
| `ga` / `gA` | N/V | Align text / Align with preview | `mini.align` |
| `gS` | N | Split / Join code (toggle) | `mini.splitjoin` |
| `gza` / `gzd` | N | Add / Delete surround | `mini.surround` |
| `gzr` / `gzh` | N | Replace / Highlight surround | `mini.surround` |
| `<M-h/j/k/l>` | V | Move highlighted block | `mini.move` |
| `<Tab>` | I | Jump past next closing bracket/quote (TabOut) | Core |

### Refactoring

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>rn` | N | Rename symbol (JIT) | `inc-rename` |
| `<leader>rr` | N/X | Refactor: Select (UI) | `refactoring.nvim` |
| `<leader>re` | X | Extract variable | `refactoring.nvim` |
| `<leader>rf` | X | Extract function | `refactoring.nvim` |
| `<leader>rF` | X | Extract function to file | `refactoring.nvim` |
| `<leader>ri` | N/X | Inline variable | `refactoring.nvim` |

### TODO Comments

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `]t` / `[t` | N | Next / Prev TODO comment | `todo-comments` |
| `<leader>xt` | N | TODOs in Trouble | `todo-comments` |
| `<leader>xT` | N | TODOs in quickfix | `todo-comments` |

### Notes (Obsidian — buffer-local on markdown in vault)

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>nq` | N | Quick switch | `obsidian.nvim` |
| `<leader>nn` | N | New note | `obsidian.nvim` |
| `<leader>ns` | N | Search notes | `obsidian.nvim` |
| `<leader>na` | N | Smart action (follow link / tag / checkbox / heading fold) | `obsidian.nvim` |
| `<leader>nf` | N | Follow link in new tab | `obsidian.nvim` |
| `<leader>nv` | N | Follow link (vertical split) | `obsidian.nvim` |
| `<leader>nh` | N | Follow link (horizontal split) | `obsidian.nvim` |
| `<leader>nT` | N | Search tags | `obsidian.nvim` |
| `<leader>no` | N | Open in Obsidian GUI | `obsidian.nvim` |
| `<leader>nc` | N | Table of contents | `obsidian.nvim` |
| `<leader>nt` | N | Insert template | `obsidian.nvim` |
| `<leader>ne` | N | Extract selection to note | `obsidian.nvim` |
| `<leader>nl` | N | Link to existing note | `obsidian.nvim` |
| `<leader>nN` | N | Link to new note | `obsidian.nvim` |
| `<leader>np` | N | Paste image attachment | `obsidian.nvim` |

---

## 5. Code Intelligence & Debugging

### LSP

| Key Chord | Mode | Action | Source |
| :--- | :---: | :--- | :--- |
| `gd` | N | Go to definition | `native-lsp` |
| `gr` | N | References | `native-lsp` |
| `K` | N | Hover documentation | `native-lsp` |
| `<leader>ci` | N | Implementations | `native-lsp` |
| `<leader>ct` | N | Type definitions | `native-lsp` |
| `<leader>co` | N | Document symbols | `native-lsp` |
| `<leader>cn` | N | Rename (native LSP) | `native-lsp` |
| `<leader>rn` | N | Rename symbol (JIT inc-rename) | `inc-rename` |
| `<leader>ca` | N/X | Code actions | `native-lsp` |
| `<leader>cc` | N | Go to declaration | `native-lsp` |
| `<leader>cf` | N/V | Format buffer | `core.format` |
| `<leader>ch` | N | Toggle inlay hints (auto-enabled) | `native-lsp` |
| `<leader>ur` | N | Restart LSP | `native-lsp` |

### Diagnostics

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>cd` | N | Line diagnostics float | Core |
| `]d` / `[d` | N | Next / Prev diagnostic | Core |
| `]e` / `[e` | N | Next / Prev error | Core |
| `]w` / `[w` | N | Next / Prev warning | Core |
| `<leader>xx` | N | Workspace diagnostics | `trouble.nvim` |
| `<leader>xd` | N | Document diagnostics | `trouble.nvim` |
| `<leader>xq` | N | Quickfix list | `trouble.nvim` |
| `<leader>xl` | N | Location list | `trouble.nvim` |
| `<leader>xt` | N | TODO list | `todo-comments` |
| `<leader>xT` | N | TODO quickfix | `todo-comments` |
| `<leader>ul` | N | Toggle diagnostic virtual text | Core |
| `<leader>uu` | N | Toggle diagnostic underlines | Core |
| `<leader>q` | N | Diagnostic quickfix (Trouble or native) | Core |

### DAP (Debugger)

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<F5>` | N | Start / Continue | `nvim-dap` |
| `<leader>db` | N | Toggle persistent breakpoint | `nvim-dap` |
| `<leader>dB` | N | Clear all breakpoints | `nvim-dap` |
| `<leader>dc` | N | Continue | `nvim-dap` |
| `<leader>do` | N | Step over | `nvim-dap` |
| `<leader>di` | N | Step into | `nvim-dap` |
| `<leader>du` | N | Toggle DAP UI | `nvim-dap` |
| `<leader>dr` | N | Toggle REPL | `nvim-dap` |

---

## 6. Git

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>gg` | N | Open Lazygit TUI | `snacks.terminal` |
| `<leader>gl` | N | Git log (commits) | `snacks.picker` |
| `<leader>gf` | N | Current file history | `snacks.picker` |
| `<leader>gS` | N | Git status (changed files) | `snacks.picker` |
| `<leader>gb` | N | Git branches | `snacks.picker` |
| `<leader>gB` | N/X | Git browse (open in browser) | `snacks` |
| `<leader>gY` | N/X | Git browse (copy remote URL) | `snacks` |
| `]c` / `[c` | N | Next / Prev git change | `mini.diff` |
| `<leader>gs` | N | Stage hunk | `mini.diff` |
| `<leader>gu` | N | Undo hunk | `mini.diff` |
| `<leader>gD` | N | Toggle diff overlay | `mini.diff` |
| `<leader>gq` | N | Export hunks to quickfix | `mini.diff` |

---

## 7. Execute & Terminal/TUI

### Execute (`<leader>e`)

| Key Chord | Mode | Action |
| :--- | :---: | :--- |
| `<leader>er` | N | Run code (interactive Zellij split) |
| `<leader>ec` | N | Continuous watch + run (watchexec) |
| `<leader>ew` | N | Manual watchexec trigger |

### Terminal / TUI (snacks.terminal)

| Key Chord | Mode | Action |
| :--- | :---: | :--- |
| `<C-\>` | N/T | Toggle terminal |
| `<leader>ta` | N | Aider AI chat |
| `<leader>tp` | N | Process monitor (btm) |
| `<leader>ts` | N | Spotify player |
| `<leader>ti` | N | Container infrastructure (podman-tui) |
| `<leader>typ` | N | Typst: Start preview (filetype=typst) |
| `<leader>tyc` | N | Typst: Close preview (filetype=typst) |
| `<leader>tys` | N | Typst: Sync cursor (filetype=typst) |
| `<leader>pv` | N | Typst: Watch terminal (filetype=typst) |

---

## 8. Test Runner (Rust / Zig / Python / C / C++)

| Key Chord | Mode | Action |
| :--- | :---: | :--- |
| `<leader>Tr` | N | Run all tests (project root) |
| `<leader>Tf` | N | Run tests for current file |
| `<leader>Tn` | N | Run nearest test under cursor |

**Language dispatch:**
- **Rust** → `cargo test` / `cargo test <fn>`
- **Zig** → `zig build test` / `zig test <file>`
- **Python** → `pytest` / `pytest <file>` / `pytest -k <fn>`
- **C/C++** → `ctest` (CMake) or `make test`

---

## 9. User Commands & CLI Integration

### Commands

| Command | Action |
| :--- | :--- |
| `:ToolCheck` | Scan for missing binaries (mise) |
| `:NvimHealth` | Check plugin layer, LSP binaries & active servers |
| `:Watch <cmd>` | Run command on file change (watchexec) |
| `:Jq` | Run jq on current buffer |
| `:Typos` | Project-wide spell check |
| `:Redir <cmd>` | Capture command output to buffer |
| `:MiseTrust` | Trust current project's .mise.toml |
| `:Scratch` | Open ephemeral notepad |
| `:Logs` | View Neovim/LSP logs in new tab |
| `:DiffOrig` | Audit unsaved changes against disk |

### Build / Run

| Key Chord | Mode | Action |
| :--- | :---: | :--- |
| `<leader>er` | N | Run code (interactive Zellij split) |
| `<leader>ec` | N | Continuous watch + run (watchexec) |
| `<leader>ew` | N | Manual watchexec trigger |

### Utilities

| Key Chord | Mode | Action |
| :--- | :---: | :--- |
| `<leader>vq` | N | JQ live scratchpad |
| `<leader>vx` | N | XH HTTP client |
| `<leader>vJ` | N | jless JSON viewer |
| `<leader>sR` | N | Find & replace (sd) |
| `<leader>ur` | N | Restart LSP |
| `<leader>ut` | N | Tool check (mise audit) |
| `<leader>uT` | N | Run Typos checker |
| `<leader>uc` | N | Toggle Copilot auto-trigger |
| `<leader>ul` | N | Toggle diagnostic virtual text |
| `<leader>uu` | N | Toggle diagnostic underlines |
| `<leader>yp` | N | Yank absolute file path |
| `<leader>yr` | N | Yank relative file path |

### Zellij Multiplexer

| Key Chord | Mode | Action |
| :--- | :---: | :--- |
| `<leader>zv` | N | Vertical split |
| `<leader>zs` | N | Horizontal split |
| `<leader>zf` | N | Floating pane |
| `<leader>zq` | N | Close pane |

### PlatformIO

| Key Chord | Mode | Action |
| :--- | :---: | :--- |
| `<leader>pb` | N | Build project |
| `<leader>pu` | N | Upload firmware |
| `<leader>pm` | N | Serial monitor |
| `<leader>pc` | N | Update compilation database |

### Session

| Key Chord | Mode | Action |
| :--- | :---: | :--- |
| `<leader>qs` | N | Restore session (current dir) |
| `<leader>ql` | N | Picker: select & restore session |
| `<leader>qw` | N | Save session manually |
| `<leader>qd` | N | Don't save current session |

