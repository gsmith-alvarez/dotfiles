# fbr - Fuzzy checkout git branch
#
# USAGE:
#   fbr             : View all git branches (local and remote).
#                     Selecting one will automatically checkout/switch to it.
#                     Preview window shows the branch's recent history.
#
# DEPENDENCIES:
#   fzf, git

function fbr --description "Fuzzy checkout git branch"
    _check_deps fzf git; or return 1
    
    # Ensure we are in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository." >&2
        return 1
    end

    # 1. Get all branches (local and remote), colorized
    # 2. fzf with a preview of the branch's git log
    set -l branch (git branch --all --color=always --format="%(HEAD) %(color:yellow)refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative))" | \
        fzf --ansi --reverse --height=60% \
        --prompt="checkout> " \
        --preview='git log --color=always --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" (string match -r "([^ *]+) -" {})[2] | head -n 50' \
        --preview-window='right:60%')

    # If a branch was selected, extract its name and check it out
    if test -n "$branch"
        # Extract the branch name (removing the *, spaces, and the commit message part)
        set -l branch_name (string match -r "([^ *]+) -" "$branch")[2]
        
        # If it's a remote branch, remove the remote name (e.g., origin/) for checkout
        if string match -q "origin/*" "$branch_name"
            set branch_name (string replace "origin/" "" "$branch_name")
        end

        echo "Switching to $branch_name..."
        git checkout "$branch_name"
    end
end
