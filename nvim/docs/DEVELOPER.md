# Neovim Configuration Developer Guide

This document explains the architecture, design philosophy, and orchestration layer of this Neovim configuration. It is designed to be **modular**, **anti-fragile**, and **performance-oriented**.

---

## 🏗️ Architecture: The Phased Boot Sequence

To achieve near-instant startup while maintaining a rich feature set, the configuration follows a strict 4-phase loading strategy in `init.lua`.

### PHASE 0: Microcode & Foundation
*   **Purpose:** Enable the Lua loader and purge legacy Vim defaults.
*   **Actions:** Calls `vim.loader.enable()` and disables built-in plugins (netrw, zip, etc.) that are replaced by modern Lua alternatives.

### PHASE 1: Core Foundation
*   **Purpose:** Establish the "Safe Execution Environment."
*   **Actions:**
    1.  Loads `core.utils` (Audit Trail, Soft Notify).
    2.  Loads `core` (Options, Keymaps, Library functions).
    3.  Loads `autocmd` and `commands` (User-defined automation).

### PHASE 2: Plugin Orchestration
*   **Purpose:** Bootstrap the plugin manager and load "Tier 0" plugins.
*   **Actions:** Uses `mini.deps` to manage dependencies. Plugins are categorized into `now` (immediate) and `later` (deferred) buckets.

### PHASE 3: Deferred UI & Workflow
*   **Purpose:** Load non-essential UI elements and background tools.
*   **Actions:** Everything that doesn't affect the initial buffer render is loaded during the Neovim idle loop.

### PHASE 4: FileType & Proxy Traps (JIT)
*   **Purpose:** Only load heavy file-specific plugins when necessary.
*   **Actions:** Plugins like `autolist.nvim` or `render-markdown` register `FileType` autocommands and wait dormant until a relevant file (e.g. `markdown`) is actually opened.

---

## 🛡️ The Anti-Fragile Engine: `safe_require`

The configuration uses a custom `safe_require` function in `init.lua` to prevent "cascading failures."

*   **Logic:** It wraps the standard `require` in a `pcall`.
*   **Failure Handling:** If a module fails to load, it captures the error, schedules a non-blocking `vim.notify`, and allows the rest of the configuration to continue.
*   **Persistence:** Errors are also routed to the persistent audit trail (`~/.local/state/nvim/config_diagnostics.log`).

---

## 🛠️ Core Utilities (`lua/core/utils.lua`)

### 1. The Audit Trail
All significant events, warnings, and errors are logged to a persistent file. This complies with XDG specifications and allows for debugging "silent" failures.
*   **Log Path:** `~/.local/state/nvim/config_diagnostics.log`

### 2. Mise Integration (`mise.nvim`)
Instead of manual path resolution, we use `ejrichards/mise.nvim` to synchronize Neovim's process environment with the local `mise` configuration. This ensures that standard Neovim discovery tools like `vim.fn.executable()` and `vim.fn.exepath()` are always accurate without custom wrappers.

### 3. Soft Notify (`M.soft_notify`)
A wrapper for `vim.notify` that simultaneously:
1.  Displays a message in the UI (via `snacks.notifier`).
2.  Appends the message to the persistent audit trail.

---

## 🧪 Testing and Validation

The configuration includes a testing suite powered by `mini.test` (or `plenary`).

### Running Tests
To run the full suite of integration tests for core utilities:
```bash
./run_tests.sh
```

Alternatively, you can run them manually:
```bash
nvim --headless -u tests/run_tests.lua -c "lua MiniTest.run()"
```

### Test Strategy
*   **Logging Integrity:** Ensure `soft_notify` writes correctly to the audit trail.
*   **Boot Sequence Smoke Tests:** Verify that all core phases load without errors.
