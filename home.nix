{ config, pkgs, lib, ... }:

let
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [ "rust-src" "rust-analyzer" "clippy" ];
    targets = [ "wasm32-unknown-unknown" "x86_64-unknown-linux-musl" ];
  };
in
{
  home.username = "eouzoe";
  home.homeDirectory = "/home/eouzoe";
  home.stateVersion = "25.05";

  # ── Rust ─────────────────────────────────────────────────────
  home.packages = with pkgs; [
    rustToolchain
    # Cargo 生態
    cargo-audit
    cargo-deny
    cargo-insta
    cargo-machete
    cargo-nextest
    cargo-llvm-cov
    cargo-flamegraph
    cargo-watch
    cargo-expand
    cargo-fuzz
    taplo        # TOML LSP + formatter
    typos        # 拼字檢查

    # Node 生態
    nodejs_22
    pnpm
    bun
    # Claude Code: npm install -g @anthropic-ai/claude-code (not in nixpkgs)

    # Python
    uv

    # Dev tools
    gh
    gitleaks
    lefthook
    firecracker
    nixd         # Nix LSP
    nixfmt       # was nixfmt-rfc-style

    # CLI 工具
    ripgrep
    fd
    bat
    eza
    delta
    jq
    yq-go
    fzf
    zoxide

    # sops (secrets)
    sops
    age
  ];

  # ── Shell: Zsh ───────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "eza --icons";
      ll = "eza -la --icons";
      lt = "eza --tree --icons";
      cat = "bat --plain";
      g = "git";
      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline -20";
      nr = "sudo nixos-rebuild switch --flake /etc/nixos#apeiron";
    };

    initContent = ''
      # API keys (遷移後改用 sops-nix)
      [ -f ~/.secrets.env ] && source ~/.secrets.env

      # Claude Code cgroup 限制
      claude() {
        systemd-run --user --scope --quiet \
          -p MemoryHigh=3G -p MemoryMax=5G -p MemorySwapMax=1G \
          -- claude "$@"
      }
    '';

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      share = true;
    };
  };

  # ── Starship prompt ──────────────────────────────────────────
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$rust"
        "$nix_shell"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];
      directory.truncation_length = 3;
      git_branch.format = "[$symbol$branch]($style) ";
      git_status.format = "[$all_status$ahead_behind]($style) ";
      rust.format = "[$symbol($version)]($style) ";
      nix_shell.format = "[$symbol$state]($style) ";
      cmd_duration.min_time = 2000;
      character = {
        success_symbol = "[>](green)";
        error_symbol = "[>](red)";
      };
    };
  };

  # ── Git ──────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "eouzoe";
        email = "114808976+eouzoe@users.noreply.github.com";
      };
      init.defaultBranch = "master";
      push.autoSetupRemote = true;
      pull.rebase = true;
      rerere.enabled = true;
    };
    ignores = [
      ".claude/settings.local.json"
      ".direnv/"
      "result"
    ];
  };

  # ── delta (git diff pager) ───────────────────────────────────
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
    };
  };

  # ── direnv + nix-direnv ──────────────────────────────────────
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ── fzf ──────────────────────────────────────────────────────
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
  };

  # ── zoxide ──────────────────────────────────────────────────
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # ── bat ──────────────────────────────────────────────────────
  programs.bat = {
    enable = true;
    config.theme = "ansi";
  };

  # ── SSH ──────────────────────────────────────────────────────
  programs.ssh = {
    enable = true;
    # Suppress future default-values removal warning
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519";
      };
      # Explicit defaults (previously implicit via enableDefaultConfig)
      "*" = {
        serverAliveInterval = 60;
        forwardAgent = false;
      };
    };
  };

  # ── gh (GitHub CLI) ─────────────────────────────────────────
  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.home-manager.enable = true;
}
