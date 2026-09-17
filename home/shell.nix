{ pkgs, ... }:
{
  home = {
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
    ];

    packages = with pkgs; [
      atuin
      navi
      starship
    ];
  };
}
