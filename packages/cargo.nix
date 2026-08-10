# Builds a Rust CLI from an arbitrary source. cargoHash: fill from first build error.
{ rustPlatform, ... }:
{ name, version, src, cargoHash, buildInputs ? [], nativeBuildInputs ? [], ... }:
rustPlatform.buildRustPackage {
  pname = name;
  inherit version src cargoHash buildInputs nativeBuildInputs;
  meta.mainProgram = name;
}