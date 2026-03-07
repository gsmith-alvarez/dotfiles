# Ground Truth Neovim Configuration

A lightweight, portable, and stable Neovim configuration built on three pillars:

1. **Lightweight** — Fast startup via deferred loading and no Mason/lazy.nvim. Tooling managed by `mise`.
2. **Portable** — The entire config can be dropped onto a new machine and work immediately. Binaries resolved via `mise` shims.
3. **Stable** — Circuit-breaker pattern throughout. Every plugin load is wrapped in `pcall`. Failures notify without crashing.

---

## Architecture Map

```
nvim/
├── init.lua                          # Phase 0: loader, built-in disables, safe_require boot
└── lua/
    ├── nvim_config/
    │   └── health.lua                # :checkhealth nvim_config (plugins, LSP binaries, tools)
    ├── autocmd/
    │   ├── basic.lua                 # Yank highlight, auto-resize, auto-mkdir
    │   ├── external.lua              # Big-file protection, archive viewer (ouch)
    │   ├── init.lua                  # Autocmd orchestrator + hot-reload on save
    │   └── jit.lua                   # JIT loader for Obsidian (FileType markdown)
    ├── commands/
    │   ├── auditing.lua              # :ToolCheck, :Redir, :NvimHealth
    │   ├── building.lua              # :Watch, :Run (Zellij pane handoff)
    │   ├── diagnostics.lua           # Virtual text / underline toggles
    │   ├── init.lua                  # Command orchestrator
    │   ├── mux.lua                   # Zellij RPC layout control
    │   └── utilities.lua             # JQ scratchpad, SD replace, XH HTTP client
    ├── core/
    │   ├── deps.lua                  # mini.deps bootstrap + MiniDeps global
    │   ├── format.lua                # Native BufWritePre formatter (vim.system)
    │   ├── icons.lua                 # Central icon registry (diagnostics, git, kinds, dap)
    │   ├── init.lua                  # Core orchestrator (options → keymaps → libs)
    │   ├── keymaps.lua               # Home-row navigation, buffer, window keymaps
    │   ├── plugin-keymaps.lua        # Central registry for all global plugin keymaps
    │   ├── libs.lua                  # Foundational library injection (lazydev)
    │   ├── lint.lua                  # Async CLI linter → vim.diagnostic bridge
    │   ├── options.lua               # Editor options, mise PATH injection
    │   ├── utils.lua                 # soft_notify, mise_shim, log-to-file
    │   └── vscode.lua                # VSCode-Neovim integration layer (loaded only in VSCode)
    └── plugins/
        ├── init.lua                  # Master boot orchestrator (context-aware phases)
        ├── core/
        │   ├── mini.lua              # TIER 0: mini.icons (deferred) + mini.tabline
        │   └── snacks.lua            # snacks.nvim: notifier, picker, terminal, ui_select, LSP progress
        ├── dap/
        │   ├── debug.lua             # DAP config + PlatformIO hardware debugging
        │   ├── init.lua              # DAP domain orchestrator
        │   ├── nvim-dap-virtual-text.lua
        │   └── persistent-breakpoint.lua
        ├── editing/
        │   ├── inc-rename.lua        # JIT LSP rename (<leader>rn)
        │   ├── indent.lua            # Auto indentation detection on BufRead
        │   ├── init.lua              # Editing domain orchestrator
        │   ├── mini-editing.lua      # ai, move, surround, comment, indentscope, pairs, hipatterns, TabOut, rainbow-delimiters
        │   ├── refactoring.lua       # JIT AST refactoring (extract, inline)
        │   └── todo-comments.lua     # TODO/FIXME/HACK highlights + Trouble/quickfix integration
        ├── lsp/
        │   ├── init.lua              # LSP domain orchestrator (strict order: blink → lsp)
        │   ├── blink.lua             # blink.cmp completion + capability broadcast
        │   └── native-lsp.lua        # vim.lsp.config servers + LSP keymaps
        ├── navigation/
        │   ├── history.lua           # mini.visits recent file history
        │   ├── mini-files.lua        # mini.files explorer + split navigation
        │   └── smart-splits.lua      # Neovim ↔ Zellij pane navigation/resize
        ├── notetaking/
        │   └── obsidian.lua          # obsidian-nvim/obsidian.nvim, snacks.picker, LSP-based link follow (gf/<leader>nf/nv/nh)
        ├── searching/
        │   ├── aerial.lua            # JIT structural symbol navigation
        │   ├── init.lua              # Searching domain orchestrator
        │   └── snacks-picker.lua     # snacks.picker keymaps (ff, fd, sg, sw, sh, sk…)
        ├── ui/
        │   ├── init.lua              # UI domain orchestrator (sync → deferred pipeline)
        │   ├── mini-clue.lua         # Key hint popup (VimEnter deferred)
        │   ├── mini-colors.lua       # mini.base16 with Catppuccin Mocha palette
        │   ├── mini-starter.lua      # Dashboard (argc==0 guard, snacks.picker actions)
        │   ├── mini-statusline.lua   # Statusline: mode, git branch+diff counts (+n ~n -n), showcmd, LSP, mise version
        │   ├── quotes.lua            # Async quote fetcher (curl → stdpath cache)
        │   ├── render-markdown.lua   # JIT markdown renderer (FileType sandbox)
        │   ├── treesitter.lua        # Treesitter + textobjects (MiniDeps.later)
        │   └── trouble.lua           # JIT diagnostic aggregator
        ├── version_control/
        │   ├── init.lua              # Git domain orchestrator
        │   └── mini-diff.lua         # mini.git (branch/statusline) + mini.diff sign column + mini.bracketed hunks
        └── workflow/
            ├── init.lua              # Workflow domain orchestrator
            ├── overseer.lua          # JIT task runner (Makefile/cargo auto-detect)
            ├── persistence.lua       # Automatic session save/restore
            ├── test-runner.lua       # Language-aware test dispatch (Rust/Zig/Python/C/C++)
            ├── toggleterm.lua        # snacks.terminal TUI factory (lazygit, aider…)
            ├── typst-preview.lua     # Typst live preview via tinymist
            └── vim-be-good.lua       # Ghost command motion trainer
```

