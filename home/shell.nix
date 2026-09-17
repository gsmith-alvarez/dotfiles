{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      starship
      atuin
      lazygit
      navi
      zed-editor
      cliphist
      wl-clipboard
      jq
      spotify-player
      topgrade
      monaspace
      jetbrains-mono
    ];

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
    ];
  };
}
