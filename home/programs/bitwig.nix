{ pkgs, ... }:
let
  bitwigWithJack = pkgs.symlinkJoin {
    name = "${pkgs.bitwig-studio.name}-pw-jack";
    paths = [ pkgs.bitwig-studio ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    # Wrap with pw-jack directly so Bitwig uses PipeWire's JACK libraries without global LD_LIBRARY_PATH.
    postBuild = ''
      rm "$out/bin/bitwig-studio"
      makeWrapper "${pkgs.pipewire.jack}/bin/pw-jack" "$out/bin/bitwig-studio" \
        --add-flags "${pkgs.bitwig-studio}/bin/bitwig-studio"
    '';
    inherit (pkgs.bitwig-studio) meta;
  };
in
{
  home.packages = [ bitwigWithJack ];
}
