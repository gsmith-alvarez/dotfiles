# fcopy - Fuzzy find a directory in HOME and copy its full path to clipboard
#
# USAGE:
#   fcopy           : Interactively select a directory in $HOME (up to 4 levels deep)
#                     to copy its absolute path to the system clipboard.
#
# DEPENDENCIES:
#   fd, fzf, eza, wl-copy

function fcopy --description "Fuzzy find a directory in HOME and copy its full path to clipboard"
    # 1. Run from HOME so fd outputs relative paths naturally
    # 2. Increased max-depth to 4
    set -l selection (cd $HOME; and fd --type d --max-depth 4 --hidden --exclude .git | fzf --height=40% --layout=reverse \
        --prompt="copy path (~/)> " \
        --preview="eza --tree --level=1 --icons --color=always {}" \
        --preview-window="right:60%")

    if test -n "$selection"
        # Form the absolute path
        # Removing any trailing slashes just in case, before joining
        set -l clean_selection (string replace -r '/$' '' -- $selection)
        set -l fullpath "$HOME/$clean_selection"

        # Using wl-copy as identified in your config.fish abbreviations
        echo -n "$fullpath" | wl-copy
        echo "📋 Copied: $fullpath"
    end
end
