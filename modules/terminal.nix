# Terminal tooling — package installation only.
#
# Tool CONFIGURATION lives in native config files under configs/
# (configs/fish/config.fish inits starship/zoxide/atuin/fzf and owns
# FZF_DEFAULT_OPTS; configs/starship/starship.toml etc.). No
# programs.<tool>.enableFishIntegration here — fish isn't HM-managed, so
# those snippets would never be generated and would just duplicate the
# native config.
{
  pkgs,
  ...
}:

{
  home.packages = with pkgs;
    [
      fish
      bat
      fd
      ripgrep
      ripgrep-all
      rsync
      xh
      tealdeer
      sd
      visidata
      duckdb
      navi
      usage
      ouch
      wl-clipboard
      cliphist
      antigravity-cli
      btop
      fuzzel
      fsel
      # ghostty — installed from system package manager (dnf) instead of Nix
      # because Nix's libglvnd can't find the system Mesa EGL driver on Fedora,
      # causing "Failed to create EGL display" on launch.
      #ghostty
      spotify-player
      topgrade

      # Shell tooling (configured natively, see configs/fish + configs/*)
      zoxide
      fzf
      starship
      atuin
      eza
      yazi
    ]
    ++ (with pkgs.bat-extras; [
      batgrep
      batman
      batpipe
      batwatch
      prettybat
    ]);
}
