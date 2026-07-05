{
  description = "dryvist server A — bare-metal NixOS AI host (standalone, never joins the Proxmox cluster)";

  inputs = {
    # Stable channel pin — Renovate auto-PRs the bump when the next release ships
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };

    # nix-ld is provided by nixpkgs (`programs.nix-ld`). We do not import the
    # nix-community/nix-ld flake — it conflicts with the nixpkgs module
    # ("nix-ld.dev cannot be enabled at the same time as nix-ld").

    # Python toolchain (uv2nix; ADR 0003 picks this over poetry2nix)
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs = {
        pyproject-nix.follows = "pyproject-nix";
        uv2nix.follows = "uv2nix";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      disko,
      sops-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.ai-server-a = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          ./hosts/ai-server-a
          ./modules
        ];
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;

      checks.${system} = import ./lib/checks.nix {
        inherit pkgs;
        inherit (self) nixosConfigurations;
        src = ./.;
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nixfmt-rfc-style
          statix
          deadnix
          sops
          age
          ssh-to-age
        ];
      };
    };
}
