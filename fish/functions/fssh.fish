# fssh - Fuzzy find SSH hosts and insert into command line
#
# USAGE:
#   <Ctrl+S>        : From a blank prompt, fuzzy select a host to SSH into.
#                     From a partial prompt (like scp), fuzzy select a host 
#                     to append it to the command line.
#
# DEPENDENCIES:
#   fzf, awk

function fssh --description "Fuzzy find SSH hosts and insert into command line"
    # Collect all possible config files that actually exist to avoid wildcard errors
    set -l config_files ~/.ssh/config
    for pattern in ~/.ssh/config.d/* ~/.ssh/conf.d/* ~/.ssh/*.conf
        if test -e "$pattern"
            set -a config_files "$pattern"
        end
    end

    # Parse the verified files for Host entries
    set -l hosts (awk '/^Host / && $2 != "*" {for (i=2; i<=NF; i++) print $i}' $config_files 2>/dev/null)

    if test (count $hosts) -eq 0
        echo "No SSH hosts found in ~/.ssh config files."
        commandline -f repaint
        return
    end

    set -l cmd (commandline)

    if test -z "$cmd"
        # If command line is empty, directly execute ssh using become
        printf "%s\n" $hosts | sort -u | fzf --height=40% --layout=reverse --prompt="ssh> " \
            --bind 'enter:become(ssh {})'
    else
        # If typing a command (like scp), just insert the selected host
        set -l selected_host (printf "%s\n" $hosts | sort -u | fzf --height=40% --layout=reverse --prompt="ssh> ")
        if test -n "$selected_host"
            commandline -i "$selected_host "
        end
    end

    commandline -f repaint
end
