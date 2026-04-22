# Switch interactive shell from fish to Nushell

## Overview

Full replace of fish with [Nushell](https://www.nushell.sh/) as the user's interactive and login shell on both hosts (`feywild`, `maple`). Keeps bash installed and configured as a rescue shell. Ports minimal fish-equivalent UX (aliases, starship prompt, direnv auto-load, no greeting) to nu. No carapace, no fzf-fish port — defer until daily use reveals what's missing.

Motivation: unified modern shell across interactive and `nix develop` / `nix-shell` environments, with structured-data pipelines replacing text-stream tooling.

## Context (from discovery)

**Files involved:**
- `modules/home/pkgs/default.nix` — home-manager package module aggregator (adds `./nushell`, removes `./fish`)
- `modules/home/pkgs/fish/default.nix` — existing fish module (deleted)
- `modules/home/pkgs/bash/default.nix` — bash module (unchanged — rescue shell)
- `modules/home/pkgs/starship/default.nix` — starship integration (swap `enableFishIntegration` → `enableNushellIntegration`)
- `modules/home/pkgs/alacritty/default.nix` — alacritty spawns nu instead of fish
- `modules/system/user/default.nix` — set `users.users.fractal.shell = pkgs.nushell` (login shell switch)
- `modules/home/pkgs/nushell/default.nix` — **new** module with aliases, defs, direnv hook

**Patterns found:**
- Module convention: each shell/tool has its own subdir under `modules/home/pkgs/` with a `default.nix`; the aggregator `default.nix` imports them.
- Current `programs.fish.shellAbbrs` uses fish-specific command substitution `(hostname)`; nushell needs `def` (runtime) instead of `alias` (parse-time).
- `programs.direnv` + `nix-direnv` enabled at system level (`modules/system/packages/default.nix:45-47`). Home-manager adds the per-shell hook.
- `CLAUDE.md` flake gotcha: new files must be `git add`-ed before nix can see them.

**Dependencies identified:**
- `pkgs.nushell` (in nixpkgs-unstable)
- home-manager's `programs.nushell` module
- home-manager's `programs.direnv.enableNushellIntegration`
- `pkgs.hostname` (inetutils) — external binary, used inside `rebuild` def via `^hostname`

## Development Approach

- **Testing approach**: **Validation-based** (not TDD). This is a NixOS flake config repo — there is no unit-test suite. The equivalents are:
  - `nix flake check` — evaluates all host configurations, catches syntax and module errors
  - `sudo nixos-rebuild build --flake .#<host>` — builds the system closure without activating (safer than `switch`)
  - Post-activation: manual smoke test of login shell, alacritty launch, starship, aliases, direnv auto-load
- Complete each task fully before moving to the next.
- After every Nix change: `git add` new/changed files, then run `nix flake check`. A green check is the gate.
- **Do NOT run `nixos-rebuild switch` until all build validations pass**, and only switch on one host at a time so the other host remains a rescue option if the switched host's login shell misbehaves.
- Keep bash enabled throughout — `programs.bash.enable = true` in `modules/home/pkgs/bash/default.nix` stays untouched so `chsh`-style recovery is available from a TTY.

## Testing Strategy

- **Static**: `nix flake check` after every file change.
- **Build-only**: `nixos-rebuild build --flake .#<host>` on the host being modified before switching.
- **Activation smoke test (post-switch, in a fresh alacritty window):**
  1. `$env.SHELL` → ends in `/bin/nu` (confirms login shell)
  2. Prompt renders via starship (directory, git status segments visible)
  3. `rebuild` and `rebuild-build` commands expand correctly (dry test: call, interrupt before sudo prompt or run `which rebuild` to see the def exists)
  4. `cd` into a directory with an `.envrc` that runs `use flake` — direnv loads without error
  5. `nd` inside a flake project launches a nested nu with dev env
  6. Aliases: `ls`, `ll`, `gs`, `cat README.md` produce expected output

## Validation Commands

- syntax/eval: `nix flake check`
- build (no activation): `nixos-rebuild build --flake .#$(hostname)`
- apply: `sudo nixos-rebuild switch --flake .#$(hostname)` — **only after build succeeds**

## Progress Tracking

- Mark completed items with `[x]` immediately when done.
- Add newly discovered tasks with ➕ prefix.
- Document issues/blockers with ⚠️ prefix.
- Update plan if scope shifts during implementation.

## Solution Overview

**Architecture:** same per-tool module pattern as the rest of `modules/home/pkgs/`. One new subdir `nushell/` with a `default.nix` that enables `programs.nushell` and wires in direnv. One-line edits to the alacritty, starship, and aggregator modules point the plumbing at nu instead of fish. One-line addition to the system user module flips the login shell.

**Key design decisions:**
1. **Login shell = nushell** (not just interactive). User accepted the non-POSIX risk; gives a single unified shell everywhere including TTY and SSH. Bash stays installed for script compatibility and TTY rescue.
2. **`def` for `rebuild`/`rebuild-build`, not `alias`.** Nushell aliases are parse-time — `(hostname)` wouldn't evaluate at call time. `def rebuild [] { ... }` does.
3. **`^hostname | str trim`** to get the hostname inside the `def` body. Nushell's builtin hostname was removed; `^` forces the external coreutils binary; `str trim` drops the trailing newline.
4. **Drop `rm -i` / `cp -i` / `mv -i`.** Nushell's builtins are already safer than unaliased coreutils (no auto-recursive, literal globs, `--trash` available). No alias needed.
5. **direnv hook via `programs.direnv.enableNushellIntegration = true`.** Home-manager generates the PWD-change hook that loads `use flake` envs into the current nu session — so dev shells "just work" on `cd`.
6. **No carapace, no fzf-fish port.** Minimal parity. Add only once daily use reveals a concrete gap.

## Technical Details

**`modules/home/pkgs/nushell/default.nix` content:**

```nix
{ ... }:
{
  programs.nushell = {
    enable = true;

    shellAliases = {
      ls = "eza";
      ll = "eza -l --git";
      la = "eza -la --git";
      lt = "eza --tree --level=2";
      cat = "bat";
      e = "zeditor";
      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate -20";
      flake-update = "nix flake update";
      flake-check = "nix flake check";
      nd = "nix develop -c nu";
      nsh = "nix-shell --command nu";
    };

    extraConfig = ''
      $env.config.show_banner = false

      def rebuild [] { sudo nixos-rebuild switch --flake $".#(^hostname | str trim)" }
      def rebuild-build [] { nixos-rebuild build --flake $".#(^hostname | str trim)" }
    '';
  };

  programs.direnv.enableNushellIntegration = true;
}
```

**`modules/system/user/default.nix` changes:**
- Module signature: `{ ... }:` → `{ pkgs, ... }:`
- Inside `users.users.fractal`: add `shell = pkgs.nushell;`
- At module top level (sibling to `users.users.fractal`), add `environment.shells = [ pkgs.nushell ];` so nushell ends up in `/etc/shells` — required for PAM/`chsh` to accept it as a valid login shell. Bash is already picked up via `programs.bash.enable = true`, so no need to list it explicitly.

**`modules/home/pkgs/starship/default.nix` changes:**
- `enableFishIntegration = true;` → `enableNushellIntegration = true;`
- `enableBashIntegration = true;` stays.

**`modules/home/pkgs/alacritty/default.nix` changes:**
- `terminal.shell.program = "${pkgs.fish}/bin/fish";` → `terminal.shell.program = "${pkgs.nushell}/bin/nu";`

**`modules/home/pkgs/default.nix` changes:**
- `./fish` → `./nushell` in the imports list.

**Deleted:** `modules/home/pkgs/fish/default.nix`.

## What Goes Where

- **Implementation Steps** (`[ ]` checkboxes): all file edits + `nix flake check` + `nixos-rebuild build` — doable in-repo.
- **Post-Completion** (no checkboxes): `sudo nixos-rebuild switch`, live smoke test of login shell in a fresh alacritty, testing on the second host.

## Implementation Steps

### Task 1: Create the nushell module

**Files:**
- Create: `modules/home/pkgs/nushell/default.nix`

- [x] create `modules/home/pkgs/nushell/default.nix` with `programs.nushell.enable`, the `shellAliases` block, `extraConfig` (banner off + `rebuild`/`rebuild-build` defs), and `programs.direnv.enableNushellIntegration = true`
- [x] `git add modules/home/pkgs/nushell/default.nix` — flakes only see git-tracked files
- [x] validate: `nix flake check` — must pass before task 2
- ⚠️ **fallback if `programs.direnv.enableNushellIntegration` is not an option** on the pinned home-manager rev (surfaced by `nix flake check` as an unknown-option error): replace that line with an `extraConfig` snippet that appends the direnv nu hook, e.g. `$env.config.hooks.env_change.PWD = ($env.config.hooks.env_change.PWD? | default []) ++ [{|_,_| ^direnv export json | from json | default {} | load-env }]`. Re-run `nix flake check` before moving on.

### Task 2: Wire nushell into the home-manager aggregator and drop fish

**Files:**
- Modify: `modules/home/pkgs/default.nix`
- Delete: `modules/home/pkgs/fish/default.nix`

- [x] in `modules/home/pkgs/default.nix`, replace `./fish` with `./nushell` in the imports list (keep alphabetical order: `nushell` goes between `git` and `rust`)
- [x] `git rm modules/home/pkgs/fish/default.nix` (removes file and stages deletion)
- [x] `rmdir modules/home/pkgs/fish 2>/dev/null || true` — remove now-empty directory (git doesn't track empty dirs; filesystem cleanup)
- [x] validate: `nix flake check` — must pass before task 3
- Note: `programs.fzf.enable = true` is being dropped with the fish module. The `fzf` binary will no longer be installed. This is intentional per the "skip fzf integration" decision — add `fzf` to `home.packages` later if a need arises.

### Task 3: Point starship at nushell instead of fish

**Files:**
- Modify: `modules/home/pkgs/starship/default.nix`

- [x] change `enableFishIntegration = true;` to `enableNushellIntegration = true;` (leave `enableBashIntegration` intact)
- [x] validate: `nix flake check` — must pass before task 4

### Task 4: Point alacritty at nushell

**Files:**
- Modify: `modules/home/pkgs/alacritty/default.nix`

- [x] change `terminal.shell.program = "${pkgs.fish}/bin/fish";` to `terminal.shell.program = "${pkgs.nushell}/bin/nu";`
- [x] validate: `nix flake check` — must pass before task 5

### Task 5: Set nushell as login shell for user `fractal`

**Files:**
- Modify: `modules/system/user/default.nix`

- [x] change the module signature from `{ ... }:` to `{ pkgs, ... }:`
- [x] add `shell = pkgs.nushell;` inside `users.users.fractal` (place it below `description`)
- [x] add `environment.shells = [ pkgs.nushell ];` at module top level (sibling to `users.users.fractal`) — ensures nu lands in `/etc/shells` for PAM/`chsh`
- [x] validate: `nix flake check` — must pass before task 6

### Task 6: Build-test both host configurations

- [x] `nixos-rebuild build --flake .#feywild` — closure builds without errors
- [x] `nixos-rebuild build --flake .#maple` — closure builds without errors
- [x] if either fails: diagnose and fix before task 7. Do NOT proceed to `switch` on a broken build. — both builds succeeded — diagnosis unnecessary

### Task 7: Verify acceptance criteria (still pre-switch)

- [x] confirm all files from the "Context" section are changed as described
- [x] re-read the new `nushell/default.nix` to sanity-check the `def` syntax (string-interpolation `$"..."`, external `^hostname`, `| str trim`)
- [x] run `nix flake check` one final time
- [x] (Optional) skim for any remaining live references to fish: `grep -rnE 'pkgs\.fish\b|programs\.fish\b|enableFishIntegration' modules/` — no hits expected.

### Task 8: [Final] Update documentation and move plan

- [ ] update `CLAUDE.md` module-tree section: replace the fish reference in the `pkgs/` listing with nushell; note that nushell is the login shell and bash is the rescue shell
- [ ] `mkdir -p docs/plans/completed`
- [ ] move this plan file to `docs/plans/completed/20260422-switch-to-nushell.md`

## Post-Completion

*Items requiring manual intervention outside the repo — no checkboxes, informational only.*

**Activation (user runs, not the plan):**
- `sudo nixos-rebuild switch --flake .#$(hostname)` on the current host (pick one host to switch first; keep the other as fallback until the first is confirmed healthy).
- **Before logging out**, sanity-check nu as a login shell in the *current* fish/alacritty session: `nu -l -c 'print ok'`. It must print `ok` and exit 0. If it errors, **do not log out** — `git revert` the switch-related commits and `sudo nixos-rebuild switch` again, then diagnose.
- Only after the sanity check passes: log out and back in (SDDM → nu as login shell). Open a fresh alacritty window.

**Manual smoke tests in the new shell:**
- `$env.SHELL` ends in `/bin/nu`
- Prompt renders with starship (directory, git branch, git status)
- `ls`, `ll`, `gs`, `cat <file>` aliases work
- `which rebuild` shows the def; `rebuild-build` actually performs a build
- In a project dir with `.envrc` containing `use flake`, running `direnv allow` then `cd .` (or any cd in/out) loads the dev env into the current nu — no new shell spawned
- `nd` inside a flake project launches nested nu with dev env
- Log into a TTY (`Ctrl-Alt-F3`) as `fractal` — nu launches; `bash` is available as fallback if needed

**Once the first host is confirmed healthy:**
- Repeat switch on the second host.

**Rollback (if nu login shell misbehaves):**
- **Preferred: boot the previous generation.** Reboot, and at systemd-boot select the previous NixOS generation. This reverts the whole system closure — including the shell flip — without needing a working shell. On `feywild`, the LUKS prompt still appears first; unlock, then pick the earlier generation.
- **If the boot menu is unavailable**: from TTY (`Ctrl-Alt-F3`) as `fractal`, try launching `bash` directly. If that works, `cd ~/Developer/os && git revert <sha>` and `sudo nixos-rebuild switch --flake .#$(hostname)`. (This path can fail if nu panics before reaching the login prompt — hence the boot-menu path is preferred.)
