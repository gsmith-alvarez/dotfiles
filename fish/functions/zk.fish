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
    
    # Get existing sessions (suppress errors if none exist)
    set -l sessions (zellij list-sessions -sn 2>/dev/null)
    
    # Check if a session for the current dir already exists
    set -l new_session_opt "✨ Create new session: $current_dir"
    if contains $current_dir $sessions
        set new_session_opt "🔄 Reattach to session: $current_dir"
    end
    
    # Combine options and pass to fzf
    set -l choice (printf "%s\n%s\n" "$new_session_opt" "$sessions" | string match -v -r '^\$' | fzf --prompt="Zellij> " --height=20% --layout=reverse --border)

    if test -z "$choice"
        return 0
    end

    # Handle the choice: If it's the "New/Reattach" option, use the -c flag
    if string match -q "* $current_dir" "$choice"
        zellij attach -c "$current_dir"
    else
        zellij attach "$choice"
    end
end
