# fnav - Fuzzy navigate directories (up/down/zoxide)
#
# USAGE:
#   fnav            : Fuzzy search subdirectories (downwards)
#   fnav up / -u    : Fuzzy search parent directories (upwards)
#   fnav z / -z     : Fuzzy search zoxide frecency database
#   fnav <path>     : Standard cd but registers path with zoxide
#
# KEYBINDINGS (Inside FZF):
#   ctrl-h          : Toggle hidden files (down mode)
#   ctrl-g          : Toggle git-ignore / reload list (down/zoxide mode)
#
# DEPENDENCIES:
#   fd, fzf, zoxide, eza

function fnav --description "Fuzzy navigate directories (up/down/zoxide)"
    set -l mode "down" # default mode
    # Check if eza is available (do this once)
    set -l has_eza (type -q eza; and echo 1; or echo 0)
    # Parse optional argument
    if test (count $argv) -gt 0
        switch $argv[1]
            case "up" "-u" "--up"
                set mode "up"
            case "down" "-d" "--down"
                set mode "down"
            case "zoxide" "z" "-z" "--zoxide"
                set mode "zoxide"
            case "*"
                if test -d "$argv[1]"
                    zoxide add "$argv[1]"
                    cd "$argv[1]"
                    commandline -f repaint
                    return
                end
                echo "Usage: fnav [up|down|zoxide] OR fnav <path>" >&2
                return 1
        end
    end

    set -l target ""
    # Create preview command based on eza availability
    set -l preview_cmd "ls -R --color=always {}"
    if test $has_eza -eq 1
        # Level 2 tree depth for better context-aware browsing
        set preview_cmd "eza --tree --level=2 --icons --color=always --group-directories-first {}"
    end

    if test "$mode" = "up"
        set -l dirs
        set -l current_dir (pwd)
        while test "$current_dir" != "/"
            set current_dir (dirname "$current_dir")
            set -a dirs "$current_dir"
        end

        if test (count $dirs) -eq 0
            echo "Already at root directory."
            return
        end

        set target (printf "%s\n" $dirs | fzf --tac --height=50% --popup=50% --layout=reverse \
            --prompt="parent> " \
            --preview="$preview_cmd" \
            --preview-window="right:60%" \
            --no-track)

    else if test "$mode" = "down"
        # Bindings: ctrl-h to show/hide hidden, ctrl-g to toggle git-ignore logic
        set target (fd --type d --hidden --exclude .git . | fzf --height=50% --popup=50% --layout=reverse --id-nth 1 \
            --prompt="subdir> " \
            --preview="$preview_cmd" \
            --preview-window="right:60%" \
            --bind "ctrl-h:reload(fd --type d --hidden --exclude .git .)" \
            --bind "ctrl-g:reload(fd --type d --exclude .git .)")

    else if test "$mode" = "zoxide"
        # query zoxide for frecency paths, exclude current directory
        set -l current_dir (pwd | string replace -r '/$' '')
        set -l escaped_dir (string escape --style=regex "$current_dir")
        # Binding: ctrl-g to refresh zoxide list
        set target (zoxide query -l 2>/dev/null | string match -v -r "^$escaped_dir/?\$" | fzf  --height=50% --popup=50% --layout=reverse --id-nth 1 \
            --prompt="zoxide> " \
            --preview="$preview_cmd" \
            --preview-window="right:60%" \
            --bind "ctrl-g:reload(zoxide query -l)" \
            --no-track)
    end

    if test -n "$target"
        # Register the jump with zoxide database explicitly
        zoxide add "$target"
        cd "$target"
        commandline -f repaint
    end
end
