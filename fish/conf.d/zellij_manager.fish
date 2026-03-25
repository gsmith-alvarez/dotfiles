# =============================================================================
# ZELLIJ TAB MANAGER - Automatic tab naming for Zellij terminal multiplexer
# =============================================================================
#
# FEATURES:
#   ✓ Auto-rename tabs based on current directory or running command
#   ✓ Smart git repository detection (shows repo/subdir or repo/…/subdir for deep dirs)
#   ✓ Configurable TUI app detection via config file
#   ✓ Environment variable controls for runtime behavior
#   ✓ Custom naming patterns with template variables
#   ✓ Project detection from package files (Node.js, Rust, Python, Go, Java)
#   ✓ Git root caching for performance optimization
#   ✓ Symlink resolution for accurate naming
#   ✓ Automatic truncation of long names
#
# QUICK START:
#   1. This file is auto-loaded by Fish shell from conf.d/
#   2. Works automatically if you're inside a Zellij session
#   3. Customize behavior via environment variables or config file
#
# ENVIRONMENT VARIABLES:
#   ZJ_AUTO_RENAME          - Enable/disable all auto-renaming (default: 1)
#   ZJ_RENAME_TUI_APPS      - Enable/disable TUI app detection (default: 1)
#   ZJ_PROJECT_DETECTION    - Enable project name/type detection (default: 0)
#   ZJ_CONFIG_FILE          - Custom config file path (default: ~/.config/fish/zellij_manager.conf)
#   ZJ_TAB_NAME_PATTERN     - Custom tab naming pattern with template variables
#
#   To disable auto-renaming, add to your config.fish:
#     set -gx ZJ_AUTO_RENAME 0
#
# TEMPLATE VARIABLES (for ZJ_TAB_NAME_PATTERN):
#   {dir}         - Current directory name
#   {git_root}    - Git repository root name
#   {git_branch}  - Current git branch name
#   {path}        - Full path (truncated if too long)
#   {project}     - Project name from package files (package.json, Cargo.toml, etc.)
#   {project_type}- Project type icon/prefix (📦 node, 🦀 rust, 🐍 python, etc.)
#
# PATTERN EXAMPLES:
#   set -gx ZJ_TAB_NAME_PATTERN "{git_root}:{git_branch}"       # Show repo and branch
#   set -gx ZJ_TAB_NAME_PATTERN "[{git_branch}] {dir}"          # Branch prefix with dir
#   set -gx ZJ_TAB_NAME_PATTERN "{project_type}{project}"       # Project type and name
#   set -gx ZJ_TAB_NAME_PATTERN "{dir}"                          # Simple directory name
#
# PROJECT DETECTION:
#   Set ZJ_PROJECT_DETECTION=1 to enable automatic project name detection
#   Supported files: package.json, Cargo.toml, pyproject.toml, go.mod, pom.xml
#
# CONFIGURATION FILE FORMAT (~/.config/fish/zellij_manager.conf):
#   # One TUI app per line, comments supported
#   # Lines starting with # are ignored
#   # Empty lines are ignored
#   nvim
#   btop
#   lazygit
#
#   A default config file is created at ~/.config/fish/zellij_manager.conf
#   Edit it to customize which applications trigger tab renaming.
#
# BEHAVIOR:
#   - When you run a TUI app (e.g., nvim), the tab is renamed to the app name
#   - When the app exits, the tab reverts to the directory name
#   - When you change directories, the tab name updates automatically
#   - Git repositories show as "repo/subdir" format
#   - Deep git subdirectories (3+ levels) show as "repo/…/current"
#   - Long names are automatically truncated with ellipsis (…)
#
# TROUBLESHOOTING:
#   - If tabs aren't renaming, check that ZELLIJ environment variable is set
#   - Verify zellij command is available: type -q zellij
#   - Check your environment variables: echo $ZJ_AUTO_RENAME
#   - Test config file: cat ~/.config/fish/zellij_manager.conf
#   - Reload fish config: source ~/.config/fish/config.fish
#
# PERFORMANCE:
#   - Git root is cached per directory to avoid repeated git calls
#   - Non-repo paths (/tmp, /proc, /sys, /dev, /run) skip git checks
#   - Config file is loaded once on shell startup and cached
#   - Template variable expansion only happens when custom pattern is set
#
# =============================================================================

