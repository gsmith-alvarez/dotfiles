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
- [ ] Add health or validation hooks for missing binaries.

### `lua/core/vscode.lua`
- [ ] Keep VSCode-specific behavior isolated.
- [ ] Load this layer only when running inside VSCode.

### `plugin/02-pack.lua`
- [ ] Keep plugin specs grouped by domain.
- [ ] Keep post-install hooks robust (build tools, copy fallbacks).
- [ ] Add health checks for missing external build tools.

## 2. Autocmds
### `plugin/05-autocmds.lua`
- [x] Highlight on yank.
- [x] Auto-resize windows on terminal resize.
- [ ] Auto-create parent directories on save.

### `lua/autocmd/external.lua` (optional split from plugin/05-autocmds.lua)
- [ ] Add large-file protections.
- [ ] Add special-file handling for archive or external viewers.

### `lua/autocmd/jit.lua` (optional split from plugin/05-autocmds.lua)
- [ ] Load markdown or note-taking features only when needed.
- [ ] Keep expensive filetype logic deferred.

### `plugin/05-autocmds.lua` orchestration
- [ ] Keep global autocmds lightweight.
- [ ] Add hot reload hooks for config files if desired.

## 3. Plugin Foundation
### `plugin/05-plugins.lua`
- [x] Keep plugin bootstrap list current.
- [x] Keep context-aware loading paths separate.
- [x] Keep all plugin module loads routed through `Config.safe_require`.

### `lua/plugins/core/mini.lua`
- [x] Add `mini.nvim` core pieces used everywhere.
- [x] Add deferred `mini.icons` / tabline support if needed.

### `lua/plugins/core/snacks.lua`
- [ ] Add notifier support.
- [ ] Add picker support.
- [ ] Add terminal support.
- [ ] Add UI select replacement.
- [ ] Add LSP progress UI.

## 4. UI Layer
### `lua/plugins/ui/mini-colors.lua`
- [x] Load the colorscheme and palette.
- [x] Make the palette the visual base for the entire config.

### `lua/plugins/ui/which-key.lua`
- [x] Add key discovery popups.
- [x] Register the major prefix groups.

### `lua/plugins/ui/snacks-dashboard.lua`
- [ ] Add a startup dashboard.
- [ ] Show recent files, projects, and useful entry actions.
- [ ] Defer expensive dashboard details until after startup.

### `lua/plugins/ui/mini-statusline.lua`
- [x] Add a custom statusline.
- [x] Show mode, branch, diff counts, LSP, and environment/version info.

### `lua/plugins/ui/winbar.lua`
- [ ] Add file context breadcrumbs.
- [ ] Use Treesitter when available.

### `lua/plugins/ui/trouble.lua`
- [ ] Add diagnostics, references, and quickfix UI.
- [ ] Wire it to search and diagnostic keymaps.

### `lua/plugins/ui/render-markdown.lua`
- [ ] Add improved markdown rendering.
- [ ] Keep it filetype-local and safe.

### `lua/plugins/ui/quotes.lua`
- [ ] Add file context breadcrumbs.
- [ ] Use Treesitter when available.

### `lua/plugins/ui/treesitter.lua`
- [x] Configure Treesitter highlighting.
- [x] Configure textobjects.
- [ ] Configure sticky context or contextual display.

## 5. Search and Discovery
### `lua/plugins/searching/init.lua`
- [ ] Rebuild the search domain orchestrator.

### `lua/plugins/searching/snacks-picker.lua`
- [ ] Add file search.
- [ ] Add recent files search.
- [ ] Add buffer search.
- [ ] Add config search.
- [ ] Add project search and project switching.
- [ ] Add git file search.
- [ ] Add live grep and grep word.
- [ ] Add diagnostics search.
- [ ] Add symbols search.
- [ ] Add resume-last-search behavior.

### `lua/plugins/searching/aerial.lua`
- [ ] Add document symbol navigation.
- [ ] Add symbol tree/jump support.

