{
  description = "eouzoe — NixOS-WSL developer workstation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, rust-overlay, sops-nix, ... }: {
    nixosConfigurations.apeiron = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-wsl.nixosModules.default
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        ./configuration.nix
        {
          nixpkgs.overlays = [ rust-overlay.overlays.default ];
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.eouzoe = import ./home.nix;
          };
        }
      ];
    };
  };
}
