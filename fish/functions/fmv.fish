# fmv - Fuzzy move files/directories
#
# USAGE:
#   fmv             : Interactively select sources and then select destination.
#   fmv <sources>   : Skip source selection and just select destination.
#
# DEPENDENCIES:
#   fd, fzf, bat, eza

function fmv --description "Fuzzy move files/directories"
    set -l sources

    # 1. Determine sources
    if test (count $argv) -gt 0
        # If arguments are provided, use them as the sources
        set sources $argv
    else
        # Select sources using fzf (multi-select enabled)
        set sources (fd --hidden --exclude .git | fzf -m \
            --prompt="source(s)> " \
            --header="[TAB] to multi-select, [ENTER] to confirm" \
            --preview="bat --color=always {} 2>/dev/null || eza --tree --level=1 --icons --color=always {}" \
            --preview-window="right:60%")
            
        if test -z "$sources"
            echo "Cancelled fmv (no sources selected)."
            return 1
        end
    end

    # 2. Determine destination
    # We inject "." (current) and ".." (parent) at the top of the fd directory list so you can easily move things up or here
    set -l dest (begin; echo "."; echo ".."; fd --type d --hidden --exclude .git; end | fzf \
        --prompt="destination> " \
        --header="Select destination directory for $(count $sources) item(s)" \
        --preview="eza --tree --level=1 --icons --color=always {} 2>/dev/null" \
        --preview-window="right:60%")

    # 3. Execute move
    if test -n "$dest"
        for src in $sources
            # Use command mv -i to ensure it prompts before overwriting files
            command mv -i "$src" "$dest/"
        end
        echo "✅ Moved $(count $sources) item(s) to $dest/"
    else
        echo "Cancelled fmv (no destination selected)."
    end
end
