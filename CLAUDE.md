# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Key Commands

```bash
# Apply system + home-manager changes (use the host matching this machine)
sudo nixos-rebuild switch --flake .#feywild   # feywild (LUKS-encrypted laptop)
sudo nixos-rebuild switch --flake .#maple     # maple (desktop)

# Build without activating (dry run)
sudo nixos-rebuild build --flake .#feywild
sudo nixos-rebuild build --flake .#maple

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

This is a multi-host NixOS flake configuration (x86_64-linux) running on `nixpkgs-unstable`.

**Hosts:**
- `feywild` — laptop with LUKS-encrypted root + swap
- `maple` — desktop with plain ext4 + zram swap

**Flake inputs:**
- `nixpkgs` → `nixos-unstable`
- `home-manager` → follows nixpkgs
- `dms` → DankMaterialShell (stable branch) from AvengeMedia

**Module tree:**
```
flake.nix
├── hosts/feywild/          ← laptop host (hardware + shared base + explicit roles)
├── hosts/maple/            ← desktop host (hardware + shared base + explicit roles + gaming + security)
├── modules/gaming/         ← maple-only: Steam, Proton-GE, Gamescope, GameMode, MangoHUD, corectrl, controllers
├── modules/security/       ← maple-only security/network extras
├── modules/system/         ← shared NixOS base plus role-scoped additions
│   ├── default.nix         ← shared base system + shared Home Manager wiring
│   ├── desktop/            ← graphical system stack shared by the desktop role
│   ├── nixos/              ← system feature modules as <feature>/default.nix
│   ├── packages/           ← system package sets as <feature>/default.nix
│   ├── roles/              ← explicit desktop/dev/work host roles
│   └── user/               ← user `fractal` with base groups (wheel, audio, etc.)
└── modules/home/           ← Home Manager modules for user `fractal`
    ├── default.nix         ← shared/base HM entrypoint
    ├── desktop/            ← DMS, graphical helpers, MIME defaults, GTK/Qt theming
    ├── niri/               ← live-editable niri config
    └── pkgs/               ← shared user packages (shells, editors, apps); see pkgs/emacs/ for Emacs specifics
```

**Host and role convention:**
- `modules/system/default.nix` is the shared base layer only.
- Hosts opt into `modules/system/roles/<name>/` explicitly for desktop/dev/work behavior.
- The `desktop` role also pulls in desktop-specific Home Manager modules for `fractal`.
- For host-specific modules, create them at `modules/<name>/` (top-level, not under `modules/system/`) and import explicitly from the host's `default.nix`.
- Established pattern: `modules/gaming/` (maple-only).

**Hardware:**
- `maple` — AMD Ryzen (Granite Ridge) + AMD Radeon RX 7700 XT / 7800 XT (RDNA 3), open-source amdgpu/Mesa/RADV
- `feywild` — AMD CPU, open-source amdgpu/Mesa/RADV
- No proprietary GPU drivers on either host.

**Gotchas:**
- Nix flakes only evaluate git-tracked files. New files must be `git add`-ed before `nix flake check` or `nixos-rebuild` can see them — otherwise you get "path does not exist" errors.

**Important notes:**
- `configuration.nix` in the repo root is the original generated file; it is **not imported by the flake** and is kept for reference only. All active configuration flows through `hosts/<hostname>/`.
- Host-specific config (LUKS, hardware) lives in `hosts/<hostname>/`; shared modules live in `modules/`.
- System modules use `home-manager.useGlobalPkgs = true` and `home-manager.useUserPackages = true`.
- `specialArgs` passes `{ inputs }` to system modules and `{ inputs; username; realname }` to home-manager modules.
- Two LSP servers for Nix are installed: `nixd` (preferred) and `nil`.
- Nushell is the user's login shell (set via `users.users.fractal.shell` in `modules/system/user/default.nix`); bash is kept installed as a rescue shell.
- Evaluation warnings (e.g., deprecated `xorg.*` renames) may originate from upstream flake inputs — particularly `quickshell` (transitive dep of DankMaterialShell) which is pinned to a specific rev and can lag behind nixpkgs-unstable API changes. If `grep` finds nothing locally, investigate upstream inputs.
