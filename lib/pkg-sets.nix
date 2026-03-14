# lib/pkg-sets.nix — single source of truth for all package sets.
#
# ADR-001: shared between home-manager and devShell consumers.
# Consumers import this file and take what they need:
#
#   let pkgSets = import ./lib/pkg-sets.nix { inherit pkgs; };
#   in pkgSets.core ++ pkgSets.shell ++ pkgSets."dev-tools"
#
# Batch 0.5: inner-circle skeleton (core + shell + dev-tools).
# Batch 2 adds: rustToolchain + nightlyToolchain arguments + rust-* sets.
# Batch 3 adds: ai + human-tui + human-editor + nix-tools sets.
{ pkgs }:
{
  # ── Inner circle ────────────────────────────────────────────────────────────
  # Pure flake, stable toolchain only. CI gate runs from this circle.
  # Guarantee level: [GUARANTEED]

  core = with pkgs; [
    git
    curl
    wget
    file
    unzip
  ];

  shell = with pkgs; [
    zsh
    starship
    direnv
    fzf
    zoxide
    atuin
  ];

  "dev-tools" = with pkgs; [
    ripgrep    # rg — fast grep
    fd         # find replacement
    bat        # cat with syntax highlighting
    eza        # ls replacement (replaces exa)
    delta      # git diff pager
    jaq        # jq replacement (5-10x faster; keep yq-go for YAML)
    yq-go      # YAML processor (alongside jaq)
    bottom     # btm — htop replacement (replaces htop)
    gh         # GitHub CLI
    ripgrep-all # rga — grep PDFs, Office docs, archives
    nixd       # Nix language server (replaces nil)
    jujutsu    # jj — modern VCS
  ];

  # ── Controlled circle ───────────────────────────────────────────────────────
  # Batch 2: nightly toolchain (pinned date) + build-speed tools.
  # Guarantee level: [ADVISORY nightly-YYYY-MM-DD]

  # ── Research circle ─────────────────────────────────────────────────────────
  # Batch 3: AI tools + human TUI + editor. Requires --impure.
  # Guarantee level: [EXPERIMENTAL]
}