## 6. Navigation
### `lua/plugins/navigation/history.lua`

## 6. Navigation
### `lua/plugins/navigation/mini-files.lua`
- [x] Add a modern file explorer.
- [x] Support current-file-directory and project-root entrypoints.
- [x] Support split-aware browsing.

### `lua/plugins/navigation/smart-splits.lua`
- [ ] Add pane navigation across Neovim and the multiplexer.
- [ ] Add pane resize mappings.

### `lua/plugins/navigation/sigils.lua`
- [ ] Add enhanced mark management.
- [ ] Add project marks, buffer marks, previews, and rebaking.

## 7. Editing
### `lua/plugins/editing/init.lua`
- [ ] Rebuild the editing domain orchestrator.

### `lua/plugins/editing/mini-editing.lua`
- [ ] Add comment motions and line comments.
- [ ] Add surround operations.
- [ ] Add alignment helpers.
- [ ] Add split/join code support.
- [ ] Add move-line and move-block support.
- [ ] Add pairs, indent scope, and other small text editing helpers.

### `lua/plugins/editing/autolist.lua`
- [ ] Continue lists on Enter.
- [ ] Handle markdown and text block behavior.
- [ ] Support dedent/list exit flows.

### `lua/plugins/editing/luasnip.lua`
- [ ] Add snippet expansion.
- [ ] Add snippet jump keys.
- [ ] Add choice-node cycling.
- [ ] Load snippet collections.

### `lua/plugins/editing/inc-rename.lua`
- [ ] Add incremental rename UX.
- [ ] Wire it to the rename keymap.

### `lua/plugins/editing/refactoring.lua`
- [ ] Add structural extract/inline refactors.
- [ ] Add function/variable/file-level refactors.

### `lua/plugins/editing/crates.lua`
- [ ] Add Rust crate helper flows.
- [ ] Support version updates and inline hints.

### `lua/plugins/editing/indent.lua`
- [ ] Add indentation behavior helpers.
- [ ] Keep visual indent behavior predictable.

## 8. LSP and Completion
### `lua/plugins/lsp/init.lua`
- [x] Rebuild the LSP domain orchestrator.
- [x] Keep completion setup before server setup.

### `lua/plugins/lsp/blink.lua`
- [x] Add completion engine setup.
- [x] Add snippets integration.
- [ ] Add capability broadcasting.
- [ ] Add toggles for LSP and snippet sources.

### `lua/plugins/lsp/init.lua` (or `lua/plugins/languages.lua`)
- [x] Configure servers with `vim.lsp.config`.
- [x] Add hover, definition, declaration, implementation, type, references, and calls mappings.
- [x] Add code actions.
- [ ] Add formatting hooks.
- [ ] Add inlay hint support.
- [ ] Add rename and file-rename flows.

### `lua/plugins/lsp/rust.lua`
- [ ] Add Rust-specific LSP configuration.
- [ ] Connect Rust tooling to the rest of the editor.

## 9. Version Control
### `lua/plugins/version_control/init.lua`
- [ ] Rebuild the git domain orchestrator.

### `lua/plugins/version_control/mini-diff.lua`
- [ ] Add sign column git markers.
- [ ] Add hunks navigation.
- [ ] Add stage and undo hunk actions.
- [ ] Add diff overlay support.
- [ ] Add branch/statusline integration.

## 10. Workflow
### `lua/plugins/workflow/init.lua`
- [ ] Rebuild the workflow domain orchestrator.

### `lua/plugins/workflow/format.lua`
- [ ] Add async formatting.
- [ ] Add buffer and selection formatting commands.
- [ ] Add autoformat-on-save toggle.

### `lua/plugins/workflow/lint.lua`
- [ ] Add async linting.
- [ ] Add diagnostics refresh on buffer events.

### `lua/plugins/workflow/overseer.lua`
- [ ] Add task runner support.
- [ ] Add template-based job execution.
- [ ] Add task info and action menus.

