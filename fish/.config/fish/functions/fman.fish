# fman - Fuzzy find man pages and view with batman
#
# USAGE:
#   fman            : Interactively search and preview all system man pages
#   fman <page>     : Open a specific man page directly via batman
#
# DEPENDENCIES:
#   fzf, batman (from bat-extras)

function fman --description "Fuzzy find man pages and view with batman"
    if count $argv > /dev/null
        batman $argv
        return
    end

    # Fetch all man pages, present to fzf
    set -l selected (man -k . | fzf --reverse --height=80% \
        --prompt="man> " \
        --preview="batman {1}" \
        --preview-window="right:60%")

    if test -n "$selected"
        set -l manpage (string split ' ' $selected)[1]
        batman $manpage
    end
end