# --- ENVIRONMENT VARIABLE DEFAULTS ---
# User can override these before sourcing this file
# Validate and set defaults for environment variables
if set -q ZJ_AUTO_RENAME
    # Ensure it's 0 or 1
    if not string match -qr '^[01]$' "$ZJ_AUTO_RENAME"
        set -g ZJ_AUTO_RENAME 1
    end
else
    set -g ZJ_AUTO_RENAME 1
end

if set -q ZJ_RENAME_TUI_APPS
    if not string match -qr '^[01]$' "$ZJ_RENAME_TUI_APPS"
        set -g ZJ_RENAME_TUI_APPS 1
    end
else
    set -g ZJ_RENAME_TUI_APPS 1
end

if set -q ZJ_PROJECT_DETECTION
    if not string match -qr '^[01]$' "$ZJ_PROJECT_DETECTION"
        set -g ZJ_PROJECT_DETECTION 0
    end
else
    set -g ZJ_PROJECT_DETECTION 0
end

test -z "$ZJ_CONFIG_FILE" && set -g ZJ_CONFIG_FILE ~/.config/fish/zellij_manager.conf

# --- DEFAULT TUI APPS ---
# Used if config file doesn't exist
set -g ZJ_TUI_APPS_DEFAULT nvim spotify_player spotify-player surge btop lazygit yazi podman-tui bmm wiki-tui bluetui jolt-tui mprocs

# --- LOAD CONFIGURATION ---
set -g ZJ_TUI_APPS
set -g ZJ_CONFIG_LOADED 0

function __zj_load_config
    # Return early if already loaded
    test $ZJ_CONFIG_LOADED -eq 1 && return

    # Check if config file exists and is readable
    if test -f "$ZJ_CONFIG_FILE" -a -r "$ZJ_CONFIG_FILE"
        # Read config file, filter comments and empty lines
        set -l apps (string match -rv '^\s*(#|$)' <"$ZJ_CONFIG_FILE" | string trim)
        if test (count $apps) -gt 0
            set -g ZJ_TUI_APPS $apps
        else
            # Config file exists but empty, use defaults
            set -g ZJ_TUI_APPS $ZJ_TUI_APPS_DEFAULT
        end
    else
        # No config file, use defaults
        set -g ZJ_TUI_APPS $ZJ_TUI_APPS_DEFAULT
    end

    set -g ZJ_CONFIG_LOADED 1
end

# Load config on startup
__zj_load_config

# =============================================================================
# EVENT HANDLERS
# =============================================================================

# 1. EVENT: Pre-execution - Rename tab when TUI app starts
function __zj_preexec_handler --on-event fish_preexec
    # Early returns for disabled features or missing ZELLIJ
    set -q ZELLIJ; or return
    test $ZJ_AUTO_RENAME -eq 1; or return
    test $ZJ_RENAME_TUI_APPS -eq 1; or return

    set -l original_cmd $argv[1]
    # Extract the base command, ignoring sudo/doas/command/builtin prefixes
    set -l bin (string replace -r '^(sudo|doas|command|builtin)\s+' '' $original_cmd | string split " " | head -n 1)

    # Rename tab to the running command if it's a TUI app
    if contains -- $bin $ZJ_TUI_APPS
        type -q zellij && command nohup zellij action rename-tab "$bin" >/dev/null 2>&1
    end
end

# 2. EVENT: Post-execution - Revert to directory name when command finishes
function __zj_postexec_handler --on-event fish_postexec
    set -q ZELLIJ; or return
    test $ZJ_AUTO_RENAME -eq 1; or return

    # Revert tab name to directory when idle
    _zellij_update_tabname
