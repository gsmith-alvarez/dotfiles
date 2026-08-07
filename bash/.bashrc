# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Source Rust toolchain if present
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# Source modular configurations
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        [ -f "$rc" ] && . "$rc"
    done
    unset rc
fi

# Auto-exec Fish for interactive shells (falls back to Bash if Nix path is broken)
if [[ $- == *i* ]] && [ -x "$HOME/.nix-profile/bin/fish" ]; then
    exec "$HOME/.nix-profile/bin/fish"
fi
