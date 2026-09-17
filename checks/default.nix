{
  pkgs,
  lib,
  home,
  nixos,
  nixConfig,
}:
let
  src = ../.;
  checkLinks =
    cfg:
    let
      homeDir = cfg.home.homeDirectory;
      relativeTarget = lib.removePrefix "${homeDir}/";
      entries =
        prefix: files:
        lib.mapAttrs' (
          name: file: lib.nameValuePair (relativeTarget "${prefix}${file.target or name}") file
        ) files;
      targets =
        declared:
        entries "" declared.home.file
        // entries "${cfg.xdg.configHome}/" declared.xdg.configFile
        // entries "${cfg.xdg.dataHome}/" declared.xdg.dataFile;

      # Compare real symlink derivations, not their external destination strings.
      expected = targets (import ../home/dotfiles.nix { config = cfg; });
      effective = lib.groupBy (file: relativeTarget file.target) (
        builtins.filter (file: file.enable) (builtins.attrValues cfg.home.file)
      );
      matches =
        target: file:
        let
          actual = effective.${target} or [ ];
        in
        builtins.length actual == 1
        && (builtins.head actual).enable == (file.enable or true)
        && toString (builtins.head actual).source == toString file.source
        && (builtins.head actual).force == (file.force or false);
      linksMatch = lib.all (target: matches target expected.${target}) (builtins.attrNames expected);

      # The filesystem validator needs paths relative to configs/, not store paths.
      manifest = targets (
        import ../home/dotfiles.nix {
          config = {
            home.homeDirectory = homeDir;
            lib.file.mkOutOfStoreSymlink = lib.removePrefix "${homeDir}/dotfiles/configs/";
          };
        }
      );
      links = builtins.mapAttrs (_: file: file.source) manifest;
      generated = builtins.filter (target: !(builtins.hasAttr target expected)) (
        builtins.attrNames effective
      );
    in
    # Validate every live owner before excluding its target from generated files.
    assert linksMatch;
    pkgs.runCommand "dotfiles-link-contract"
      {
        nativeBuildInputs = [ pkgs.python3 ];
      }
      ''
        export PYTHONDONTWRITEBYTECODE=1
        python -m unittest discover -s ${src}/tests -p 'test_*.py' -v
        python ${src}/tests/link_contract.py ${src}/configs ${
          pkgs.writeText "links.json" (builtins.toJSON { inherit links generated; })
        }
        touch $out
      '';
  caches = import ../lib/caches.nix;
in
{
  link-contract =
    assert import ../tests/out-of-store.nix;
    checkLinks home;

  link-contract-regression =
    assert import ../tests/link-contract.nix {
      inherit lib pkgs nixos;
      check = checkLinks;
    };
    pkgs.runCommand "dotfiles-link-contract-regression" { } "touch $out";

  caches =
    assert nixConfig.extra-substituters == caches.substituters;
    assert nixConfig.extra-trusted-public-keys == caches.trusted-public-keys;
    assert (nixos.config.nix.settings.extra-substituters or [ ]) == caches.substituters;
    assert (nixos.config.nix.settings.extra-trusted-public-keys or [ ]) == caches.trusted-public-keys;
    pkgs.runCommand "dotfiles-cache-policy" { } "touch $out";

  nix-style =
    pkgs.runCommand "dotfiles-nix-style"
      {
        nativeBuildInputs = [
          pkgs.nixfmt
          pkgs.statix
          pkgs.deadnix
        ];
      }
      ''
        cd ${src}
        find . -name '*.nix' -type f -exec nixfmt --check {} +
        statix check .
        deadnix --fail .
        touch $out
      '';

  config-syntax =
    pkgs.runCommand "dotfiles-config-syntax"
      {
        nativeBuildInputs = [
          pkgs.python3
          pkgs.fish
          pkgs.luajit
          pkgs.niri
        ];
      }
      ''
        export HOME=$TMPDIR
        python ${src}/tests/config_syntax.py ${src}/configs
        niri validate -c ${src}/configs/niri/config.kdl
        touch $out
      '';
}
