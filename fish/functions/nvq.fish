function nvq --description "Ripgrep results directly into Neovim Quickfix list"
    _check_deps rg nvim; or return 1
    
    if test (count $argv) -eq 0
        echo "Usage: nvq <search_pattern> [path]" >&2
        return 1
    end

    # 1. Run ripgrep in vimgrep format (file:line:col:text)
    # 2. Pipe into Neovim
    # 3. '-q -' tells Neovim to read the quickfix list from stdin
    rg --vimgrep $argv | nvim -q -
end
