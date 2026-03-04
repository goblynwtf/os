# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Key Commands

```bash
# Apply system + home-manager changes
sudo nixos-rebuild switch --flake .#feywild

# Build without activating (dry run)
sudo nixos-rebuild build --flake .#feywild

# Check flake syntax and evaluation
nix flake check

# Update all flake inputs
nix flake update

# Update a single input (e.g., nixpkgs)
nix flake update nixpkgs

# Search for a package
nix search nixpkgs <package>
```

## Architecture

This is a single-host NixOS flake configuration for the machine `feywild` (x86_64-linux) running on `nixpkgs-unstable`.

**Flake inputs:**
- `nixpkgs` → `nixos-unstable`
- `home-manager` → follows nixpkgs
- `dms` → DankMaterialShell (stable branch) from AvengeMedia

**Module tree:**
```
flake.nix
└── hosts/feywild/          ← host entry point (hardware + imports system + home-manager)
    modules/system/         ← NixOS system configuration
    ├── nixos/              ← boot, audio (PipeWire), bluetooth, locale, network, nix settings, virtualization
    ├── desktop/            ← Niri (Wayland) + SDDM + GNOME + fonts
    ├── packages/           ← system packages + direnv + Steam + 1Password
    └── user/               ← user `fractal` with groups (wheel, docker, audio, etc.)
    modules/home/           ← Home Manager configuration for user `fractal`
    ├── desktop/            ← DankMaterialShell, cursor theme, XDG MIME defaults
    └── pkgs/               ← user packages (zed-editor, claude-code, ripgrep, etc.) + bash config
```

**Important notes:**
- `configuration.nix` in the repo root is the original generated file; it is **not imported by the flake** and is kept for reference only. All active configuration flows through `hosts/feywild/`.
- System modules use `home-manager.useGlobalPkgs = true` and `home-manager.useUserPackages = false`.
- `specialArgs` passes `{ inputs }` to system modules and `{ inputs; username; realname }` to home-manager modules.
- Two LSP servers for Nix are installed: `nixd` (preferred) and `nil`.
- `devenv` is installed system-wide; bash is configured to auto-stop devenv services when leaving a project directory.
