# Zellij Tab Manager

Intelligent automatic tab naming for the [Zellij](https://zellij.dev/) terminal multiplexer.

## Features

✨ **Smart Directory Naming**
- Shows current directory name
- Git repository detection (displays `repo/subdir`)
- Deep directory support (`repo/…/current` for nested paths)
- Automatic name truncation for long paths

🎯 **TUI App Detection**
- Renames tabs when running TUI applications (nvim, btop, lazygit, etc.)
- Reverts to directory name when app exits
- Fully customizable via config file

🚀 **Performance Optimized**
- Git root caching reduces repeated lookups
- Smart path filtering skips non-repo directories
- Config loaded once and cached

🎨 **Customizable**
- Environment variables for runtime control
- Custom naming patterns with template variables
- Project detection from package files
- Per-user TUI app configuration

## Quick Start

The zellij manager works automatically when you're in a Zellij session. No setup required!

### Customization

**Disable auto-renaming** (add to `~/.config/fish/config.fish`):
```fish
set -gx ZJ_AUTO_RENAME 0
```

**Disable only TUI app renaming**:
```fish
set -gx ZJ_RENAME_TUI_APPS 0
```

**Enable project detection**:
```fish
set -gx ZJ_PROJECT_DETECTION 1
```

**Use custom naming pattern**:
```fish
# Show repo and git branch
set -gx ZJ_TAB_NAME_PATTERN "{git_root}:{git_branch}"

# Show project type icon with project name
set -gx ZJ_PROJECT_DETECTION 1
set -gx ZJ_TAB_NAME_PATTERN "{project_type}{project}"
```

## Configuration File

Edit `~/.config/fish/zellij_manager.conf` to customize which TUI apps trigger tab renaming:

```conf
# Text editors
nvim
vim
helix

# System monitors
btop
htop

# Git tools
lazygit
tig

# File managers
yazi
ranger

# Add your own!
```

## Template Variables

Use these in `ZJ_TAB_NAME_PATTERN` for custom tab naming:

| Variable | Description | Example |
|----------|-------------|---------|
| `{dir}` | Current directory name | `dotfiles` |
| `{git_root}` | Git repository root name | `my-project` |
| `{git_branch}` | Current git branch | `main` or `feature/new` |
| `{path}` | Full directory path (truncated) | `/home/user/projects/...` |
| `{project}` | Project name from package file | `my-app` |
| `{project_type}` | Project type icon | 📦 🦀 🐍 🐹 ☕ |

### Pattern Examples

```fish
# Repository with branch
set -gx ZJ_TAB_NAME_PATTERN "{git_root}:{git_branch}"
# Output: my-project:feature/auth

# Branch prefix
set -gx ZJ_TAB_NAME_PATTERN "[{git_branch}] {dir}"
# Output: [main] src

# Project type and name
set -gx ZJ_PROJECT_DETECTION 1
set -gx ZJ_TAB_NAME_PATTERN "{project_type} {project}"
# Output: 🦀 my-rust-app
```

## Environment Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `ZJ_AUTO_RENAME` | 0/1 | 1 | Master switch for all auto-renaming |
| `ZJ_RENAME_TUI_APPS` | 0/1 | 1 | Enable TUI app detection |
| `ZJ_PROJECT_DETECTION` | 0/1 | 0 | Enable project name/type detection |
| `ZJ_CONFIG_FILE` | path | `~/.config/fish/zellij_manager.conf` | TUI apps config file |
| `ZJ_TAB_NAME_PATTERN` | string | *(none)* | Custom naming pattern |

## Project Detection

When enabled with `ZJ_PROJECT_DETECTION=1`, automatically detects project names from:

| Language | File | Icon |
|----------|------|------|
| Node.js / JavaScript | `package.json` | 📦 |
| Rust | `Cargo.toml` | 🦀 |
| Python | `pyproject.toml` | 🐍 |
| Go | `go.mod` | 🐹 |
| Java | `pom.xml` | ☕ |

## Behavior Details

### Tab Naming Logic

1. **Home directory** → `~`
2. **Regular directory** → `directory-name`
3. **Git repository** → `repo/subdir`
4. **Deep git directory** (3+ levels) → `repo/…/current`
5. **Long names** → Automatically truncated with `…`

### TUI App Detection

When you run a TUI app from the config:
1. Tab is renamed to the app name (e.g., `nvim`)
2. When the app exits, tab reverts to directory name
3. Works with `sudo`, `doas`, `command`, and `builtin` prefixes

### Performance

- **Git caching**: Repository root cached per directory
- **Smart filtering**: Skips git checks in `/tmp`, `/proc`, `/sys`, `/dev`, `/run`
- **One-time loading**: Config file loaded once on shell startup
- **Minimal overhead**: Template expansion only when pattern is set

## Troubleshooting

**Tabs aren't renaming?**
- Check you're in a Zellij session: `echo $ZELLIJ`
- Verify zellij command exists: `type -q zellij`
- Check settings: `echo $ZJ_AUTO_RENAME`

**Config file not working?**
- Verify file exists: `cat ~/.config/fish/zellij_manager.conf`
- Check permissions: `ls -la ~/.config/fish/zellij_manager.conf`
- Reload fish: `source ~/.config/fish/config.fish`

**Git detection not working?**
- Ensure you're in a git repository: `git status`
- Check git command exists: `type -q git`
- Clear cache by changing to a different directory and back

**Project detection not working?**
- Enable it: `set -gx ZJ_PROJECT_DETECTION 1`
- Verify project file exists (e.g., `package.json`)
- For JSON parsing, install `jq` for better results

## Examples

### Default Behavior

```
/home/user              → ~
/home/user/projects     → projects
/home/user/projects/my-repo          → my-repo
/home/user/projects/my-repo/src      → my-repo/src
/home/user/projects/my-repo/src/api/handlers  → my-repo/…/handlers
```

### Running TUI Apps

```
/home/user/project $ nvim           → Tab shows: nvim
                                       (on exit) → project
```

### With Custom Pattern

```fish
set -gx ZJ_TAB_NAME_PATTERN "{git_root}:{git_branch}"
```

```
/home/user/my-repo/src  → my-repo:main
/home/user/my-repo/docs → my-repo:feature/docs
```

## License

Part of personal dotfiles configuration.