---

## Design Patterns

### Circuit Breaker
Every domain orchestrator wraps each module load in `pcall`. A failure in one plugin never cascades. Errors route to `soft_notify` at `ERROR` level (popup) while debug noise stays at `DEBUG` (silent, visible in `:messages`).

### Notification Philosophy
| Level | Behaviour | Used for |
|-------|-----------|----------|
| `DEBUG` | Silent (history only) | Background events: hot-reload, file watching, archive open |
| `INFO` | Popup | Direct user-action results |
| `WARN` | Popup | Actionable issues (missing binary, big file mode) |
| `ERROR` | Popup | Plugin/boot failures |

### Context-Aware Boot
`plugins/init.lua` branches on startup context:
- **File opened** (`argc > 0`) — synchronous critical path: colors → UI → searching → LSP → DAP
- **Dashboard** (`argc == 0`, UI attached) — UI + searching now, LSP deferred to `MiniDeps.later`
- **Headless** — minimal lspconfig install only

### mise Integration
No Mason. All language servers, formatters, and tools are managed by `mise`. `core.utils.mise_shim(bin)` resolves binaries from `~/.local/share/mise/shims/` with `vim.fn.exepath` fallback.

---

## Plugin Inventory

| Plugin | Purpose |
|--------|---------|
| `echasnovski/mini.nvim` | ai, bracketed, clue, comment, deps, diff, files, git, hipatterns, icons, indentscope, move, pairs, sessions, starter, statusline, surround, tabline, visits |
| `folke/snacks.nvim` | Notifier, fuzzy picker (replaces telescope), floating terminal, ui_select, LSP progress spinner, smooth scroll |
| `echasnovski/mini.base16` (bundled) | Colorscheme (Catppuccin Mocha palette, part of mini.nvim) |
| `saghen/blink.cmp` | Completion engine (LSP, path, snippets, lazydev) — pinned to v1.9.1 |
| `rafamadriz/friendly-snippets` | Community VSCode-format snippet collection |
| `neovim/nvim-lspconfig` | LSP server stub registry |
| `nvim-lua/plenary.nvim` | Async utility library (required by obsidian.nvim) |
| `nvim-treesitter/nvim-treesitter` | Parsing + syntax |
| `nvim-treesitter/nvim-treesitter-textobjects` | Text objects (functions, classes, params) |
| `nvim-treesitter/nvim-treesitter-context` | Pins current scope/function header at viewport top |
| `HiPhish/rainbow-delimiters.nvim` | Bracket/delimiter colorization by nesting level (treesitter-based) |
| `MeanderingProgrammer/render-markdown.nvim` | Markdown visual rendering |
| `stevearc/aerial.nvim` | Symbol sidebar + jump (JIT) |
| `stevearc/overseer.nvim` | Task runner (JIT) |
| `folke/trouble.nvim` | Diagnostic aggregator (JIT) |
| `folke/todo-comments.nvim` | TODO/FIXME/HACK/NOTE highlights + Trouble/quickfix integration |
| `mrjones2014/smart-splits.nvim` | Neovim ↔ Zellij navigation |
| `obsidian-nvim/obsidian.nvim` | Notetaking (deferred, snacks.picker, LSP-based link following) |
| `chomosuke/typst-preview.nvim` | Typst live preview |
| `mfussenegger/nvim-dap` | Debugger |
| `rcarriga/nvim-dap-ui` | DAP UI layout |
| `theHamsta/nvim-dap-virtual-text` | Inline variable values during debug |
| `Weissle/persistent-breakpoints.nvim` | Breakpoint persistence across sessions |
| `nvim-neotest/nvim-nio` | Async I/O library (required by nvim-dap-ui) |
| `smjonas/inc-rename.nvim` | Incremental LSP rename (JIT) |
| `ThePrimeagen/refactoring.nvim` | AST-based refactoring (JIT) |
| `NMAC427/guess-indent.nvim` | Auto indentation detection |
| `folke/lazydev.nvim` | Lua API intelligence |
| `ThePrimeagen/vim-be-good` | Motion training (ghost command) |

