# 🐟 Fish Config Reference

Quick reference for all custom functions, abbreviations, and automation hooks
configured in this Fish shell environment.

---

## Functions (`functions/`)

| Command | Depends On | Description |
| :--- | :--- | :--- |
| `bmo` | `bmm`, `fzf`, `jq` | Fuzzy-find bookmarks and open in browser via `xdg-open`. |
| `fkill` | `fzf`, `ps` | Fuzzy find and kill processes. `TAB` to multi-select. |
| `j [path]` | `zoxide`, `fzf`, `eza` | Smart `cd`. No args → fzf over zoxide history with tree preview. |
| `list_all_apps` | `dnf`, `flatpak`, `cargo` | Generate full software inventory → `~/Downloads/MasterList.md`. |
| `nfzf` | `fd`, `fzf`, `bat` | Fuzzy find files (incl. hidden, excl. `.git`) and open in `$EDITOR`. |
| `nvq <pattern>` | `rg`, `nvim` | Ripgrep results piped directly into Neovim quickfix list. |
| `rga-fzf` | `rga`, `fzf` | Search inside PDFs/Office docs. Opens selected file via `xdg-open`. |
| `sg` | `rg`, `fzf`, `bat` | Fuzzy search file contents; opens Neovim at the exact match line. |
| `wtf` | `atuin`, `aider` | Sends last 5 commands + exit codes to `aider` for failure diagnosis. |
| `y` | `yazi`, `zoxide`, `nvim` | Yazi wrapper: syncs CWD to zoxide on exit, opens selected file in nvim. |
| `zk` | `zellij`, `fzf` | Fuzzy Zellij session manager — attach to existing or create new. |
| 'fcd' | 'fd', 'fzf', 'Zoxide' | Fuzzy search the current directory and move with z |


---

## Abbreviations (`config.fish`)

### Navigation
| Abbreviation | Expands To |
| :--- | :--- |
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `cd` | `z` (zoxide) |
| `yr` | `yazi` |
| `bk` | `bmm tui` |

### File & Text
| Abbreviation | Expands To |
| :--- | :--- |
| `cat` | `bat` |
| `man` | `batman` |
| `rg` | `batgrep` |
| `diff` | `batdiff` |
| `watch` | `batwatch` |
| `find` | `fd` |
| `du` | `dust -r` |
| `cp` | `rsync -ah --info=progress2` |
| `ls` | `eza --icons --group-directories-first` |
| `ll` | `eza -lh --icons --grid --group-directories-first` |
| `la` | `eza -a --icons --group-directories-first` |
| `tree` | `eza --tree --icons` |

### Editor & Clipboard
| Abbreviation | Expands To |
| :--- | :--- |
| `v` | `nvim` |
| `copy` | `wl-copy` |
| `paste` | `wl-paste` |

### Git
| Abbreviation | Expands To |
| :--- | :--- |
| `g` | `git` |
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit -m` |
| `gp` | `git push` |

### Python (`uv`)
| Abbreviation | Expands To |
| :--- | :--- |
| `py` | `uv run` |
| `pyr` | `uv run python` |
| `pyv` | `uv venv` |

### Asus Laptop
| Abbreviation | Expands To |
| :--- | :--- |
| `pperf` | `asusctl profile set Performance` |
| `pbal` | `asusctl profile set Balanced` |
| `pquiet` | `asusctl profile set Quiet` |
| `bbstay` | `asusctl battery limit 60` |

---

## Key Bindings (`config.fish`)

| Binding | Mode | Action |
| :--- | :--- | :--- |
| `Ctrl+R` | Insert + Normal | Atuin history search |
| `↑` | Insert + Normal | Atuin history up |
| `Ctrl+G` | Insert + Normal | Navi: smart cheatsheet replace |
| `Alt+E` | Insert + Normal | Navi: smart cheatsheet replace (alt) |

FZF is configured in Vi-modal mode — press `i` to enter Insert (search) mode,
`Esc` to return to Normal mode with `j/k/h/l` navigation.

---

## Automation Hooks (`conf.d/zellij_manager.fish`)

Event-driven hooks that fire automatically inside a Zellij session.

| Hook | Trigger | Behaviour |
| :--- | :--- | :--- |
| `__on_pwd_change` | Directory change | Notifies if a project-specific Zellij layout (`<dir>.kdl`) exists in `~/.config/zellij/layouts/`. |
| `__zj_preexec_handler` | Before a TUI app runs | Prints an encouraging message when launching: `nvim`, `spotify-player`, `surge`, `btop`, `lazygit`, `yazi`. |
| `__zj_postexec_handler` | After a TUI app exits | Prints a welcome-back message when returning from a TUI app. |

