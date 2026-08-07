# nfzf - Fuzzy find files and open in EDITOR
#
# USAGE:
#   nfzf            : Fuzzy search all files in current directory.
#                     Supports multi-select (TAB).
#                     Opens selection in Neovim/EDITOR.
#
# DEPENDENCIES:
#   fd, fzf, bat

function nfzf --description "Fuzzy find files and open in EDITOR"
    set -l editor (set -q EDITOR; and echo "$EDITOR"; or echo nvim)
    set -l files (fd --type f --hidden --exclude .git | fzf -m --preview="bat --color=always {}")
    if test (count $files) -gt 0
        $editor $files
    end
end
