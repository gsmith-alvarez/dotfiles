# ~/.config/fish/conf.d/abbrs.fish - Abbreviations & Aliases

abbr --add cat bat
abbr --add man batman
abbr --add find fd
abbr --add cp 'rsync -avh --info=progress2'
abbr --add rm 'rm -i'
abbr --add rmd 'rm -rf'
abbr --add gd 'git diff'
abbr --add mv 'mv -i'
abbr --add mkdir 'mkdir -p'
abbr --add v nvim
abbr --add ch 'cliphist list | fzf | cliphist decode | wl-copy'
abbr --add cnavi 'navi --cheatsh'
abbr --add hm home-manager
abbr --add hms 'home-manager switch'
abbr --add hmb 'home-manager build'

abbr --add ls eza
abbr --add ll 'eza -lh --grid'
abbr --add la 'eza -a'
abbr --add tree 'eza --tree'

abbr --add u 'fnav up'
abbr --add d 'fnav down'
abbr --add z 'fnav zoxide'
abbr --add sg sgrep

abbr --add copy wl-copy
abbr --add paste wl-paste

abbr --add rg batgrep
abbr --add diff batdiff
abbr --add watch batwatch

abbr --add uvr 'uv run'
abbr --add pytest 'uv run pytest'