end

# =============================================================================
# TAB NAMING LOGIC
# =============================================================================

# Git root cache - reduces repeated git calls
set -g ZJ_GIT_ROOT_CACHE ""
set -g ZJ_GIT_ROOT_CACHE_DIR ""

# Helper: Detect project name and type from common project files
function __zj_detect_project --argument-names dir
    test $ZJ_PROJECT_DETECTION -eq 0 && return
    test -z "$dir" && return
    
    set -l project_name ""
    set -l project_type ""
    
    # Node.js / JavaScript / TypeScript
    if test -f "$dir/package.json"
        if type -q jq
            set project_name (jq -r '.name // empty' "$dir/package.json" 2>/dev/null)
        else
            # Fallback without jq - simple grep
            set project_name (string match -r '"name"\s*:\s*"([^"]+)"' <"$dir/package.json" | string replace -r '.*"name"\s*:\s*"([^"]+)".*' '$1' 2>/dev/null)
        end
        set project_type "📦"
    # Rust
    else if test -f "$dir/Cargo.toml"
        set project_name (string match -r 'name\s*=\s*"([^"]+)"' <"$dir/Cargo.toml" | head -n 1 | string replace -r '.*name\s*=\s*"([^"]+)".*' '$1' 2>/dev/null)
        set project_type "🦀"
    # Python
    else if test -f "$dir/pyproject.toml"
        set project_name (string match -r 'name\s*=\s*"([^"]+)"' <"$dir/pyproject.toml" | head -n 1 | string replace -r '.*name\s*=\s*"([^"]+)".*' '$1' 2>/dev/null)
        set project_type "🐍"
    # Go
    else if test -f "$dir/go.mod"
        set project_name (string match -r 'module\s+(.+)' <"$dir/go.mod" | head -n 1 | string replace -r 'module\s+(.+)' '$1' | string split "/" | tail -n 1 2>/dev/null)
        set project_type "🐹"
    # Java / Maven
    else if test -f "$dir/pom.xml"
        set project_name (string match -r '<artifactId>([^<]+)</artifactId>' <"$dir/pom.xml" | head -n 1 | string replace -r '.*<artifactId>([^<]+)</artifactId>.*' '$1' 2>/dev/null)
        set project_type "☕"
    end
    
    # Return results via global vars (more efficient than command substitution)
    set -g __ZJ_PROJECT_NAME (string trim "$project_name")
    set -g __ZJ_PROJECT_TYPE "$project_type"
end

