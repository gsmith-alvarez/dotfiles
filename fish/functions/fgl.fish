# fgl - Fuzzy git log with delta diff previews
#
# USAGE:
#   fgl             : View a compressed git log. 
#                     - Enter  : Replace process with a full delta diff view of commit.
#                     - Ctrl+Y : Copy the commit hash to clipboard and exit.
#
# DEPENDENCIES:
#   fzf, git, delta, wl-copy

function fgl --description "Fuzzy git log with delta diff previews"
    _check_deps fzf git delta wl-copy; or return 1
    
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository." >&2
        return 1
    end

    git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" | \
        fzf --ansi --no-sort --reverse --tiebreak=index \
        --preview 'git show --color=always (string split -m 1 " " {})[1] | delta' \
        --preview-window 'right:60%' \
        --bind 'enter:become(git show (string split -m 1 " " {})[1] | delta)' \
        --bind 'ctrl-y:execute(echo -n (string split -m 1 " " {})[1] | wl-copy)+abort' \
        --header="ENTER: View full diff | CTRL-Y: Copy commit hash"
end
