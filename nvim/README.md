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
    │   ├── init.lua                  # Core orchestrator (options → keymaps → libs)
    │   ├── keymaps.lua               # Home-row navigation, buffer, window keymaps
    │   ├── libs.lua                  # Foundational library injection (lazydev)
    │   ├── lint.lua                  # Async CLI linter → vim.diagnostic bridge
    │   ├── options.lua               # Editor options, mise PATH injection
    │   └── utils.lua                 # soft_notify, mise_shim, log-to-file
    └── plugins/
        ├── init.lua                  # Master boot orchestrator (context-aware phases)
        ├── core/
        │   ├── mini.lua              # TIER 0: mini.icons (deferred) + mini.tabline
        │   └── snacks.lua            # snacks.nvim: notifier, picker, terminal, ui_select
        ├── dap/
        │   ├── debug.lua             # DAP config + PlatformIO hardware debugging
        │   ├── init.lua              # DAP domain orchestrator
        │   ├── nvim-dap-virtual-text.lua
        │   └── persistent-breakpoint.lua
        ├── editing/
        │   ├── inc-rename.lua        # JIT LSP rename (<leader>rn)
        │   ├── indent.lua            # Auto indentation detection on BufRead
        │   ├── init.lua              # Editing domain orchestrator
        │   ├── mini-editing.lua      # ai, move, surround, indentscope, pairs, hipatterns
        │   └── refactoring.lua       # JIT AST refactoring (extract, inline)
        ├── lsp/
        │   ├── init.lua              # LSP domain orchestrator (strict order: blink → lsp)
        │   ├── blink.lua             # blink.cmp completion + capability broadcast
        │   └── native-lsp.lua        # vim.lsp.config servers + LSP keymaps
        ├── navigation/
        │   ├── history.lua           # mini.visits recent file history
        │   ├── mini-files.lua        # mini.files explorer + split navigation
        │   └── smart-splits.lua      # Neovim ↔ Zellij pane navigation/resize
        ├── notetaking/
        │   └── obsidian.lua          # obsidian-nvim/obsidian.nvim fork, snacks.picker, callback-based keymaps
        ├── searching/
        │   ├── aerial.lua            # JIT structural symbol navigation
        │   ├── init.lua              # Searching domain orchestrator
        │   └── snacks-picker.lua     # snacks.picker keymaps (ff, fd, sg, sw, sh, sk…)
        ├── ui/
        │   ├── init.lua              # UI domain orchestrator (sync → deferred pipeline)
        │   ├── mini-clue.lua         # Key hint popup (VimEnter deferred)
        │   ├── mini-colors.lua       # mini.base16 with Catppuccin Mocha palette
        │   ├── mini-starter.lua      # Dashboard (argc==0 guard, snacks.picker actions)
        │   ├── mini-statusline.lua   # Statusline + mise version telemetry
        │   ├── quotes.lua            # Async quote fetcher (curl → stdpath cache)
        │   ├── render-markdown.lua   # JIT markdown renderer (FileType sandbox)
        │   ├── treesitter.lua        # Treesitter + textobjects (MiniDeps.later)
        │   └── trouble.lua           # JIT diagnostic aggregator
        ├── version_control/
        │   ├── init.lua              # Git domain orchestrator
        │   └── mini-diff.lua         # mini.diff sign column + mini.bracketed hunks
        └── workflow/
            ├── init.lua              # Workflow domain orchestrator
            ├── overseer.lua          # JIT task runner (Makefile/cargo auto-detect)
            ├── persistence.lua       # Automatic session save/restore
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
| `echasnovski/mini.nvim` | Icons, tabline, statusline, starter, diff, files, ai, surround, move, pairs, indentscope, hipatterns, visits, bracketed, clue |
| `folke/snacks.nvim` | Notifier, fuzzy picker (replaces telescope), floating terminal, ui_select |
| `echasnovski/mini.base16` (bundled) | Colorscheme (Catppuccin Mocha palette, part of mini.nvim) |
| `saghen/blink.cmp` | Completion engine |
| `neovim/nvim-lspconfig` | LSP server stub registry |
| `nvim-treesitter/nvim-treesitter` | Parsing + syntax |
| `nvim-treesitter/nvim-treesitter-textobjects` | Text objects (functions, classes, params) |
| `MeanderingProgrammer/render-markdown.nvim` | Markdown visual rendering |
| `stevearc/aerial.nvim` | Symbol sidebar + jump (JIT) |
| `stevearc/overseer.nvim` | Task runner (JIT) |
| `folke/trouble.nvim` | Diagnostic aggregator (JIT) |
| `mini.sessions` (bundled) | Session management (autowrite, picker restore) |
| `mrjones2014/smart-splits.nvim` | Neovim ↔ Zellij navigation |
| `obsidian-nvim/obsidian.nvim` | Notetaking (JIT on markdown, snacks.picker) |
| `chomosuke/typst-preview.nvim` | Typst live preview |
| `mfussenegger/nvim-dap` | Debugger |
| `folke/lazydev.nvim` | Lua API intelligence |
| `ThePrimeagen/vim-be-good` | Motion training (ghost command) |