---

## Keymap Registry

### Core
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<Esc>` | Clear search highlights |
| n/i/x/s | `<C-s>` | Save file |
| t | `<Esc><Esc>` | Exit terminal mode |
| n | `H` / `L` | Previous / Next buffer |
| n | `<leader>bb` / `` <leader>` `` | Switch to alternate buffer |
| n | `<leader>bd` | Buffer delete (preserves splits) |
| n | `<leader>bo` | Delete all other buffers |
| n | `<leader>bD` | Delete buffer + close window |
| n | `<leader>fn` | New empty file |
| n | `<leader>qq` | Quit all |
| n | `<leader>K` | Keywordprg (man/help) |
| n | `<leader>wv` / `<leader>\|` | Window: Vertical split |
| n | `<leader>ws` / `<leader>-` | Window: Horizontal split |
| n | `<leader>wq` | Window: Quit current |
| n | `<leader>wo` | Window: Only (close others) |
| n | `<leader>w=` | Window: Equalize sizes |
| n | `<leader>wx` | Window: Swap next |
| n, t | `<C-h/j/k/l>` | Smart pane move (Neovim ↔ Zellij) |
| n, t | `<M-h/j/k/l>` | Smart pane resize |
| n/x | `n` / `N` | Next/Prev search result (direction-normalised) |
| x | `<` / `>` | Indent (stay in visual) |
| i | `,` `.` `;` | Undo break-points |
| n/i | `<A-j>` / `<A-k>` | Move current line down / up |
| n | `[q` / `]q` | Prev / Next quickfix item |
| n | `<leader>ui` | Inspect highlight under cursor |
| n | `<leader>uI` | Inspect treesitter tree |

