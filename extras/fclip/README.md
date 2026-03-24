# fclip: A DIY Wayland Clipboard Manager

`fclip` is a lightweight, blazing-fast, and completely hackable clipboard manager designed specifically for Wayland, the Cosmic Desktop Environment, and Ghostty.

It operates without a heavy GUI or bloated background daemons. Instead, it glues together a few excellent Unix tools to give you a beautiful `fzf`-driven clipboard history.

---

## 🚀 How It Works

The system is split into two distinct parts:

1. **The Watcher (`fclip watch`)**: A lightweight background process (managed by `systemd`) that listens for Wayland clipboard events using `wl-paste --watch`. Every time you copy text, this watcher securely intercepts it, ignores images and password managers, and saves the text into a local SQLite database (`~/.clipboard_history.sqlite`).
2. **The Interface (`fclip window`)**: When triggered via a keyboard shortcut, it launches a dedicated, borderless **Ghostty** terminal window. Inside this terminal, it runs `fclip menu`, which pulls your history from the SQLite database and presents it in a beautiful, interactive `fzf` menu.

## ✨ Functionality & Keybindings

When the `fclip` window is open, you can use the following bindings:

- `Enter`: Copy the selected item back to your clipboard and close the window.
- `Del`: Delete the selected item from your clipboard history permanently.
- `Tab`: Select multiple items.
- `Ctrl + A`: Select all items.
- `Ctrl + P`: Toggle the preview window (great for long multi-line copies).
- `Ctrl + /`: Toggle line wrapping in the preview window.
- `Ctrl + R`: Reload the clipboard history.
- `Ctrl + H`: Toggle the help header.

## 🧰 Dependencies

To run `fclip`, the following modern Unix tools must be installed:

- **wl-clipboard**: For Wayland clipboard interactions (`wl-paste`, `wl-copy`).
- **fzf**: For the interactive fuzzy finder UI.
- **sqlite3**: To securely store and query the clipboard history.
- **jq**: To parse the JSON output from SQLite safely.
- **ghostty**: The terminal emulator used to display the UI.

## ⚙️ How to Implement on a New Machine

If you are setting this up on a fresh machine or dotfiles clone, follow these steps:

### 1. Symlink the Script
Make sure the script is executable and symlinked into your `$PATH`:
```bash
chmod +x ~/dotfiles/extras/fclip/fclip
ln -sf ~/dotfiles/extras/fclip/fclip ~/.local/bin/fclip
```

### 2. Enable the Systemd Background Watcher
Symlink the systemd service file to your user config, reload the daemon, and enable it so it starts automatically on login:
```bash
mkdir -p ~/.config/systemd/user
ln -sf ~/dotfiles/extras/fclip/fclip.service ~/.config/systemd/user/fclip.service
systemctl --user daemon-reload
systemctl --unit enable --now $PWD/fclip.service
```

### 3. Desktop Environment Configuration (Cosmic DE)
You need to configure your desktop environment to launch the window and float it.

**Create the Keyboard Shortcut:**
- Open Cosmic Settings > Keyboard > Custom Shortcuts.
- Add a new shortcut (e.g., `Super + V`).
- Set the command to: `fclip window`

**Make the Window Float (If Supported):**
*Note: As Cosmic DE is actively being developed, Window Rules may still be experimental or missing depending on your version.*
- Open Cosmic Settings > Window Rules (or similar tiling exception settings).
- Add a new rule targeting applications with the Window Class `clipboard`.
- Set the rule to force the window to be **Floating** and **Centered**.
- *(If Window Rules are not yet available in your Cosmic build, the fclip window will simply spawn as a normal tiled terminal window when triggered, which works perfectly fine!)*

---
*Inspired by `fzf-clipboard` by cdriehuys, re-architected for Wayland/Cosmic/Ghostty.*
