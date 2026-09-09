# Only source cargo env if rustup has been set up on this machine
if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end
