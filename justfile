# oikos — declarative development environment

# Lint and validate configuration
check:
    nix flake check --no-build /etc/nixos
    nix-instantiate --eval /etc/nixos --attr nixosConfigurations.apeiron.config.system.build.toplevel > /dev/null

# Apply configuration (first time or after changes)
setup: check
    sudo nixos-rebuild switch --flake /etc/nixos#apeiron

# Alias for setup
rebuild: setup

# Preview changes without applying
dry:
    nixos-rebuild dry-activate --flake /etc/nixos#apeiron 2>&1
    home-manager build --flake /etc/nixos#eouzoe 2>&1 | tail -5

# Update all flake inputs
update:
    nix flake update --flake /etc/nixos
    @echo "Inputs updated. Run 'just rebuild' to apply."

# Show system generations and flake metadata
status:
    @echo "Generations"
    @echo "==========="
    @nixos-rebuild list-generations 2>/dev/null | tail -5
    @echo ""
    @echo "Flake inputs"
    @echo "============"
    @nix flake metadata /etc/nixos 2>/dev/null | sed -n '/Inputs:/,$$p'

# Open home.nix in $EDITOR
customise:
    $EDITOR /etc/nixos/home.nix

# Garbage-collect old generations (keep last 14 days)
gc:
    sudo nix-collect-garbage --delete-older-than 14d
