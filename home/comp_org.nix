{ pkgs, ... }:

let
  xpackRiscvToolchain = pkgs.stdenv.mkDerivation rec {
    pname = "xpack-riscv-none-elf-gcc";
    version = "14.2.0-2";

    src = pkgs.fetchurl {
      url = "https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v${version}/xpack-riscv-none-elf-gcc-${version}-linux-x64.tar.gz";
      hash = "sha256-Crk5N6q4gsOmn2Pv9P6PxuNg5KI3dgBPoRataS5pnSM=";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [
      pkgs.libiconv
      pkgs.zlib
      pkgs.ncurses5
      pkgs.stdenv.cc.cc.lib
    ];

    installPhase = ''
      mkdir -p $out
      cp -r * $out/

      # Provide standard aliases expected by Ripes and other toolchains
      for tool in $out/bin/riscv-none-elf-*; do
        name=$(basename "$tool")
        suffix="''${name#riscv-none-elf-}"
        ln -s "$tool" "$out/bin/riscv64-unknown-elf-$suffix"
        ln -s "$tool" "$out/bin/riscv32-unknown-elf-$suffix"
      done
    '';
  };

  ripesWrapped = pkgs.symlinkJoin {
    name = "ripes-wrapped";
    paths = [ pkgs.ripes ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/Ripes \
        --prefix PATH : ${pkgs.lib.makeBinPath [ xpackRiscvToolchain ]} \
        --run '
          conf="''${XDG_CONFIG_HOME:-$HOME/.config}/Ripes/Ripes.conf"
          if [ -f "$conf" ]; then
            current_cc=$(grep -E "^compiler_path=" "$conf" 2>/dev/null | cut -d= -f2- || true)
            if [ -z "$current_cc" ] || [ "$current_cc" = "riscv64-unknown-elf-gcc" ] || [ ! -x "$current_cc" ]; then
              if grep -q "^compiler_path=" "$conf" 2>/dev/null; then
                sed -i "s|^compiler_path=.*|compiler_path=${xpackRiscvToolchain}/bin/riscv64-unknown-elf-gcc|" "$conf" || true
              else
                echo "compiler_path=${xpackRiscvToolchain}/bin/riscv64-unknown-elf-gcc" >> "$conf"
              fi
            fi
          fi
        '
      ln -sf Ripes $out/bin/ripes
    '';
  };
in
{
  home.packages = [
    xpackRiscvToolchain
    ripesWrapped
  ];
}
