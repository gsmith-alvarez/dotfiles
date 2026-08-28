final:

let
  cargoTool = (import ./cargo.nix { rustPlatform = final.rustPlatform; });
  buntool   = (import ./bun.nix { stdenv = final.stdenv; bun = final.bun; });
in
{
  fsel = cargoTool {
    name = "fsel";
    version = "3.6.0";
    src = final.fetchFromGitHub {
      owner = "Mjoyufull";
      repo = "fsel";
      rev = "84f2b4b5004c66f1d32009ba008aee0b3b4ebbb4";
      hash = "sha256-yUenkuZ5ryUSpeGjJPO7xgbMObZ5SeBs8/LKU3ROo4g=";
    };
    cargoHash = "sha256-WmHrMALgP52OJH1acrB7DMgo/8FMgksPyXpeRL9Q7s0=";
  };
}