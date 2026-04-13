function y --description "Yazi Wrapper"
    set tmp (mktemp -t "yazi-cwd.XXXXXX")

    yazi --cwd-file="$tmp"

    if test -f "$tmp"
        set cwd (cat -- "$tmp")

        if test -n "$cwd"; and test "$cwd" != "$PWD"
            builtin cd -- "$cwd"
            if command -v zoxide >/dev/null
                zoxide add "$cwd"
            end
        end
        rm -f -- "$tmp"
    end
end