### `lua/plugins/workflow/persistence.lua`
- [ ] Add session save and restore.
- [ ] Add manual save, restore, and discard flows.

### `lua/plugins/workflow/test-runner.lua`
- [ ] Add nearest-test runner.
- [ ] Add current-file test runner.
- [ ] Add project-root test runner.

### `lua/plugins/workflow/toggleterm.lua`
- [ ] Add terminal/tui integration.
- [ ] Add launchers for lazygit, aider, or other terminal workflows.

### `lua/plugins/workflow/typst-preview.lua`
- [ ] Add Typst preview support.
- [ ] Add preview start, close, and sync actions.

### `lua/plugins/workflow/golem-be-good.lua`
- [ ] Add motion training if you still want it in the rebuilt setup.

### `lua/plugins/workflow/platformio.lua`
- [ ] Add PlatformIO task support.
- [ ] Add build, upload, monitor, and compile-database actions.

### `lua/plugins/workflow/go.lua`
- [ ] Add Go workflow support.
- [ ] Add language-specific run or test helpers.

### `lua/plugins/workflow/dadbod.lua`
- [ ] Add database workflow support.
- [ ] Add a comfortable query/edit loop.

## 11. DAP
### `lua/plugins/dap/init.lua`
- [ ] Rebuild the DAP domain orchestrator.

### `lua/plugins/dap/debug.lua`
- [ ] Add core DAP configuration.
- [ ] Add language adapters you use.
- [ ] Add launch and attach setups.

### `lua/plugins/dap/nvim-dap-virtual-text.lua`
- [ ] Add inline debug values.

### `lua/plugins/dap/persistent-breakpoint.lua`
- [ ] Persist breakpoints across sessions.
- [ ] Add breakpoint toggle and clear actions.

## 12. Notes
### `lua/plugins/notetaking/obsidian.lua`
- [ ] Add Obsidian vault integration.
- [ ] Add quick switch and note search.
- [ ] Add new-note and follow-link actions.
- [ ] Add buffer-local note actions for tags, TOC, templates, extraction, and linking.
- [ ] Add image paste and GUI-open helpers.

## 13. Commands
### `lua/commands/init.lua`
- [ ] Rebuild the command domain orchestrator.

### `lua/commands/utilities.lua`
- [ ] Add jq scratchpad support.
- [ ] Add sd-based replace support.
- [ ] Add xh HTTP client helpers.

### `lua/commands/diagnostics.lua`
- [ ] Add diagnostic display toggles.
- [ ] Add virtual text and underline control.

### `lua/commands/building.lua`
- [x] Add project run/watch commands.
- [x] Add terminal handoff or split execution.

### `lua/commands/auditing.lua`
- [ ] Add tool and health audit commands.
- [ ] Add redirection or capture helpers.

### `lua/commands/mux.lua`
- [ ] Add multiplexer layout or pane control commands.

### `lua/commands/hot-reload.lua`
- [ ] Add config reload helpers.
- [ ] Make the reload path fast and predictable.

### `lua/commands/platformio.lua`
- [ ] Add direct PlatformIO user commands.

## 14. Validation and Maintenance
### `docs/`
- [ ] Write the rebuild notes for future-you.
- [ ] Keep the module order documented.

### `scripts/`
- [ ] Add a headless test runner.
- [ ] Add a boot verification script.

### `tests/`
- [ ] Add boot tests.
- [ ] Add option tests.
- [ ] Add keymap tests.
- [ ] Add autocmd tests.
- [ ] Add plugin-loading tests.
- [ ] Add snippet tests.
- [ ] Add format and dependency tests.
- [ ] Add any matrix coverage you want for platform/tooling differences.

### Config quality
- [ ] Add health checks for the final setup.
- [ ] Add linting and formatting for the config itself.
- [ ] Keep the TODO list synced with the actual modules as they are rebuilt.
