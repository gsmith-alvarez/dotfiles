# frepl - Interactive stream processor (gojq, awk, sd, etc.)
#
# USAGE:
#   frepl <file>    : Interactively type a CLI filter (like jq or sd) and
#                     see the results applied to the file in real-time.
#                     Pressing ENTER will execute the pipeline immediately.
#
# DEPENDENCIES:
#   fzf, bat

function frepl --description "Interactive stream processor (gojq, awk, sd, etc.)"
    if test (count $argv) -lt 1
        echo "Usage: frepl <file>"
        echo "Example: frepl data.json"
        echo "Example: frepl server.log"
        return 1
    end

    set -l file $argv[1]

    if not test -f "$file"
        echo "Error: File '$file' not found."
        return 1
    end

    # 1. fzf acts as a prompt.
    # 2. Preview streams the file through the query.
    # 3. Enter executes the stream right there using `become`, so it's instant.
    echo "" | fzf --print-query \
        --prompt="repl> " \
        --preview-window="up:80%:wrap" \
        --preview="cat $file | eval {q} 2>/dev/null | bat --color=always --style=plain" \
        --info=hidden \
        --header="Type a filter command. Press ENTER to execute the pipeline." \
        --bind "enter:become(cat $file | eval {q})"
end
