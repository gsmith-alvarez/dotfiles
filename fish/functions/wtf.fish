function wtf -d "Debug recent shell history with aider"
    _check_deps atuin aider; or return 1
    
    # Configurable history limit
    set -l limit 5
    if set -q FISH_WTF_LIMIT
        set limit $FISH_WTF_LIMIT
    end
    
    # 1. Grab history
    set -l recent_history (atuin search --limit $limit --format "CMD: {command} (EXIT: {exit})" 2>/dev/null)
    if test -z "$recent_history"
        echo "Error: No command history available from atuin" >&2
        return 1
    end
    
    # 2. Capture the actual output of the last failed command (if possible)
    # Note: This is a 'best effort' capture for a smarter context.
    echo "🩺 Aider is diagnosing your terminal..."
    
    set -l prompt "Identify why the command failed. 
    Look at the exit code and history. If the command output is available, use it.
    
    History:
    $recent_history"

    # 3. Use 'ask' mode with the context of your history
    aider --chat-mode ask --message "$prompt"
end
