# Neovim Post-Rebuild TODO

Most of the clay-dots architecture is now implemented and verified. These are the remaining items to reach full completion.

## 1. UI Enhancements
- [ ] **Startup Dashboard**: Configure `snacks.dashboard` to show recent files, projects, and useful entry actions.
- [ ] **Trouble UI**: Implement `folke/trouble.nvim` for advanced project-wide diagnostics, references, and quickfix views.

## 2. Debugging (DAP)
- [ ] **DAP Orchestrator**: Rebuild the DAP (Debug Adapter Protocol) domain. Setup `nvim-dap`, `nvim-dap-ui`, and language-specific adapters.

## 3. Maintenance & Robustness
- [x] **LaTeX Rendering**: Verified `snacks.image` math rendering.
- [ ] **Post-Install Hooks**: Refine `plugin/02-pack.lua` hooks to be even more robust across different OS environments.

## 4. Completed Milestones (Recent)
- [x] Switched to `mini.icons` as the universal icon provider.
- [x] Integrated `LuaSnip` with both VSCode (JSON) and Lua-native snippet sources.
- [x] Connected `blink.cmp` to `LuaSnip` for completion.
- [x] Implemented IDE-like breadcrumbs via `dropbar.nvim`.
- [x] Added `mini.sessions` for automatic state persistence.
- [x] Configured smart image resolution for YouTube and Obsidian in `snacks.image`.
- [x] Beautified Markdown with `render-markdown.nvim`.
- [x] Optimized `which-key` with dynamic icons and corrected bracket/operator groups.