# 3. ZELLIJ TAB NAME AUTO-UPDATE - Smart directory-based naming
function _zellij_update_tabname
    # Early returns
    set -q ZELLIJ; or return
    test $ZJ_AUTO_RENAME -eq 1; or return
    type -q zellij; or return

    set -l current_dir $PWD
    
    # Resolve symlinks to real path for more accurate naming
    if test -L "$current_dir"
        set -l real_path (realpath "$current_dir" 2>/dev/null)
        test -n "$real_path" && set current_dir $real_path
    end
    
    # Collect template variables for custom patterns
    set -l dir_name (basename "$current_dir")
    set -l git_root_name ""
    set -l git_branch ""
    set -l git_root ""
    set -l project_name ""
    set -l project_type ""
    
    # Handle edge cases for directory name
    test "$current_dir" = "$HOME" && set dir_name "~"
    test -z "$dir_name" && set dir_name "/"
    
    # Detect project information
    __zj_detect_project "$current_dir"
    set project_name $__ZJ_PROJECT_NAME
    set project_type $__ZJ_PROJECT_TYPE
    
    # Git information gathering (for both default and custom patterns)
    if test "$current_dir" != "$HOME"
        # Check cache first
        if test -n "$ZJ_GIT_ROOT_CACHE_DIR" -a -n "$ZJ_GIT_ROOT_CACHE"
            if string match -q "$ZJ_GIT_ROOT_CACHE_DIR*" "$current_dir"
                set git_root $ZJ_GIT_ROOT_CACHE
            end
        end
        
        # Cache miss - perform git check
        if test -z "$git_root"
            # Skip known non-repo paths for performance
            if not string match -q -r '^/(tmp|proc|sys|dev|run)' "$current_dir"
                set git_root (command git rev-parse --show-toplevel 2>/dev/null)
                if test -n "$git_root"
                    # Update cache
                    set -g ZJ_GIT_ROOT_CACHE $git_root
                    set -g ZJ_GIT_ROOT_CACHE_DIR $git_root
                end
            end
        end
        
        # Get git branch if in a repo
        if test -n "$git_root"
            set git_root_name (basename "$git_root")
            set git_branch (command git branch --show-current 2>/dev/null)
            test -z "$git_branch" && set git_branch (command git rev-parse --short HEAD 2>/dev/null)
        end
    end
    
    set -l tab_name
    
    # Check for custom pattern
    if test -n "$ZJ_TAB_NAME_PATTERN"
        # Expand template variables
        set tab_name $ZJ_TAB_NAME_PATTERN
        set tab_name (string replace -a '{dir}' "$dir_name" "$tab_name")
        set tab_name (string replace -a '{git_root}' "$git_root_name" "$tab_name")
        set tab_name (string replace -a '{git_branch}' "$git_branch" "$tab_name")
        set tab_name (string replace -a '{path}' "$current_dir" "$tab_name")
        set tab_name (string replace -a '{project}' "$project_name" "$tab_name")
        set tab_name (string replace -a '{project_type}' "$project_type" "$tab_name")
        
        # Clean up any remaining empty placeholders
        set tab_name (string replace -ra '\{\w+\}' '' "$tab_name")
        set tab_name (string trim "$tab_name")
        
        # Fallback if pattern resulted in empty string
        test -z "$tab_name" && set tab_name "$dir_name"
    else
        # Default naming logic
        if test "$current_dir" = "$HOME"
            set tab_name "~"
        else
            set tab_name "$dir_name"
            
            # Truncate extremely long directory names (single dir, not git path)
            if test (string length "$tab_name") -gt 40
                set tab_name (string sub -l 37 "$tab_name")…
            end
        end

        # Add git context if available
        if test -n "$git_root"
            # If we are in a subdirectory of the git root, show both
            if test "$git_root" != "$current_dir"
                # For deep git subdirectories (more than 1 level deep), show intermediate path
                set -l relative_path (string replace "$git_root/" "" "$current_dir")
                set -l depth (string split "/" "$relative_path" | count)
                
                if test $depth -gt 2
                    # Deep subdirectory: show repo/…/current
                    set tab_name $git_root_name/…/$dir_name
                else
                    # Truncate long combined names
                    if test (string length "$git_root_name/$dir_name") -gt 40
                        set tab_name (string sub -l 18 "$git_root_name")…/(string sub -l 18 "$dir_name")
                    else
                        set tab_name $git_root_name/$dir_name
                    end
                end
            else
                # We're at git root
                set tab_name "$git_root_name"
            end
        end
    end

    # Sanitize tab name: escape any characters that might cause issues
    # Zellij handles most characters well, but let's be safe with control chars
    set tab_name (string replace -ra '[\x00-\x1f\x7f]' '?' "$tab_name")
    
    # Final truncation if still too long
    if test (string length "$tab_name") -gt 50
        set tab_name (string sub -l 47 "$tab_name")…
    end

    command nohup zellij action rename-tab "$tab_name" >/dev/null 2>&1
end

# =============================================================================
# AUTO-UPDATE HOOKS
# =============================================================================

# Auto update tab name on directory change
function __auto_zellij_update_tabname --on-variable PWD --description "Update zellij tab name on directory change"
    _zellij_update_tabname
end

# Update tab name on shell start
_zellij_update_tabname
