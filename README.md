# oikos

A declarative development environment built on NixOS.

The name comes from the Greek οἶκος — *dwelling*, *household*. A well-ordered
home from which all work begins. Companion to
[Apeiron](https://github.com/eouzoe/Apeiron), the deterministic execution
fabric.

## Philosophy

A development environment ought to be:

- **Reproducible.** Given the same inputs, every machine converges to the same
  state. No "works on my machine." No tribal knowledge hidden in shell history.
- **Declarative.** The configuration *is* the documentation. If something is not
  in the Nix files, it does not exist.
- **Minimal.** Every installed tool earns its place. Defaults are considered
  carefully; nothing is included merely because it is fashionable.
- **Layered.** System configuration and project toolchains are separate concerns.
  One may use a project's `flake.nix` without adopting the full environment, or
  adopt the full environment to gain a richer experience.

## Quick start

**With NixOS-WSL** (full experience):

```sh
git clone https://github.com/eouzoe/oikos /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#apeiron
```

**With any Nix installation** (project-level only):

```sh
git clone https://github.com/eouzoe/Apeiron
cd Apeiron
nix develop   # no oikos required
```

## What you get

| Layer | Provided by | Contents |
|-------|-------------|----------|
| System | `configuration.nix` | WSL integration, Podman, KVM/Firecracker, Nix gc |
| User | `home.nix` | Zsh, Starship, Git+Delta, direnv, fzf, zoxide, bat, eza |
| Rust | `home.nix` | Stable toolchain, rust-analyzer, 12 cargo extensions |
| Project | Each project's `flake.nix` | Project-specific tools, devShell variants |

## Usage

```sh
just setup      # apply configuration (first time or after changes)
just rebuild    # alias for setup
just dry        # preview changes without applying
just update     # update all flake inputs
just status     # show system generations and flake metadata
just customise  # open home.nix in $EDITOR
```

## Structure

```
oikos/
├── flake.nix           NixOS system entry point
├── flake.lock          Pinned dependencies
├── configuration.nix   System-level: WSL, networking, services
├── home.nix            User-level: shell, tools, programme configuration
├── justfile            Common operations
└── .gitleaks.toml      Secret scanning configuration
```

## Layered architecture

```
┌─────────────────────────────────────────────┐
│  Project devShell  (Apeiron, bose-search)   │  ← each project's flake.nix
├─────────────────────────────────────────────┤
│  User environment  (home.nix)               │  ← this repository
├─────────────────────────────────────────────┤
│  System layer      (configuration.nix)      │  ← this repository
├─────────────────────────────────────────────┤
│  NixOS + WSL2                               │
└─────────────────────────────────────────────┘
```

Projects are self-contained. A contributor who only has Nix (not NixOS) runs
`nix develop` inside the project repository and receives the full toolchain.
Oikos adds the surrounding environment — shell configuration, system services,
editor integration — but is never a hard dependency.

## Roadmap

### v0.1 — Foundation ✓ (current)
- [x] NixOS-WSL baseline — `configuration.nix`, networking, KVM, Podman
- [x] Home Manager — Zsh, Starship, Git+Delta, direnv, fzf, zoxide, bat, eza
- [x] Rust toolchain — stable + rust-analyzer + 12 cargo extensions via rust-overlay
- [x] Dual devShell — `default` (agent, minimal) + `human` (interactive + MoonBit)
- [x] `justfile` workflow — setup, dry, update, status, gc, check

### v0.2 — Security & Stability
- [ ] sops-nix secrets management — replace `~/.secrets.env` with age-encrypted secrets
- [ ] WSL2 systemd workaround — address `user@1000` cgroup race condition (microsoft/WSL#13826)
- [ ] Cachix binary cache — pre-built derivations for faster contributor onboarding

### v0.3 — Developer Experience
- [ ] Gate tiers in justfile — loop (<5s), commit (<30s), PR (<5min), weekly (<60min)
- [ ] NixOS shared overlays — common derivations across projects (MoonBit, custom tools)
- [ ] MoonBit Nix derivation — pin version via `fetchurl`, replace impure curl install

### v0.4 — Verification Infrastructure
- [ ] MoonBit Wasm oracle infrastructure — `#declaration_only` specs, WIT interfaces, wasmtime integration
- [ ] Audit queue foundation — ractor supervision + wasmtime sandboxing

## Licence

The configuration files in this repository are released under
[MIT](https://opensource.org/licenses/MIT). Use them as you wish.
