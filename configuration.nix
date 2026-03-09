{ config, pkgs, lib, ... }:

{
  # ── WSL ──────────────────────────────────────────────────────
  wsl.enable = true;
  wsl.defaultUser = "eouzoe";
  wsl.wslConf.automount.root = "/mnt";
  wsl.wslConf.interop.appendWindowsPath = false; # 不污染 PATH

  # ── System ───────────────────────────────────────────────────
  networking.hostName = "apeiron";
  time.timeZone = "Asia/Taipei";

  # ── Nix ──────────────────────────────────────────────────────
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true; # WSL 磁碟空間有限
      trusted-users = [ "root" "eouzoe" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # ── User ─────────────────────────────────────────────────────
  users.users.eouzoe = {
    isNormalUser = true;
    home = "/home/eouzoe";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "kvm" ];
  };

  programs.zsh.enable = true;

  # ── System packages (minimal — user tools go in home.nix) ───
  environment.systemPackages = with pkgs; [
    curl
    wget
    htop
    file
    unzip
  ];

  # ── KVM (for Firecracker) ───────────────────────────────────
  # WSL2 需要 nestedVirtualization=true 在 .wslconfig
  # NixOS 側只需確保 kvm group 存在
  users.groups.kvm = {};

  # ── Podman (for SearXNG) ────────────────────────────────────
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # docker CLI alias
  };

  # ── Security ────────────────────────────────────────────────
  security.sudo.wheelNeedsPassword = false; # WSL 單人機

  system.stateVersion = "25.05";
}
