set -l paths \
    ~/.local/bin \
    ~/.cargo/bin \
    ~/.local/share/mise/shims \
    ~/.nix-profile/bin \
    ~/.local/state/nix/profiles/profile/bin \
    /nix/var/nix/profiles/default/bin

for path in $paths
    if test -d $path
        fish_add_path -g $path
    end
end

set -gx EDITOR nvim
set -gx VISUAL nvim

if status is-login
    if not pgrep -x wl-paste >/dev/null
        wl-paste --type text --watch cliphist store &
        wl-paste --type image --watch cliphist store &
    end
end

if status is-interactive
    set -g fish_key_bindings fish_vi_key_bindings

    type -q mise; and mise activate fish | source
    type -q starship; and starship init fish | source
    if type -q fzf
        fzf --fish | source
        # Global fzf default options (UI/UX updates)
        set -gx FZF_DEFAULT_OPTS "
          --height=50%
          --layout=reverse
          --border=rounded
          --margin=1
          --padding=1
          --info=inline-right
          --color=border:#6c7086,header:#fab387,info:#cba6f7,pointer:#f5e0dc,prompt:#cba6f7,hl:#f38ba8,hl+:#f38ba8
          --walker-skip .git,node_modules,target,.cache,dist,.next
          --bind 'ctrl-b:preview-half-page-up,ctrl-d:preview-half-page-down'
        "

        # Ctrl-T (Files search) preview & copy binding
        set -gx FZF_CTRL_T_OPTS "
          --preview 'if test -d {}; eza --tree --color=always {} | head -200; else; bat -n --color=always --line-range :500 {}; end'
          --bind '?:toggle-preview,ctrl-y:execute-silent(echo -n {} | wl-copy)+abort'
          --preview-window 'right:60%'
        "

        # Alt-C (Directory switcher) preview & copy binding
        set -gx FZF_ALT_C_OPTS "
          --preview 'eza --tree --color=always {} | head -200'
          --bind 'ctrl-y:execute-silent(echo -n {} | wl-copy)+abort'
          --preview-window 'right:60%'
        "
    end

    type -q zoxide; and zoxide init fish --cmd cd | source
    type -q atuin; and atuin init fish | source

    ### Abbreviations
    abbr -a cat bat
    abbr -a man batman
    abbr -a find fd
    abbr -a cp "rsync -avh --info-progress2"
    abbr -a rm "rm -i"
    abbr -a mv "mv -i"
    abbr -a mkdir "mkdir -p"
    abbr -a v nvim
    abbr -a ch "cliphist list | fzf | cliphist decode | wl-copy"
    abbr -a cnavi "navi --cheatsh"

    # eza - ls
    if type -q eza
        alias eza 'eza --icons --hyperlink --group-directories-first'
        abbr -a ls eza
        abbr -a ll 'eza -lh --grid'
        abbr -a la 'eza -a'
        abbr -a tree 'eza --tree'
    end

    # Functions
    abbr -a u 'fnav up'
    abbr -a d 'fnav down'
    abbr -a z 'fnav zoxide'
    abbr -a sg sgrep

    # Clipboard
    abbr -a copy wl-copy
    abbr -a paste wl-paste

    # bat-extas
    abbr -a rg batgrep
    abbr -a diff batdiff
    abbr -a watch batwatch

    #python
    abbr -a uvr 'uv run'
    abbr -a pytest 'uv run pytest'

end
