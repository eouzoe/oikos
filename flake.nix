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

  outputs = { self, nixpkgs, nixos-wsl, home-manager, rust-overlay, ... }: {
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
