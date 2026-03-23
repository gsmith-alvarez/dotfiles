### --- 1. THE ENGINE: MISE (Pre-Interactive) --- ###
# We activate mise first so all managed binaries are immediately available.
if type -q mise
    mise activate fish | source
end

### --- 2. PATH CONSOLIDATION --- ###
# Use a single, unified path addition for non-mise binaries.
fish_add_path -g ~/.local/bin ~/.cargo/bin ~/.lmstudio/bin

# Go Path Sync
if type -q go
    set -gx GOPATH (go env GOPATH)
    fish_add_path -g $GOPATH/bin
end

# Exercism CLI
if test -d ~/bin
    fish_add_path ~/bin
end

### --- 3. INTERACTIVE OPTIMIZATION --- ###
if status is-interactive
    # [[ FAST INITIALIZATION ]]
    # Chain these together to reduce process spawning overhead
    type -q starship; and starship init fish | source
    type -q zoxide; and zoxide init fish --cmd cd | source
    type -q fzf; and fzf --fish | source
    type -q atuin; and atuin init fish --disable-up-arrow | source
    type -q navi; and navi widget fish | source

    # [[ FZF CHANGES ]]

    # Setting fd instead for find and ignoring git folders
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_ALT_C_COMMAND 'fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'

    # [[ UI PREFERENCES ]]
    set -g fish_greeting
    fish_vi_key_bindings

    # [[ USER BINDINGS ]]

    ## [[ VI-MODE RECTIFICATION ]]
    function fish_user_key_bindings
        # 1. Atuin: Bridge Normal and Insert modes
        # This fixes your 'kj' issue. Atuin will now work in Normal Mode.
        bind -M insert \cr _atuin_search
        bind -M default \cr _atuin_search
        bind -M insert \e\[A _atuin_bind_up
        bind -M default \e\[A _atuin_bind_up

        # 2. Navi: Smart Replace
        if type -q navi
            bind -M insert \cg _navi_smart_replace
            bind -M default \cg _navi_smart_replace
            bind -M insert \ee _navi_smart_replace
            bind -M default \ee _navi_smart_replace
        end

        # 3. Autosuggestion Keybinds
        bind -M insert \cf accept-autosuggestion # Ctrl+F: accept whole suggestion (overrides forward-char; use → instead)
        bind -M insert \e\[1\;5C forward-word # Ctrl+→: accept one word at a time
        bind -M insert \cx accept-autosuggestion execute # Ctrl+X: accept suggestion and execute

        # 4. Fuzzy SSH (Ctrl+S)
        bind -M insert \cs fssh
        bind -M default \cs fssh
    end

    # [[ FZF MODAL CATPPUCCIN MOCHA CONFIGURATION ]]
    # Advanced State Machine: Full Vi-Movement Matrix
    set -l peach f9e2af
    set -l lavender b4befe
    set -l flamingo f2cdcd
    set -l surface0 313244
    set -l text cdd6f4

    set -gx FZF_DEFAULT_OPTS "
      --layout=reverse
      --height=40%
      --tmux=70%
      --border
      --info=inline
      --prompt='[I] 󰭎 '
      --pointer=''
      --marker='󰄵 '
      --color='bg+:-1,gutter:-1,spinner:#$flamingo,hl:#$peach'
      --color='fg:#$text,header:#$flamingo,info:#$lavender,pointer:#$lavender'
      --color='marker:#$lavender,fg+:#$text,prompt:#$lavender,hl+:#$peach'
      --color='selected-bg:#$surface0'

      --bind='ctrl-b:preview-page-up,ctrl-f:preview-page-down'

      --bind='j:down,k:up,h:backward-char,l:forward-char'
      --bind='w:forward-word,b:backward-word,x:delete-char,ctrl-d:clear-query,q:abort'

      --bind='i:unbind(j,k,h,l,w,b,x,q,ctrl-d,i)+change-prompt([I] 󰭎 )'
      --bind='esc:rebind(j,k,h,l,w,b,x,q,ctrl-d,i)+change-prompt([N] 󰭎 )'
      --bind='start:unbind(j,k,h,l,w,b,x,q,i)'
    "
    ### --- 4. ABBREVIATIONS & ALIASES --- ###
    abbr -a .. 'cd ..'
    abbr -a ... 'cd ../..'
    abbr -a cat bat
    abbr -a man batman
    abbr -a find fd
    abbr -a yr yazi
    abbr -a fcd fnav
    abbr -a fup 'fnav u'
    abbr -a j 'fnav z'
    abbr -a du "dust -r"
    abbr -a cp "rsync -ah --info=progress2"
    abbr -a rm "rm -i"
    abbr -a mv "mv -i"

    # bat-extras
    abbr -a rg batgrep
    abbr -a diff batdiff
    abbr -a watch batwatch

    # Python (uv)
    abbr -a py "uv run"
    abbr -a pyr "uv run python"
    abbr -a pyv "uv venv"

    # Git
    abbr -a g git
    abbr -a gs 'git status'
    abbr -a ga 'git add'
    abbr -a gc 'git commit -m'
    abbr -a gp 'git push'
    abbr -a gab 'git absorb' # Auto fixup into correct ancestor commit
    abbr -a gl fgl
    abbr -a gb fbr

    # New tools
    abbr -a ps procs # Modern ps
    abbr -a hx hexyl # Hex viewer for binaries/firmware
    abbr -a mp mprocs # Multi-process TUI runner

    # Modern LS (eza)
    if type -q eza
        abbr -a ls 'eza --icons --group-directories-first'
        abbr -a ll 'eza -lh --icons --grid --group-directories-first'
        abbr -a la 'eza -a --icons --group-directories-first'
        abbr -a tree 'eza --tree --icons'
    end

    # Carapace (Completion Engine)
    if type -q carapace
        set -gx CARAPACE_BRIDGES 'zsh,bash,inshellisense,usage'
        carapace _carapace fish | source
    end

    # Clipboard Shortcuts
    abbr -a copy wl-copy
    abbr -a paste wl-paste
    abbr -a v nvim
    abbr -a bk 'bmm tui'
end
