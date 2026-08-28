{
  description = "Giovanni's Home Manager Configuration (dotfiles is the source of truth)";

  # For llm-agents
  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

    # Declarative Flatpak management (HM service)
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # uv2nix: build Python venvs from uv.lock (pyproject-nix ecosystem)
    pyproject-nix.url = "github:pyproject-nix/pyproject.nix";
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # cargo2nix: build Rust workspaces from Cargo.nix
    cargo2nix.url = "github:cargo2nix/cargo2nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      neovim-nightly-overlay,
      llm-agents,
      cargo2nix,
      uv2nix,
      pyproject-nix,
      pyproject-build-systems,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          neovim-nightly-overlay.overlays.default
          (final: prev: import ./packages final)
        ];
      };
    in
    {
      homeConfigurations = {
        "laptop" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs self;
          };

          modules = [ ./modules/common.nix ./hosts/laptop ];
        };

        "desktop" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs self;
          };

          modules = [ ./modules/common.nix ./hosts/desktop ];
        };
      };
    };
}