### Search (snacks.picker)
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>ff` | Find files |
| n | `<leader>fs` | Find: Starter (open dashboard) |
| n | `<leader>fe` | File explorer (root dir) |
| n | `<leader>fr` | Recent files |
| n | `<leader>fc` | Recent files (cwd) |
| n | `<leader>fd` | Find directory (Zoxide) |
| n | `<leader>sg` | Grep project |
| n | `<leader>sw` | Grep word under cursor |
| n | `<leader>sd` | Search diagnostics |
| n | `<leader>sr` | Resume last search |
| n | `<leader>sh` | Search help |
| n | `<leader>sk` | Search keymaps |
| n | `<leader>sn` | Search Neovim config files |
| n | `<leader>su` | Search undo history |
| n | `<leader>sN` | Search notification history |
| n | `<leader>sR` | Find & replace (sd) |
| n | `<leader><leader>` | Active buffers |

### LSP
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `gd` | Go to definition |
| n | `gr` | References |
| n | `K` | Hover documentation (rounded border, Neovim native) |
| n | `<leader>ci` | Implementations |
| n | `<leader>ct` | Type definitions |
| n | `<leader>co` | Document symbols |
| n | `<leader>cn` | Rename (native LSP) |
| n | `<leader>rn` | Rename symbol (JIT inc-rename) |
| n, x | `<leader>ca` | Code actions |
| n | `<leader>cc` | Go to declaration |
| n, v | `<leader>cf` | Format buffer |
| n | `<leader>ch` | Toggle inlay hints (auto-enabled on attach) |

### Diagnostics
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>cd` | Line diagnostics float |
| n | `]d` / `[d` | Next / Prev diagnostic |
| n | `]e` / `[e` | Next / Prev error |
| n | `]w` / `[w` | Next / Prev warning |
| n | `<leader>xx` | Workspace diagnostics (Trouble) |
| n | `<leader>xd` | Document diagnostics (Trouble) |
| n | `<leader>xq` | Quickfix list (Trouble) |
| n | `<leader>xl` | Location list (Trouble) |
| n | `<leader>ul` | Toggle diagnostic virtual text |
| n | `<leader>uu` | Toggle diagnostic underlines |
| n | `<leader>q` | Diagnostic quickfix (Trouble or native) |

