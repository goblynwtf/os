# Repository Guidelines

## Project Structure & Module Organization
This repository is a multi-host NixOS flake. [`flake.nix`](/home/fractal/Developer/os/flake.nix) defines the two active hosts: `feywild` and `maple`.

- `hosts/<host>/` contains host-specific entrypoints and generated hardware files.
- `modules/system/` contains shared NixOS modules (`nixos/`, `desktop/`, `packages/`, `user/`).
- `modules/home/` contains shared Home Manager modules, including `niri/` and user package configs under `pkgs/`.
- `modules/gaming/` and `modules/security/` are opt-in feature modules imported by specific hosts.
- `assets/wallpapers/` stores static desktop assets.

Prefer shared changes in `modules/`; keep hardware, boot, and machine-only overrides inside `hosts/<host>/`.

## Build, Test, and Development Commands
- `nix flake check` validates flake evaluation and catches broken imports.
- `sudo nixos-rebuild build --flake .#maple` performs a dry-run build for the desktop host.
- `sudo nixos-rebuild build --flake .#feywild` performs a dry-run build for the laptop host.
- `sudo nixos-rebuild switch --flake .#$(hostname)` applies changes on the current machine.
- `nix flake update [input]` refreshes pinned inputs in `flake.lock`.
- `nix search nixpkgs <package>` looks up package names before adding them.

## Coding Style & Naming Conventions
Use 2-space indentation in Nix files and keep attribute sets compact but readable. Name new modules by feature using lowercase paths such as `modules/home/pkgs/<tool>/default.nix`. Use `default.nix` as the module entrypoint for directories. Add brief comments only for non-obvious hardware quirks, service workarounds, or upstream limitations.

## Testing Guidelines
There is no separate unit-test suite; validation is build-based. Run `nix flake check` for every change, then run `nixos-rebuild build` for each affected host. For new files, run `git add` before validating: flakes do not evaluate untracked paths.

## Commit & Pull Request Guidelines
Recent history uses short imperative subjects, sometimes with Conventional Commit prefixes like `fix:` or `docs:`. Follow that pattern: keep titles concise, lowercase is acceptable, and scope by change when useful. PRs should state which host(s) were tested, list the commands run, and include screenshots only for desktop-facing changes such as Niri or shell UI updates.

## Configuration Notes
Treat `hosts/*/hardware-configuration.nix` as generated machine state and edit it cautiously. Keep secrets out of the repo and prefer Nix-managed configuration over manual edits in `$HOME`.