---

## Keymap Registry

### Core
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader><space>` | Clear search highlights |
| t | `<Esc><Esc>` | Exit terminal mode |
| n | `H` / `L` | Previous / Next buffer |
| n | `<leader>bd` | Buffer delete |
| n | `<leader>wv` | Window: Vertical split |
| n | `<leader>ws` | Window: Horizontal split |
| n | `<leader>wq` | Window: Quit current |
| n | `<leader>wo` | Window: Only (close others) |
| n | `<leader>w=` | Window: Equalize sizes |
| n | `<leader>wx` | Window: Swap next |
| n, t | `<C-h/j/k/l>` | Smart pane move (Neovim ↔ Zellij) |
| n, t | `<M-h/j/k/l>` | Smart pane resize |

### Search (snacks.picker)
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>ff` | Find files |
| n | `<leader>sg` | Live grep |
| n | `<leader>sw` | Grep word under cursor |
| n | `<leader>sd` | Search diagnostics |
| n | `<leader>sr` | Resume last search |
| n | `<leader>sh` | Search help |
| n | `<leader>sk` | Search keymaps |
| n | `<leader>sn` | Search Neovim config files |
| n | `<leader>fd` | Find directory (Zoxide) |
| n | `<leader><leader>` | Active buffers |

### LSP
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `gd` | Go to definition |
| n | `gr` | References |
| n | `<leader>ci` | Implementations |
| n | `<leader>ct` | Type definitions |
| n | `<leader>co` | Document symbols |
| n | `<leader>cn` | Rename (native LSP) |
| n | `<leader>rn` | Rename symbol (JIT inc-rename) |
| n, x | `<leader>ca` | Code actions |
| n | `<leader>cc` | Go to declaration |
| n, v | `<leader>cf` | Format buffer |
| n | `<leader>ch` | Toggle inlay hints |

### Git
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>gg` | Lazygit TUI |
| n | `]h` / `[h` | Next / Prev git hunk |
| n | `<leader>hs` | Stage hunk |
| n | `<leader>hr` | Reset hunk |

### View / Navigation
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>va` | Toggle Aerial symbol sidebar |
| n | `<leader>vj` | Jump to symbol (Aerial nav) |
| n | `<leader>vJ` | jless JSON viewer |
| n | `<leader>xx` | Workspace diagnostics (Trouble) |
| n | `<leader>xd` | Document diagnostics (Trouble) |
| n | `<leader>xq` | Quickfix list (Trouble) |
| n | `<leader>xl` | Location list (Trouble) |

### Editing
| Mode | Keybind | Description |
|------|---------|-------------|
| v, V | `<M-h/j/k/l>` | Move highlighted block |
| n | `gz[a/d/r/f/h/n]` | Surround manipulation |
| n, x | `<leader>rr` | Refactor: Select (UI) |
| x | `<leader>re` | Refactor: Extract variable |
| x | `<leader>rf` | Refactor: Extract function |
| n, x | `<leader>ri` | Refactor: Inline variable |

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

### Typst
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>typ` | Typst: Start preview |
| n | `<leader>tyc` | Typst: Close preview |
| n | `<leader>tys` | Typst: Sync cursor |

### DAP
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>db` | Toggle persistent breakpoint |
| n | `<leader>dc` | Start / Continue |
| n | `<leader>du` | Toggle DAP UI |
| n | `<leader>dr` | Toggle DAP REPL |

### Notes (Obsidian — JIT on markdown)
| Mode | Keybind | Description |
|------|---------|-------------|
| n | `<leader>nq` | Quick switch |
| n | `<leader>ns` | Search notes |
| n | `<leader>nn` | New note |
| n | `<leader>nf` | Follow link in tab (buffer-local) |
| n | `<leader>nv` | Follow link vsplit (buffer-local) |
| n | `<leader>nh` | Follow link hsplit (buffer-local) |
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
| n | `<leader>cx` | Code: Continuous watch (watchexec) |
| n | `<leader>cr` | Code: Run interactive |
| n | `<leader>vq` | JQ live scratchpad |
| n | `<leader>sR` | Search & replace (sd) |
| n | `<leader>vx` | XH HTTP client |
| n | `<leader>ut` | Tool check (mise audit) |
| n | `<leader>tl` | Toggle diagnostic virtual text |
| n | `<leader>tu` | Toggle diagnostic underlines |
| n | `<leader>ct` | Run typos checker |
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

**Language Servers:** `pyright`, `ruff`, `rust-analyzer`, `gopls`, `zls`, `clangd`, `lua-language-server`, `marksman`, `taplo`, `bash-language-server`, `tinymist`

**Formatters / Linters:** `stylua`, `oxfmt`, `markdownlint-cli2`, `shellcheck`

**Utilities:** `rg`, `fd`, `make`, `gcc`, `lazygit`, `btm`, `dlv`, `watchexec`, `uv`, `go`, `zig`, `zellij`, `gojq`, `sd`, `xh`, `bat`, `zoxide`, `cargo`, `curl`, `spotify_player`, `podman-tui`, `aider`, `pio`, `typos`

