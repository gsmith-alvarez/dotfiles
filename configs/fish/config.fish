# ~/.config/fish/config.fish - Native Fish Shell Configuration

# No "Welcome to fish" banner
set -g fish_greeting ''

# Default editor (yazi etc. read $EDITOR)
set -gx EDITOR nvim
set -gx VISUAL nvim

# Vi key bindings
set -g fish_key_bindings fish_vi_key_bindings

# Clipboard history watcher (login shell)
if status is-login
    if not pgrep -x wl-paste >/dev/null
        wl-paste --type text --watch cliphist store &
        wl-paste --type image --watch cliphist store &
    end
end

if status is-interactive
type -q starship; and starship init fish | source
    if type -q fzf
        fzf --fish | source
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

        set -gx FZF_CTRL_T_OPTS "
          --preview 'if test -d {}; eza --tree --color=always {} | head -200; else; bat -n --color=always --line-range :500 {}; end'
          --bind '?:toggle-preview,ctrl-y:execute-silent(echo -n {} | wl-copy)+abort'
          --preview-window 'right:60%'
        "

        set -gx FZF_ALT_C_OPTS "
          --preview 'eza --tree --color=always {} | head -200'
          --bind 'ctrl-y:execute-silent(echo -n {} | wl-copy)+abort'
          --preview-window 'right:60%'
        "
    end

    type -q zoxide; and zoxide init fish --cmd cd | source
    type -q atuin; and atuin init fish | source
end
