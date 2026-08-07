# Neovim Nix Migration Plan (Home Manager + Nix-Managed Plugins)

This document outlines the architecture and step-by-step plan for migrating this Neovim configuration to **NixOS / Home Manager** while preserving **100% of the native Lua codebase** (`~/.config/nvim`).

---

## 🎯 Architectural Philosophy

- **No Nix Translation Layers (No Nixvim/nvf):** Keep configuration in raw Lua. Avoids double-translation friction, preserves instant edit-reload feedback, and maintains full `lazydev` type intelligence.
- **Nix for System Dependencies & Binaries:** Let Home Manager deliver Neovim 0.11+, Language Servers, formatters, CLI tools (`ripgrep`, `watchexec`, `tectonic`), and C build tools.
- **Nix for Plugin Management:** Replace runtime `vim.pack.add` fetching with Nix store plugin derivations (`pkgs.vimPlugins`). This provides pre-compiled C/Rust plugin binaries (`luasnip`, `blink.cmp`) with zero host build tool requirements.

---

## 📋 Migration Steps

### 1. Neovim 0.11+ Nightly Overlay
This configuration requires Neovim 0.11 features (`vim._core.ui2`, native `vim.lsp.config`, built-in `vim.pack`). Standard Nixpkgs defaults to 0.10.x.

* **Action:** Import `neovim-nightly-overlay` in your Flake:
  ```nix
  inputs.neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  ```

### 2. Dual-Boot Guard in `plugin/02-pack.lua`
Allow the config to run on both NixOS (where Nix loads plugins into `packpath`) and standard Linux/macOS (where `vim.pack` fetches them).

* **Action:** Add a check at the top of `plugin/02-pack.lua`:
  ```lua
  if vim.g.nix_managed then
      return
  end
  ```

### 3. Home Manager Neovim Module (`neovim.nix`)
Define the Neovim program block, system packages, and plugin list in Home Manager:

```nix
{ pkgs, inputs, ... }:

let
  # Helper for custom GitHub plugins not yet in nixpkgs
  buildCustomPlugin = name: repo: pkgs.vimUtils.buildVimPlugin {
    pname = name;
    version = "latest";
    src = pkgs.fetchFromGitHub {
      owner = "gsmith-alvarez";
      repo = repo;
      rev = "main";
      sha256 = pkgs.lib.fakeHash; # Replace with actual hash after initial build
    };
  };
in
{
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    defaultEditor = true;

    # Set flag so 02-pack.lua skips vim.pack.add
    extraLuaConfig = ''
      vim.g.nix_managed = true
    '';

    # External dependencies injected into Neovim's PATH
    extraPackages = with pkgs; [
      # LSPs
      lua-language-server
      clang-tools          # clangd
      ruff
      bash-language-server
      typos-lsp

      # Utilities & Runners
      ripgrep
      watchexec
      tectonic
      uv
      zig
      gnumake
      gcc
    ];

    # Nix-managed plugins (Loaded automatically into packpath)
    plugins = with pkgs.vimPlugins; [
      # Theme & UI
      catppuccin-nvim
      mini-nvim
      mini-icons
      snacks-nvim
      which-key-nvim
      dropbar-nvim

      # Completion & Snippets (Nix pre-compiles native C/Rust binaries)
      luasnip
      blink-cmp
      friendly-snippets
      lazydev-nvim

      # Treesitter + Parsers
      (nvim-treesitter.withPlugins (p: [
        p.c p.cpp p.python p.lua p.bash p.markdown p.json p.yaml p.zig
      ]))
      nvim-treesitter-textobjects

      # LSP & Tools
      nvim-lspconfig
      render-markdown-nvim
      obsidian-nvim
      autolist-nvim
      quicker-nvim
      nvim-bqf
      async-nvim
      refactoring-nvim

      # Custom Plugins
      (buildCustomPlugin "mise-nvim" "mise.nvim")
      (buildCustomPlugin "latex-tools-nvim" "latex-tools.nvim")
      (buildCustomPlugin "sigils-nvim" "sigils.nvim")
      (buildCustomPlugin "run-nvim" "run.nvim")
    ];
  };

  # Symlink Lua configuration directory
  home.file.".config/nvim".source = ./nvim;
}
```

---

## ⚡ Benefits of Final Setup

1. **Instant Feedback:** Editing `~/.config/nvim/*.lua` applies immediately on save without running `home-manager switch`.
2. **Zero Compiled Plugin Friction:** `LuaSnip` C extensions and `blink.cmp` Rust binaries come pre-compiled straight from `/nix/store`.
3. **Full LSP & `lazydev` Support:** Autocompletion, type checking, and hover docs remain active for `vim.*` APIs and plugin libraries.
4. **Fallback Portability:** Disabling `vim.g.nix_managed` lets the config fall back to `vim.pack.add` on non-Nix systems.
