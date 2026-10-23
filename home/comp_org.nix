{ pkgs, ... }:

let
  riscvToolchain = pkgs.pkgsCross.riscv64-embedded.buildPackages.gcc;

  # Ripes specifically looks for 'riscv64-unknown-elf-gcc' in PATH
  riscvToolchainAliased = pkgs.runCommand "riscv-gcc-ripes-compat" { } ''
    mkdir -p $out/bin
    ln -s ${riscvToolchain}/bin/riscv64-none-elf-gcc $out/bin/riscv64-unknown-elf-gcc
    ln -s ${riscvToolchain}/bin/riscv64-none-elf-g++ $out/bin/riscv64-unknown-elf-g++
    ln -s ${riscvToolchain}/bin/* $out/bin/
  '';

  ripesWrapped = pkgs.symlinkJoin {
    name = "ripes-wrapped";
    paths = [ pkgs.ripes ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/Ripes \
        --prefix PATH : ${
          pkgs.lib.makeBinPath [
            riscvToolchainAliased
            riscvToolchain
          ]
        }
      ln -s Ripes $out/bin/ripes
    '';
  };
in
{
  home.packages = [
    ripesWrapped
  ];
}
