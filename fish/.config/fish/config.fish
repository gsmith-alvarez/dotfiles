## Some Random Paths
set -l paths \
	~/.local/bin \
	~/.cargo/bin \
	~/.local/mise/shims 

for path in $paths
	if test -d $path; and not contains $path $PATH
		fish_add_path -g $path
	end
end

set -gx EDITOR nvim
set -gx VISUAL nvim

if status is-interactive
	# Using mise in the interactive path to avoid bloating the global path
	type -q starship; and starship init fish | source
	type -q fzf; and fzf --fish | source
	type -q zoxide; and zoxide init fish --cmd cd | source
	type -q atuin; and atuin init fish | source

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



# Commands to run in interactive sessions can go here
end
