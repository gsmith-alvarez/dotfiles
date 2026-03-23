function fish_title --description "Set the terminal title dynamically"
    # If a command is currently running, its string is passed as argv[1].
    if set -q argv[1]
        echo $argv[1]
    else
        # Otherwise, we are idle at the prompt. Just show the current folder name.
        basename $PWD
    end
end
