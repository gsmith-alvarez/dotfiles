# fenv - Fuzzy search environment variables and copy value
#
# USAGE:
#   fenv            : Fuzzy search all active environment variables.
#                     Selecting one will copy its value to the clipboard.
#
# DEPENDENCIES:
#   fzf, wl-copy

function fenv --description "Fuzzy search environment variables and copy value"
    # 1. Use set --show to get all fish variables and their values
    # 2. Pipe to fzf, using the variable name as the list item
    # 3. Preview shows the full content of the variable
    set -l var (set --names | fzf --reverse --height=40% \
        --prompt="env> " \
        --preview="set --show {}" \
        --preview-window="right:60%:wrap")

    if test -n "$var"
        # Extract just the value(s) of the variable.
        # $$var gets the value of the variable whose name is stored in $var
        # string join \n handles array variables by putting them on new lines
        set -l val (string join \n $$var)
        echo -n "$val" | wl-copy
        echo "📋 Copied value of \$$var to clipboard."
    end
end
