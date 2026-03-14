{
  description = "eouzoe — NixOS-WSL developer workstation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/refs/tags/2511.7.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: enable when age key management is set up
    # sops-nix = {
    #   url = "github:Mic92/sops-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, rust-overlay, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      # Batch 0.5: inner-circle skeleton only.
      pkgSets = import ./lib/pkg-sets.nix { inherit pkgs; };
    in
    {
    # nix flake check smoke-test: validates pkg-sets.nix evaluates without errors
    # and all package references resolve in nixpkgs.
    checks.${system}.pkg-sets-eval = pkgs.runCommand "pkg-sets-eval" { } ''
      echo "core:      ${toString (builtins.length pkgSets.core)} pkgs"
      echo "shell:     ${toString (builtins.length pkgSets.shell)} pkgs"
      echo "dev-tools: ${toString (builtins.length pkgSets."dev-tools")} pkgs"
      touch $out
    '';

    nixosConfigurations.apeiron = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-wsl.nixosModules.default
        home-manager.nixosModules.home-manager
        # TODO: re-enable when age key management is set up
        # sops-nix.nixosModules.sops
        ./configuration.nix
        {
          nixpkgs.overlays = [ rust-overlay.overlays.default ];
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.eouzoe = import ./home.nix;
          };
          system.configurationRevision = self.rev or "dirty";
        }
      ];
    };
  };
}
