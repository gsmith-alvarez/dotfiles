# sgrep - Interactive Ripgrep (dynamic reloading engine)
#
# USAGE:
#   sgrep [pattern] : Starts in "Ripgrep Mode" (dynamic search).
#                     - Ctrl+F : Toggle between Ripgrep and Fuzzy search mode.
#                     - Enter  : Instantly replace process with Neovim at line.
#
# DEPENDENCIES:
#   ripgrep, fzf, bat, nvim

function sgrep -d "Interactive Ripgrep (dynamic reloading engine)"
    # Delete temp files if they exist to start fresh
    rm -f /tmp/rg-fzf-{r,f}
    
    set -l INITIAL_QUERY (test (count $argv) -gt 0; and echo $argv[1]; or echo "")
    set -l rg_cmd "rg --column --line-number --no-heading --color=always --smart-case"
    
    # Run fzf with advanced transform logic to toggle between ripgrep mode and fuzzy mode
    fzf --ansi --disabled --query "$INITIAL_QUERY" \
        --bind "start:reload:$rg_cmd {q}" \
        --bind "change:reload:sleep 0.1; $rg_cmd {q} || true" \
        --bind 'ctrl-f:transform:[[ ! $FZF_PROMPT =~ ripgrep ]] &&
            echo "rebind(change)+change-prompt(rg> )+disable-search+transform-query:echo \\{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
            echo "unbind(change)+change-prompt(fzf> )+enable-search+transform-query:echo \\{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
        --prompt="rg> " \
        --header="CTRL-F: Toggle Ripgrep / FZF mode" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
        --bind 'enter:become($EDITOR "+{2}" "{1}")'
end
