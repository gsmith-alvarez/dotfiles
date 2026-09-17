{
  description = "NixOS configuration";

  # Literal set required here: the flake schema rejects computed nixConfig values.
  # Keep in sync with lib/caches.nix (consumed by modules/core).
  nixConfig = {
    extra-substituters = [
      "https://cache.numtide.com"
      "https://noctalia.cachix.org"
    ];

    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";
    noctalia.url = "github:noctalia-dev/noctalia";

    cargo2nix.url = "github:cargo2nix/cargo2nix";

    pyproject-nix.url = "github:pyproject-nix/pyproject.nix";

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yazi-flavors.url = "github:aguirre-matteo/nix-yazi-flavors";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
      checks.x86_64-linux = import ./checks {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        inherit (nixpkgs) lib;
        home = self.nixosConfigurations.wolfgang.config.home-manager.users.giovanni;
        nixos = self.nixosConfigurations.wolfgang;
        inherit (import ./flake.nix) nixConfig;
      };
      devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        packages = with nixpkgs.legacyPackages.x86_64-linux; [
          nixfmt
          statix
          deadnix
          python3
          fish
          luajit
          niri
          sops
          age
          ssh-to-age
        ];
      };

      # Standalone home-manager config so read-only commands
      # (e.g. `home-manager news --flake .`) work.
      # NOTE: use `nh os switch` for actual activation — the NixOS module owns this.
      homeConfigurations.giovanni = home-manager.lib.homeManagerConfiguration {
        pkgs = self.nixosConfigurations.wolfgang.pkgs;
        modules = [
          ./home
        ];

        extraSpecialArgs = { inherit inputs; };
      };

      nixosConfigurations.wolfgang = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/wolfgang
          ./modules/secrets.nix

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              # Share the system nixpkgs evaluation rather than instantiating a duplicate package set.
              useGlobalPkgs = true;
              # Install user packages directly to /etc/profiles/per-user to integrate with system search paths.
              useUserPackages = true;

              extraSpecialArgs = { inherit inputs; };

              users.giovanni = import ./home;

              # Back up unmanaged conflicting files to .backup instead of aborting activation.
              backupFileExtension = "backup";
            };
          }
        ];
      };
    };
}
