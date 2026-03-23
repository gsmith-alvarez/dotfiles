# zk - Fuzzy manage Zellij sessions
#
# USAGE:
#   zk              : Interactively switch between existing sessions or 
#                     create a new one named after current directory.
#
# DEPENDENCIES:
#   fzf, zellij

function zk --description "Fuzzy manage Zellij sessions"
    # Get current directory name for the "New Session" prompt
    set -l current_dir (basename "$PWD")
    set -l new_session_opt "✨ Create new session: $current_dir"
    
    # Get existing sessions (suppress errors if none exist)
    set -l sessions (zellij list-sessions -sn 2>/dev/null)
    
    # Combine options and pass to fzf
    # Note: Using escaped \$ to prevent fish from treating it as a variable expansion
    set -l choice (printf "%s\n%s\n" "$new_session_opt" "$sessions" | string match -v -r '^\$' | fzf --prompt="Zellij> " --height=20% --layout=reverse --border)

    if test -z "$choice"
        return 0
    end

    # Handle the choice
    if test "$choice" = "$new_session_opt"
        zellij attach -c "$current_dir"
    else
        zellij attach "$choice"
    end
end