### Git
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>gg` | Lazygit TUI |
| n | `<leader>gl` | Git log (commits) |
| n | `<leader>gf` | Current file history |
| n | `<leader>gS` | Git status (changed files) |
| n | `<leader>gb` | Git branches |
| n, x | `<leader>gB` | Git browse (open in browser) |
| n, x | `<leader>gY` | Git browse (copy remote URL) |
| n | `]c` / `[c` | Next / Prev git change |
| n | `<leader>gs` | Stage hunk |
| n | `<leader>gu` | Undo hunk |
| n | `<leader>gD` | Toggle diff overlay |
| n | `<leader>gq` | Export hunks to quickfix |

### View / Navigation
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>va` | Toggle Aerial symbol sidebar |
| n | `<leader>vj` | Jump to symbol (Aerial nav) |
| n | `<leader>vJ` | jless JSON viewer |
| n | `<leader>vq` | JQ live scratchpad |
| n | `<leader>vx` | XH HTTP client |
| n | `-` | Open file explorer (current file's dir) |
| n | `<leader>fe` | Open file explorer (project root) |

### Editing
| Mode | Keybind | Description |
|------|---------|-------------|
| i | `<Tab>` | TabOut: jump past next closing bracket/quote (or insert tab) |
| n | `gc` | Comment (motion) |
| n | `gcc` | Comment current line |
| v | `gc` | Comment selection |
| n | `gco` | Add comment line below |
| n | `gcO` | Add comment line above |
| v, V | `<M-h/j/k/l>` | Move highlighted block |
| n | `gz[a/d/r/f/h/n]` | Surround manipulation |
| n, x | `<leader>rr` | Refactor: Select (UI) |
| x | `<leader>re` | Refactor: Extract variable |
| x | `<leader>rf` | Refactor: Extract function |
| x | `<leader>rF` | Refactor: Extract function to file |
| n, x | `<leader>ri` | Refactor: Inline variable |

### TODO Comments
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `]t` / `[t` | Next / Prev TODO comment |
| n | `<leader>xt` | TODOs in Trouble |
| n | `<leader>xT` | TODOs in quickfix |

### Execute (`<leader>e`)
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>er` | Run code (interactive Zellij split) |
| n | `<leader>ec` | Continuous watch + run (watchexec) |
| n | `<leader>ew` | Manual watchexec trigger |

### Terminal / TUI (snacks.terminal)
| Mode | Keybind | Description |
|------|---------|-------------|
| n, t | `<C-\>` | Toggle terminal |
| n | `<leader>ta` | Aider AI chat |
| n | `<leader>tp` | Process monitor (btm) |
| n | `<leader>ts` | Spotify player |
| n | `<leader>ti` | Container infrastructure (podman-tui) |

### Workflow
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>ot` | Overseer: Toggle task list |
| n | `<leader>or` | Overseer: Run template |
| n | `<leader>oi` | Overseer: Task info |
| n | `<leader>oa` | Overseer: Task action menu |
| n | `<leader>qs` | Session: Restore current dir |
| n | `<leader>ql` | Session: Picker (select session) |
| n | `<leader>qw` | Session: Save manually |
| n | `<leader>qd` | Session: Don't save |

### Test Runner (Rust / Zig / Python / C / C++)
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>Tr` | Run all tests (project root) |
| n | `<leader>Tf` | Run tests for current file |
| n | `<leader>Tn` | Run nearest test under cursor |

### Typst (buffer-local, `filetype=typst`)
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>typ` | Typst: Start preview |
| n | `<leader>tyc` | Typst: Close preview |
| n | `<leader>tys` | Typst: Sync cursor |
| n | `<leader>pv` | Typst: Watch (terminal) |

### DAP
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<F5>` | Start / Continue |
| n | `<leader>db` | Toggle persistent breakpoint |
| n | `<leader>dB` | Clear all breakpoints |
| n | `<leader>dc` | Continue |
| n | `<leader>do` | Step over |
| n | `<leader>di` | Step into |
| n | `<leader>du` | Toggle DAP UI |
| n | `<leader>dr` | Toggle DAP REPL |

### Notes (Obsidian — JIT on markdown)
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>nq` | Quick switch |
| n | `<leader>ns` | Search notes |
| n | `<leader>nn` | New note |
| n | `gf` | Follow link under cursor (current window) |
| n | `<leader>nf` | Follow link in new tab |
| n | `<leader>nv` | Follow link vsplit |
| n | `<leader>nh` | Follow link hsplit |
| n | `<leader>nT` | Search tags (buffer-local) |
| n | `<leader>no` | Open in Obsidian GUI (buffer-local) |
| n | `<leader>nc` | Table of contents (buffer-local) |
| n | `<leader>nt` | Insert template (buffer-local) |
| n | `<leader>ne` | Extract to note (buffer-local) |
| n | `<leader>nl` | Link existing note (buffer-local) |
| n | `<leader>nN` | Link new note (buffer-local) |
| n | `<leader>np` | Paste image (buffer-local) |

### Utilities
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>ur` | Restart LSP |
| n | `<leader>ut` | Tool check (mise audit) |
| n | `<leader>uT` | Run Typos checker |
| n | `<leader>ul` | Toggle diagnostic virtual text |
| n | `<leader>uu` | Toggle diagnostic underlines |
| n | `<leader>vq` | JQ live scratchpad |
| n | `<leader>vx` | XH HTTP client |
| n | `<leader>vJ` | jless JSON viewer |
| n | `<leader>sR` | Find & replace (sd) |
| n | `<leader>yp` | Yank absolute path |
| n | `<leader>yr` | Yank relative path |
| n | `<leader>zv` | Zellij: Vertical split |
| n | `<leader>zs` | Zellij: Horizontal split |
| n | `<leader>zf` | Zellij: Floating pane |
| n | `<leader>zq` | Zellij: Close pane |

### PlatformIO
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>pb` | Build project |
| n | `<leader>pu` | Upload firmware |
| n | `<leader>pm` | Serial monitor |
| n | `<leader>pc` | Update compilation database |

---

## External Binaries (via `mise`)

**Language Servers:** `pyright`, `ruff`, `rust-analyzer`, `gopls`, `zls`, `clangd`, `ts_ls`, `lua-language-server`, `tinymist`, `taplo`, `bash-language-server`, `vscode-json-languageserver`, `yaml-language-server`, `markdown-oxide`

**Formatters / Linters:** `stylua`, `oxfmt`, `ruff` (python), `fish_indent`, `markdownlint-cli2`, `shellcheck`

**Utilities:** `rg`, `fd`, `make`, `gcc`, `lazygit`, `btm`, `dlv`, `watchexec`, `uv`, `go`, `zig`, `zellij`, `gojq`, `sd`, `xh`, `bat`, `zoxide`, `cargo`, `curl`, `spotify_player`, `podman-tui`, `aider`, `pio`, `typos`, `openocd`, `lldb-dap`

