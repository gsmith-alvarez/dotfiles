# fnav - Fuzzy navigate directories (up/down/zoxide)
#
# USAGE:
#   fnav            : Fuzzy search subdirectories (downwards)
#   fnav up / -u    : Fuzzy search parent directories (upwards)
#   fnav z / -z     : Fuzzy search zoxide frecency database
#   fnav <path>     : Standard cd but registers path with zoxide
#
# DEPENDENCIES:
#   fd, fzf, zoxide, eza

function fnav --description "Fuzzy navigate directories (up/down/zoxide)"
    set -l mode "down" # default mode
    
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
                if test -d $argv[1]
                    zoxide add $argv[1]
                    cd $argv[1]
                    commandline -f repaint
                    return
                end
                echo "Usage: fnav [up|down|zoxide] OR fnav <path>"
                return 1
        end
    end

    set -l target ""

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

        set target (printf "%s\n" $dirs | fzf --tac --height=40% --layout=reverse \
            --prompt="parent> " \
            --preview="type -q eza; and eza --tree --level=1 --icons --color=always {}; or ls -R --color=always {}" \
            --preview-window="right:60%")

    else if test "$mode" = "down"
        set target (fd --type d --hidden --exclude .git . | fzf --height=40% --layout=reverse \
            --prompt="subdir> " \
            --preview="type -q eza; and eza --tree --level=1 --icons --color=always {}; or ls -R --color=always {}" \
            --preview-window="right:60%")

    else if test "$mode" = "zoxide"
        # query zoxide for frecency paths, exclude current directory
        set -l current_dir (pwd | string replace -r '/$' '')
        set -l escaped_dir (string escape --style=regex "$current_dir")
        set target (zoxide query -l | string match -v -r "^$escaped_dir/?\$" | fzf --height=40% --layout=reverse \
            --prompt="zoxide> " \
            --preview="type -q eza; and eza --tree --level=1 --icons --color=always {}; or ls -R --color=always {}" \
            --preview-window="right:60%")
    end

    if test -n "$target"
        # Register the jump with zoxide database explicitly
        zoxide add "$target"
        cd "$target"
        commandline -f repaint
    end
end
