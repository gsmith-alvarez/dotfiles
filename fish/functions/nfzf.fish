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
    _check_deps fd fzf bat; or return 1
    
    set -l files (fd --type f --hidden --exclude .git | fzf -m --preview="bat --color=always {}")
    if test (count $files) -gt 0
        $EDITOR $files
    end
end
