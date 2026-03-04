# Neovim Workflow Cheatsheet

A quick reference for the keybindings and commands in this configuration.

For the full keymap list use `<leader>sk` (search keymaps via snacks.picker).

For benchmarking run `PROFILE=1 nvim`, then `<leader>zp`.

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
| `j` / `k` | N | Smart visual line movement (`gj`/`gk`) | Core |

---

## 2. Window, Panel & Buffer Management

| Key Chord | Mode | Action | Plugin/Source |
| :--- | :---: | :--- | :--- |
| `<C-w>v` | N | Split window vertically | Native |
| `<C-w>s` | N | Split window horizontally | Native |
| `<C-w>q` / `<C-w>c` | N | Close current window/panel | Native |
| `<C-w>o` | N | Close all other windows (maximize current) | Native |
| `<C-w>=` | N | Equalize all window sizes | Native |
| `<C-h/j/k/l>` | N/T | Move focus to Left/Down/Up/Right pane (Neovim ↔ Zellij) | `smart-splits` |
| `<M-h/j/k/l>` | N/T | Resize pane | `smart-splits` |
| `H` / `L` | N | Previous / Next buffer | Core |
| `<leader>bd` | N | Buffer delete | Core |
| `[b` / `]b` | N | Go to previous / next buffer | `mini.bracketed` |

---

## 3. Multi-Tiered Navigation

### Tier 1: Global (snacks.picker)

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>fd` | N | Find directory (Zoxide) | `snacks.picker` |
| `<leader>ff` | N | Find files | `snacks.picker` |
| `<leader>sg` | N | Live grep | `snacks.picker` |
| `<leader>sw` | N | Grep word under cursor | `snacks.picker` |
| `<leader>sr` | N | Resume last search | `snacks.picker` |
| `<leader>sd` | N | Search diagnostics | `snacks.picker` |
| `<leader>sh` | N | Search help | `snacks.picker` |
| `<leader>sk` | N | Search keymaps | `snacks.picker` |
| `<leader>sn` | N | Search Neovim config files | `snacks.picker` |
| `<leader><leader>` | N | Active buffers | `snacks.picker` |

### Tier 2: File Browser

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `-` | N | Open parent directory | `mini.files` |

### Tier 3: Symbol Navigation (Aerial — JIT)

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>va` | N | Toggle symbol sidebar | `aerial.nvim` |
| `<leader>vj` | N | Jump to symbol (fuzzy nav) | `aerial.nvim` |

---

## 4. Editing, Refactoring & Notetaking

### Text Objects & Surround

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `v a )` | N | Select around parentheses | `mini.ai` |
| `y i n q` | N | Yank inside next quote | `mini.ai` |
| `gza` / `gzd` | N | Add / Delete surround | `mini.surround` |
| `gzr` / `gzh` | N | Replace / Highlight surround | `mini.surround` |
| `<M-h/j/k/l>` | V | Move highlighted block | `mini.move` |

### Refactoring

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>rn` | N | Rename symbol (JIT) | `inc-rename` |
| `<leader>rr` | N/X | Refactor: Select (UI) | `refactoring.nvim` |
| `<leader>re` | X | Extract variable | `refactoring.nvim` |
| `<leader>rf` | X | Extract function | `refactoring.nvim` |
| `<leader>ri` | N/X | Inline variable | `refactoring.nvim` |

### Notes (Obsidian — JIT on markdown)

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>nq` | N | Quick switch | `obsidian.nvim` |
| `<leader>nn` | N | New note | `obsidian.nvim` |
| `<leader>ns` | N | Search notes | `obsidian.nvim` |
| `gf` | N | Follow link under cursor | `obsidian.nvim` |

---

## 5. Code Intelligence & Debugging

### LSP

| Key Chord | Mode | Action | Source |
| :--- | :---: | :--- | :--- |
| `gd` | N | Go to definition | `native-lsp` |
| `gr` | N | References | `native-lsp` |
| `<leader>ci` | N | Implementations | `native-lsp` |
| `<leader>ct` | N | Type definitions | `native-lsp` |
| `<leader>co` | N | Document symbols | `native-lsp` |
| `<leader>cn` | N | Rename (native LSP) | `native-lsp` |
| `<leader>rn` | N | Rename symbol (JIT inc-rename) | `inc-rename` |
| `<leader>ca` | N/X | Code actions | `native-lsp` |
| `<leader>cc` | N | Go to declaration | `native-lsp` |
| `<leader>cf` | N/V | Format buffer | `core.format` |
| `<leader>ch` | N | Toggle inlay hints | `native-lsp` |

### Diagnostics & Trouble

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>xx` | N | Workspace diagnostics | `trouble.nvim` |
| `<leader>xd` | N | Document diagnostics | `trouble.nvim` |
| `<leader>xq` | N | Quickfix list | `trouble.nvim` |
| `<leader>xl` | N | Location list | `trouble.nvim` |

### DAP (Debugger)

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>db` | N | Toggle persistent breakpoint | `nvim-dap` |
| `<leader>dc` | N | Start / Continue | `nvim-dap` |
| `<leader>du` | N | Toggle DAP UI | `nvim-dap` |
| `<leader>dr` | N | Toggle REPL | `nvim-dap` |

---

## 6. Git

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>gg` | N | Open Lazygit TUI | `snacks.terminal` |
| `]h` / `[h` | N | Next / Prev git hunk | `mini.diff` |
| `<leader>hs` | N | Stage hunk | `mini.diff` |
| `<leader>hr` | N | Reset hunk | `mini.diff` |

---

## 7. Terminal & TUI (snacks.terminal)

| Key Chord | Mode | Action |
| :--- | :---: | :--- |
| `<C-\>` | N/T | Toggle terminal |
| `<leader>ta` | N | Aider AI chat |
| `<leader>tp` | N | Process monitor (btm) |
| `<leader>ts` | N | Spotify player |
| `<leader>ti` | N | Container infrastructure (podman-tui) |
| `<leader>typ` | N | Typst: Start preview |
| `<leader>tyc` | N | Typst: Close preview |
| `<leader>tys` | N | Typst: Sync cursor |
| `<leader>tl` | N | Toggle diagnostic virtual text |
| `<leader>tu` | N | Toggle diagnostic underlines |

---

## 8. User Commands & CLI Integration

### Commands

| Command | Action |
| :--- | :--- |
| `:ToolCheck` | Scan for missing binaries (mise) |
| `:NvimHealth` | Check plugin layer, LSP binaries & active servers |
| `:Watch <cmd>` | Run command on file change (watchexec) |
| `:Jq` | Run jq on current buffer |
| `:Typos` | Project-wide spell check |
| `:Redir <cmd>` | Capture command output to buffer |

### Build / Run

| Key Chord | Mode | Action |
| :--- | :---: | :--- |
| `<leader>cr` | N | Run code (interactive Zellij split) |
| `<leader>cx` | N | Continuous watch + run (watchexec) |

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

