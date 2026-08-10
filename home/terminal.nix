{ pkgs, ... }:

{
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;

    # Let Atuin manage Ctrl-R
    historyWidget.command = "";

    defaultOptions = [
      "--height=50%"
      "--layout=reverse"
      "--border=rounded"
      "--margin=1"
      "--padding=1"
      "--info=inline-right"
      "--color=border:#6c7086,header:#fab387,info:#cba6f7,pointer:#f5e0dc,prompt:#cba6f7,hl:#f38ba8,hl+:#f38ba8"
      "--walker-skip .git,node_modules,target,.cache,dist,.next"
      "--bind 'ctrl-b:preview-half-page-up,ctrl-d:preview-half-page-down'"
    ];

    fileWidget.options = [
      "--preview 'if test -d {}; eza --tree --color=always {} | head -200; else; bat -n --color=always --line-range :500 {}; end'"
      "--bind '?:toggle-preview,ctrl-y:execute-silent(echo -n {} | wl-copy)+abort'"
      "--preview-window 'right:60%'"
    ];

    changeDirWidget.options = [
      "--preview 'eza --tree --color=always {} | head -200'"
      "--bind 'ctrl-y:execute-silent(echo -n {} | wl-copy)+abort'"
      "--preview-window 'right:60%'"
    ];
  };

  programs.starship = {
    enable = true;
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
    icons = "auto";
    extraOptions = [
      "--hyperlink"
      "--group-directories-first"
    ];
  };

  programs.yazi = {
    enable = true;
    enableFishIntegration = false; # Using custom y.fish wrapper with zoxide support
  };

  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [
      batgrep
      batman
      batpipe
      batwatch
      prettybat
    ];
  };

  home.packages = with pkgs; [
    fish
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
    ghostty
    spotify-player
    topgrade
  ];

  # Ghostty terminfo: env var + .terminfo symlink so ncurses finds xterm-ghostty.
  home.sessionVariables.TERMINFO_DIRS = "${pkgs.ghostty}/share/terminfo";
  home.file.".terminfo".source = "${pkgs.ghostty}/share/terminfo";
}
