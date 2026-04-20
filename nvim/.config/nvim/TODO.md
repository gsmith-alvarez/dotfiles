# Neovim Rebuild TODO

Rebuild order follows the clay-dots architecture from bootstrap to everyday workflows.

## 0. Bootstrap
- [x] Recreate `init.lua` as the only startup entrypoint.
- [x] Enable `vim.loader` caching at the top of startup.
- [x] Disable legacy built-ins (`netrw`, archive handlers, gzip, etc.).
- [x] Add `safe_require()` and use it for all non-core module loads.
- [x] Keep startup split into Phase 0, Phase 1, Phase 2, and deferred JIT loads.

## 1. Core Runtime

### `plugin/00-options.lua`
- [x] Rebuild all editor options.
- [x] Set basic UX defaults: numbers, signcolumn, cursorline, split behavior, scrolloff, wrap, conceal, clipboard.
- [x] Set editing defaults: indent, tabstop, shiftwidth, expandtab, smartindent, undo, backup.
- [x] Set search and completion defaults.
- [x] Set diagnostic display defaults.

### `plugin/03-keymaps.lua`
- [x] Rebuild core save, quit, and escape mappings.
- [x] Rebuild buffer navigation and buffer management mappings.
- [x] Rebuild window split, window move, and resize mappings.
- [x] Rebuild search-result movement mappings.
- [x] Rebuild visual indent and line-move mappings.
- [x] Rebuild quickfix navigation mappings.
- [x] Rebuild core utility mappings like file creation and search clear.

### `lua/core/libs.lua`
- [x] Add lazydev or equivalent Lua runtime support.

### `lua/core/icons.lua`
- [x] Centralize diagnostic, git, kind, and DAP icons.
- [x] Use the icon registry everywhere instead of ad hoc strings.

### `plugin/04-plugin-keymaps.lua`
- [x] Create a single registry for global plugin keymaps.
- [x] Group mappings by domain and keep them discoverable.

### `plugin/01-path.lua`
- [x] Sync Neovim with `mise`.
- [x] Confirm PATH resolution for tools used by LSP, formatters, and CLI workflows.
- [x] Add health or validation hooks for missing binaries.

### `plugin/02-pack.lua`
- [x] Keep plugin specs grouped by domain.
- [ ] Keep post-install hooks robust (build tools, copy fallbacks).

## 2. Autocmds
### `plugin/05-autocmds.lua`
- [x] Highlight on yank.
- [x] Auto-resize windows on terminal resize.
- [x] Auto-create parent directories on save.
- [x] Project-aware file renaming (mini.files + snacks.rename).

### `lua/autocmd/external.lua` (optional split from plugin/05-autocmds.lua)
- [x] Add large-file protections.
- [x] Add special-file handling for archive or external viewers.

### `lua/autocmd/jit.lua` (optional split from plugin/05-autocmds.lua)
- [x] Keep expensive filetype logic deferred.

## 3. Plugin Foundation
### `plugin/05-plugins.lua`
- [x] Keep plugin bootstrap list current.
- [x] Keep context-aware loading paths separate.
- [x] Keep all plugin module loads routed through `Config.safe_require`.

### `lua/plugins/core/mini.lua`
- [x] Add `mini.nvim` core pieces used everywhere.
- [x] Implement optimized `now` / `later` deferred loading.

### `lua/plugins/core/snacks.lua`
- [x] Add notifier support.
- [x] Add picker support.
- [x] Add terminal support.
- [x] Add UI toggles (Zen, Zoom, Wrap, etc.).

## 4. UI Layer
### `lua/plugins/ui/mini-colors.lua`
- [x] Load the colorscheme and palette.
- [x] Make the palette the visual base for the entire config.

### `lua/plugins/ui/which-key.lua`
- [x] Add key discovery popups.
- [x] Register the major prefix groups with consistent icons.

### `lua/plugins/ui/snacks-dashboard.lua`
- [ ] Add a startup dashboard.
- [ ] Show recent files, projects, and useful entry actions.

### `lua/plugins/ui/mini-statusline.lua`
- [x] Add a custom statusline.
- [x] Show mode, branch, diff counts, LSP, and environment/version info.

### `lua/plugins/ui/winbar.lua`
- [ ] Add file context breadcrumbs.

### `lua/plugins/ui/trouble.lua`
- [ ] Add diagnostics, references, and quickfix UI.

### `lua/plugins/ui/render-markdown.lua`
- [ ] Add improved markdown rendering.

### `lua/plugins/ui/treesitter.lua`
- [x] Configure Treesitter highlighting with `latex` and `regex` support.
- [x] Configure textobjects and incremental selection.

## 5. Search and Discovery
### `lua/plugins/searching/snacks-picker.lua`
- [x] Add file search.
- [x] Add recent files search.
- [x] Add buffer search.
- [x] Add config search.
- [x] Add project search and project switching (zoxide).
- [x] Add git file search.
- [x] Add live grep and grep word.
- [x] Add diagnostics search.
- [x] Add symbols search (LSP & Treesitter).
- [x] Add resume-last-search behavior.
- [x] Add Wayland clipboard history (cliphist).

## 6. Navigation
### `lua/plugins/navigation/history.lua`
- [x] Add visual Jumplist navigation.

### `lua/plugins/navigation/mini-files.lua`
- [x] Add a modern file explorer.
- [x] Support current-file-directory and project-root entrypoints.
- [x] Support split-aware browsing.

### `lua/plugins/navigation/smart-splits.lua`
- [x] Add pane navigation across Neovim and the multiplexer (Zellij integration).

## 7. Editing
### `lua/plugins/editing/mini-editing.lua`
- [x] Add surround operations.
- [x] Add split/join code support.
- [x] Add move-line support.
- [x] Add pairs and indent scope (snacks).

### `lua/plugins/editing/inc-rename.lua`
- [x] Add project-wide file renaming (integrated with explorer).

## 8. LSP and Completion
### `lua/plugins/lsp/blink.lua`
- [x] Add completion engine setup.
- [x] Add snippets integration.

### `lua/plugins/lsp/init.lua`
- [x] Configure servers with `vim.lsp.config`.
- [x] Add hover, definition, declaration, implementation, type, references, and calls mappings.
- [x] Add code actions.

## 9. Version Control
### `lua/plugins/version_control/mini-diff.lua`
- [x] Add hunks navigation and statusline integration.
- [x] Add stage/modified hunk actions.

## 10. Workflow
### `lua/plugins/workflow/test-runner.lua`
- [x] Add nearest-test and project-root test runner.

### `lua/plugins/workflow/toggleterm.lua`
- [x] Add terminal/tui integration (snacks.terminal).
- [x] Add launchers for lazygit.

## 11. DAP
### `lua/plugins/dap/init.lua`
- [ ] Rebuild the DAP domain orchestrator.

## 13. Commands
### `lua/commands/building.lua`
- [x] Rebuild the build system with modular sub-modules.
- [x] Add project run/watch commands (watchexec).
- [x] Add terminal handoff and Zellij split execution.
- [x] Add intelligent language detection (uv, go run, zig run, cargo, etc.).

## 14. Validation and Maintenance
### `scripts/`
- [x] Add a headless test runner (busted-based).

### `tests/`
- [x] Add building system unit and integration tests.
- [x] Add filesystem/marker branching tests.

### Config quality
- [x] Sync the TODO list with rebuilt modules.
