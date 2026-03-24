# 🔬 Research & Implementation TODOs

This list contains high-potential "Modern Unix" tools already in my `mise` stack that I want to push to their absolute limits.

---

## 🗂️ CLI Tools & Workflows

- [ ] **navi (Interactive Cheatsheet)**
    - [ ] Research: "Custom navi cheatsheets with fzf scripts."
    - [ ] Goal: Build a custom cheatsheet library that uses `fzf` to pick between dynamic variables (e.g., picking a Docker container or Git branch directly from a `navi` prompt).
    - [ ] [GitHub: denisidoro/navi](https://github.com/denisidoro/navi)

- [ ] **ast-grep (Structural Search & Rewrite)**
    - [ ] Research: "ast-grep scan rules" and "ast-grep rewrite patterns."
    - [ ] Goal: Move beyond regex-based search. Create rules to find "structural" smells in code (e.g., too many function arguments, missing React keys) that `ripgrep` cannot catch.
    - [ ] [GitHub: ast-grep/ast-grep](https://github.com/ast-grep/ast-grep)

- [ ] **gum (Interactive Shell UI)**
    - [ ] Research: "gum shell script examples" and "glamorous shell scripts."
    - [ ] Goal: Use `gum` to create professional-feeling "Dev-Onboarding" or "Deploy" scripts with spinners, big confirmation buttons, and interactive multi-select menus.
    - [ ] [GitHub: charmbracelet/gum](https://github.com/charmbracelet/gum)

- [ ] **direnv + mise (Context-Aware Environments)**
    - [ ] Research: "direnv and mise integration" and "direnv layout python/node."
    - [ ] Goal: Implement "Zero-Config" project entry. Make the shell automatically activate the correct `venv`, `node_modules`, and local aliases the moment I `cd` into a directory.
    - [ ] [GitHub: direnv/direnv](https://github.com/direnv/direnv)

- [ ] **just (The Project Command Center)**
    - [ ] Research: "Advanced justfile recipes" and "justfile multi-language recipes."
    - [ ] Goal: Turn my `justfile` into a project-wide "App Gallery." Use it to orchestrate complex multi-language tasks (e.g., a Python data script that feeds into a Rust build).
    - [ ] [GitHub: casey/just](https://github.com/casey/just)

- [x] **difftastic (Structural Git Diffs)**
    - [x] Implementation: Added to global Git config as `diff.external` and configured in `lazygit/config.yml`.
    - [x] [GitHub: Wilfred/difftastic](https://github.com/Wilfred/difftastic)

---

## 🏗️ Architecture & Core Neovim

- [ ] **Native Package Management (`vimpack`)**
    - [ ] Research: "Neovim vimpack release notes and migration guides."
    - [ ] Goal: Refactor the plugin architecture to migrate away from `mini.deps` to the upcoming native `vimpack` system once it is officially released, adhering strictly to the "Native-First / Zero-Proxy" philosophy.

---

## 🗄️ Database & Intelligence

- [ ] **vim-dadbod (Database Management in Neovim)**
    - [ ] Research: "vim-dadbod + vim-dadbod-ui + vim-dadbod-completion setup."
    - [ ] Goal: Transform Neovim into a lightweight, powerful database client. Execute queries against live SQLite/PostgreSQL databases directly from the editor with real-time autocompletion.
    - [ ] [GitHub: tpope/vim-dadbod](https://github.com/tpope/vim-dadbod)

---

## 🔍 Inspiration Sources
- **GitHub:** [Awesome-CLI List](https://github.com/agarrharr/awesome-cli-apps)
- **Dotfiles Research:** 
    - [ThePrimeagen's Dotfiles](https://github.com/ThePrimeagen/init.lua)
    - [Christian Chiarulli (ChrisAtMachine)](https://github.com/ChristianChiarulli/LunarVim)
