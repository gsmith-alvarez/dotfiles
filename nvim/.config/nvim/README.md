# Neovim Config Structure

This config follows Neovim's native runtime layout. The main idea is simple:

- Use `plugin/` for files that should run automatically on startup.
- Use `lua/` for modules that should only run when explicitly required.
- Use `after/` for overrides that must run later than everything else.

## How This Config Loads

Startup flow:

1. Neovim starts and reads `init.lua`.
2. `init.lua` defines global bootstrap helpers (for example `Config.safe_require`).
3. Neovim automatically executes files in `plugin/` in lexicographic order.
4. `plugin/05-plugins.lua` requires plugin modules from `lua/plugins/*`.
5. `after/` is loaded last and can override previous behavior.

Current `plugin/` order in this repo:

- `plugin/00-options.lua`
- `plugin/01-path.lua`
- `plugin/02-pack.lua`
- `plugin/03-keymaps.lua`
- `plugin/04-plugin-keymaps.lua`
- `plugin/05-autocmds.lua`
- `plugin/05-plugins.lua`

## Standard Neovim Runtime Subdirectories

Inside `~/.config/nvim/`, Neovim recognizes specific runtime folders. Other folder names are not loaded by core automatically (though plugins may use them).

1. `lua/` - Lua modules loaded via `require()`.
2. `plugin/` - Auto-loaded once on startup.
3. `after/` - Overrides loaded after the main runtime.
4. `ftplugin/` - Filetype-local settings (for example `python.lua`).
5. `ftdetect/` - Filetype detection rules.
6. `colors/` - Colorschemes.
7. `queries/` - Treesitter query overrides/extensions.
8. `doc/` - Help docs indexed by `:helptags`.
9. `autoload/` - Vimscript autoload functions.
10. `indent/` - Filetype indentation logic.
11. `syntax/` - Legacy syntax highlight rules.
12. `compiler/` - `:compiler` definitions and errorformats.
13. `keymap/` - Keymap/input-method files.
14. `spell/` - Spell files and custom dictionaries.
15. `rplugin/` - Remote plugin entrypoints.
16. `pack/` - Native package layout.
17. `parser/` - Treesitter parser binaries (sometimes in data dir instead).

## Common Non-Standard (Plugin-Owned) Folders

These are common but plugin-specific:

- `snippets/` - snippet collections/load paths (for example LuaSnip ecosystems).
- `themes/` - user-defined theme organization.
- `undodir/` - persistent undo storage path (used if `vim.opt.undodir` points here).

## Practical Rule of Thumb

- Put side-effect startup scripts in `plugin/`.
- Put reusable functions/modules in `lua/`.
- Put filetype behavior in `ftplugin/`.
- Put late overrides in `after/`.

This keeps load order predictable and takes advantage of Neovim's built-in runtime engine.
