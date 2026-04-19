## Some Random Paths
set -l paths \
	~/.local/bin \
	~/.cargo/bin \
	~/.local/share/mise/shims

for path in $paths
	if test -d $path; and not contains $path $PATH
		fish_add_path -g $path
	end
end

set -gx EDITOR nvim
set -gx VISUAL nvim

if status is-interactive
	type -q mise; and mise activate fish | source
	type -q starship; and starship init fish | source
	type -q fzf; and fzf --fish | source
	type -q zoxide; and zoxide init fish --cmd cd | source
	type -q atuin; and atuin init fish | source
    
    fish_vi_key_bindings

	### Abbreviations
	abbr -a cat bat
	abbr -a man batman
	abbr -a find fd
	abbr -a cp "rsync -ah --info-progress2"
	abbr -a rm "rm -i"
	abbr -a mv "mv -i"
	abbr -a v "nvim"

	# eza - ls
	if type -q eza
		abbr -a ls 'eza --icons --group-directories-first'
		abbr -a ll 'eza -lh --icons --grid --group-directories-first'
		abbr -a la 'eza -a --icons --group-directories-first'
		abbr -a tree 'eza --tree --icons'
	end

    # Functions
    abbr -a u 'fnav up'
    abbr -a d 'fnav down'
    abbr -a z 'fnav zoxide'
    abbr -a sg 'sgrep'

	# Clipboard
	abbr -a copy wl-copy
	abbr -a paste wl-paste

	# bat-extas
	abbr -a rg batgrep
	abbr -a diff batdiff
	abbr -a watch batwatch
end
# What I get for uninstalling the cosmic store
set -x XDG_DATA_DIRS /var/lib/flatpak/exports/share $XDG_DATA_DIRS

# Hermes Agent — ensure ~/.local/bin is on PATH
fish_add_path "$HOME/.local/bin"
