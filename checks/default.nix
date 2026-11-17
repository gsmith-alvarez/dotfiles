{
  pkgs,
  lib,
  homes,
}:
let
  src = ../.;
  flake = import ../flake.nix;
  caches = import ../lib/caches.nix;
  cachesMatch =
    flake.nixConfig.extra-substituters == caches.substituters
    && flake.nixConfig.extra-trusted-public-keys == caches.trusted-public-keys;

  checkLinks =
    hostName: cfg:
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
        entries "" (declared.home.file or { })
        // entries "${cfg.xdg.configHome}/" (declared.xdg.configFile or { })
        // entries "${cfg.xdg.dataHome}/" (declared.xdg.dataFile or { });

      declaredFor =
        evalCfg:
        let
          base = import ../home/dotfiles.nix { config = evalCfg; };
          host = import ../home/hosts/${hostName}.nix { config = evalCfg; };
        in
        lib.recursiveUpdate base host;

      # Compare real symlink derivations, not their external destination strings.
      expected = targets (declaredFor cfg);
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

      # The filesystem validator needs paths relative to the repo root, not store paths.
      mockCfg = {
        home.homeDirectory = homeDir;
        lib.file.mkOutOfStoreSymlink = lib.removePrefix "${homeDir}/dotfiles/";
      };
      manifest = targets (declaredFor mockCfg);
      links = builtins.mapAttrs (_: file: file.source) manifest;
      generated = builtins.filter (target: !(builtins.hasAttr target expected)) (
        builtins.attrNames effective
      );
    in
    # Validate every live owner before excluding its target from generated files.
    assert cachesMatch;
    assert linksMatch;
    pkgs.writeText "links-${hostName}.json" (builtins.toJSON { inherit links generated; });

  wolfgangLinks = checkLinks "wolfgang" homes.wolfgang;
  easleyLinks = checkLinks "easley" homes.easley;
in
{
  link-contract =
    pkgs.runCommand "dotfiles-link-contract"
      {
        nativeBuildInputs = [ pkgs.python3 ];
      }
      ''
        python ${src}/tests/link_contract.py ${src} ${wolfgangLinks}
        python ${src}/tests/link_contract.py ${src} ${easleyLinks}
        touch $out
      '';

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
        deadnix --fail --exclude _sources .
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
        python ${src}/tests/config_syntax.py ${src}/configs ${src}/hosts ${src}/nvfetcher.toml
        for host in wolfgang easley; do
          mkdir -p "$TMPDIR/niri-$host"
          ln -s ${src}/configs/niri/config.kdl "$TMPDIR/niri-$host/config.kdl"
          ln -s ${src}/hosts/$host/niri.kdl "$TMPDIR/niri-$host/host.kdl"
          niri validate -c "$TMPDIR/niri-$host/config.kdl"
        done
        touch $out
      '';
}
