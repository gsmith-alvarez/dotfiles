# --- CONFIGURATION ---
set -g ZJ_TUI_APPS nvim spotify_player spotify-player surge btop lazygit yazi podman-tui bmm wiki-tui bluetui jolt-tui mprocs

# 1. EVENT: Pre-execution
function __zj_preexec_handler --on-event fish_preexec
    set -q ZELLIJ; or return

    set -l original_cmd $argv[1]
    # Extract the base command, ignoring sudo/doas/command/builtin prefixes
    set -l bin (string replace -r '^(sudo|doas|command|builtin)\s+' '' $original_cmd | string split " " | head -n 1)

    # Rename tab to the running command if it's a TUI app
    if contains -- $bin $ZJ_TUI_APPS
        command nohup zellij action rename-tab "$bin" >/dev/null 2>&1
    end
end

# 2. EVENT: Post-execution
function __zj_postexec_handler --on-event fish_postexec
    set -q ZELLIJ; or return

    # Revert tab name to directory when idle
    _zellij_update_tabname
end

# 3. ZELLIJ TAB NAME AUTO-UPDATE
function _zellij_update_tabname
    set -q ZELLIJ; or return

    set -l current_dir $PWD
    set -l tab_name
    if test "$current_dir" = "$HOME"
        set tab_name "~"
    else
        set tab_name (basename "$current_dir")
    end

    if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        # we are in a git repo
        set -l git_root (command git rev-parse --show-superproject-working-tree 2>/dev/null)
        if test -z "$git_root"
            set git_root (command git rev-parse --show-toplevel 2>/dev/null)
        end

        # if we are in a subdirectory of the git root, use the relative path
        if test -n "$git_root"; and test (string lower "$git_root") != (string lower "$current_dir")
            set tab_name (basename "$git_root")/(basename "$current_dir")
        end
    end

    command nohup zellij action rename-tab "$tab_name" >/dev/null 2>&1
end

# auto update tab name on directory change
function __auto_zellij_update_tabname --on-variable PWD --description "Update zellij tab name on directory change"
    _zellij_update_tabname
end

# Update tab name on shell start
_zellij_update_tabname
