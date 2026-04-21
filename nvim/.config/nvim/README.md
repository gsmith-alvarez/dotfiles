# Engineering-Centric Neovim Configuration

A native-first, explicit Neovim configuration designed for engineering studies, rapid prototyping, and academic note-taking. Built to run on **Neovim Nightly**.

## 🛠 Core Philosophy

- **Native over Abstraction:** Avoids complex plugin managers in favor of Neovim's built-in `vim.pack` system and standard runtime layout.
- **Explicit & Simple:** Configuration is kept readable and side-effect-aware, prioritizing understanding over "magic" one-liners.
- **Fault Tolerance:** Uses a custom `safe_require` mechanism to ensure that a single failing module or missing plugin doesn't break the entire editor startup.
- **Self-Healing:** Automatically handles background builds for heavy plugins like `blink.cmp` (Rust/Cargo) and `LuaSnip` (C/Make).

## 🚀 Prototyping & Workflow

Designed for the "Learning-by-Doing" approach to programming:

- **Smart Run:** Custom `:Run` command that detects filetypes and executes scripts in a **Zellij** pane or **Snacks** terminal.
- **Live Watch:** Integration with `watchexec` via `:Watch` and `:RunWatch` for real-time feedback while scripting.
- **Academic Stack:** Optimized for LaTeX (Tectonic engine) and Obsidian-style Markdown note-taking, making it a primary tool for engineering coursework.

## 📦 Native Plugin Management

Managed via Neovim's `vim.pack` with custom lifecycle commands:

- `:PackStatus`: Shows a detailed report of loaded, lazy-loaded, and inactive plugins.
- `:PackUpdate`: Fetches and installs updates for all configured plugins.
- `:PackRestore`: Syncs plugins exactly to the `nvim-pack-lock.json` for reproducibility.
- `:PackPurge`: Opens an interactive buffer to safely remove unused plugin directories.
- `:PackCleanLock`: Resets the lockfile to allow for a fresh dependency resolution.

## 🏗 Project Structure

Following Neovim's native runtime engine:

- `plugin/`: Side-effect scripts loaded automatically on startup (Options, Keymaps, Package Specs).
- `lua/core/`: Internal utilities and the `safe_require` engine.
- `lua/plugins/`: Modular configuration for the plugin ecosystem.
- `lua/commands/`: Implementation of the Smart Run, Watch, and Plugin Management systems.
- `after/`: Context-specific overrides (LSP, Ftplugins).
- `tests/`: Automated verification of the build runners and filesystem helpers.

## 📦 Dependencies

Managed via `mise` (or your preferred tool manager):

| Category | Tools |
| :--- | :--- |
| **Runtimes** | Node.js, Bun, Zig, Cargo |
| **LSPs** | Lua, Bash, Pyright, JSON, YAML, Docker, clangd |
| **Format/Lint** | Ruff, Stylua, Checkshell, Shfmt, Taplo, Oxlint |
| **Typesetting** | Tectonic (LaTeX), Mermaid-CLI, dvisvgm |
| **Utilities** | watchexec, tree-sitter-cli, typos |

## 🔧 Installation

1. Ensure you are on **Neovim Nightly**.
2. Install the required tools listed above via `mise install`.
3. Clone into `~/.config/nvim`.
4. Neovim will automatically bootstrap the `vim.pack` system and build necessary binaries on first launch.
