# Alacritty Visual + Integration Improvements

## Overview
- Apply visual polish to the Alacritty home-manager module: set terminal font to match DMS's `monoFontFamily` ("PragmataPro Mono Liga"), size 13, with correct bold rendering for ligature fonts
- Reduce window opacity to 0.85 for subtle transparency
- Add `COLORTERM=truecolor` env safety net for 24-bit color
- Keep all existing DMS-aligned settings (adaptive colors, window padding/decorations, cursor, keybindings) untouched
- **Acceptance criteria**: Alacritty launches using PragmataPro Mono Liga at size 13, has 0.85 opacity, and `nix flake check` + `nixos-rebuild build` both succeed on at least one host

## Context (from discovery)
- **Target file**: `modules/home/pkgs/alacritty/default.nix` (existing, 38 lines)
- **DMS font config** at `modules/home/desktop/default.nix:106-108`:
  - `fontFamily = "Berkeley Mono"` (UI)
  - `monoFontFamily = "PragmataPro Mono Liga"` (code/terminal — what we match)
  - `fontScale = 1.0`
- **System fonts** at `modules/system/desktop/default.nix:43-52` include noto, fira-code, ubuntu-classic, nerd-fonts.ubuntu-mono, lmodern — **does NOT include PragmataPro or Berkeley Mono**. User installs these proprietary fonts manually; automating that install is out of scope for this plan.
- **Prior plan**: `docs/plans/20260404-alacritty-adaptive-colors.md` established the current module (DMS color import, window/cursor/keybinding settings copied from DMS's embedded alacritty.toml). That plan is already implemented except for the final "move to completed/" cleanup task.
- **Hosts affected**: both `maple` (desktop) and `feywild` (laptop) — both pull in this home-manager module.
- **Niri blur**: Niri does not natively support window blur. User accepts 0.85 opacity regardless (will be literal see-through).

### Files involved
- Modify: `modules/home/pkgs/alacritty/default.nix`

## Development Approach
- **testing approach**: This is a NixOS configuration module, not application code. There is no unit test framework — validation is evaluation + build success.
  - `nix flake check` verifies syntax and flake evaluation
  - `nixos-rebuild build --flake .#<host>` verifies the full config builds (alacritty.toml gets generated into the nix store)
  - Manual verification after activation confirms runtime behavior (font renders, opacity applied, ligatures work)
- Make small, focused changes — all changes land in a single file
- Keep settings in the same structural order/style as the existing module

## Testing Strategy
- **Evaluation check**: `nix flake check` must pass with no new errors — this also provides cross-host coverage (evaluates both `maple` and `feywild` configs)
- **Build check**: `nixos-rebuild build --flake .#<current-host>` must succeed
- **Generated TOML inspection**: verify the built alacritty.toml in `/nix/store/*-home-manager-files/.config/alacritty/alacritty.toml` contains the expected `font`, `env`, `colors.draw_bold_text_with_bright_colors`, and updated `opacity` keys
- **Runtime config validation**: **Nix evaluation cannot catch Alacritty schema errors** (wrong key paths, wrong types). After activation, run `alacritty --print-events 2>&1 | head -30` or check `journalctl --user --since "5 minutes ago"` for "Config error" / "unused config key" warnings. This is the only real schema validator.
- **Manual verification** after activation (in Post-Completion): font visibly changes to PragmataPro, window shows 0.85 opacity, ligatures render (e.g., `->`, `!=`, `>=`), bold text renders with bright colors

## Progress Tracking
- Mark completed items with `[x]` immediately when done
- Add newly discovered tasks with ➕ prefix
- Document issues/blockers with ⚠️ prefix
- Update plan if implementation deviates from original scope

## What Goes Where
- **Implementation Steps** (`[ ]` checkboxes): edits to the Nix module + build validation on this machine
- **Post-Completion** (no checkboxes): activation via `sudo nixos-rebuild switch`, visual verification of font/opacity/ligatures in a live Alacritty session

## Implementation Steps

### Task 1: Update Alacritty module with font, opacity, env, and bold-color settings

**Files:**
- Modify: `modules/home/pkgs/alacritty/default.nix`

- [x] Add a `font` attrset to `programs.alacritty.settings` with `normal.family = "PragmataPro Mono Liga"` and `size = 13` (no explicit bold/italic — let fontconfig auto-resolve variants)
- [x] Add `colors.draw_bold_text_with_bright_colors = true` — note: this key lives under `[colors]` in Alacritty's schema, NOT at root. Placing it at root silently fails (Alacritty logs an "unused config key" warning but build succeeds). The imported `~/.config/alacritty/dank-theme.toml` defines color palettes but does not set this key, so no conflict — main config overrides imports.
- [x] Add an `env` attrset with `COLORTERM = "truecolor"` as a safety net for 24-bit color detection
- [x] Change `window.opacity` from `1.0` to `0.85`
- [x] Leave DMS color import, window decorations/padding, scrolling, cursor, mouse, selection, bell, and all keybindings untouched

### Task 2: Validate evaluation and build

- [x] Run `nix flake check` — must pass with no new errors attributable to this change (also covers cross-host evaluation)
- [x] Run `nixos-rebuild build --flake .#maple` (or `.#feywild` depending on current host) — build must complete alacritty.toml successfully
- [x] Inspect generated `alacritty.toml` from the built home-manager output and confirm it contains: `font.normal.family = "PragmataPro Mono Liga"`, `font.size = 13`, `[colors]` section with `draw_bold_text_with_bright_colors = true` nested inside it, `env.COLORTERM = "truecolor"`, `window.opacity = 0.85`

### Task 3: Finalize
- [ ] Verify acceptance criteria from Overview are met (font set, size 13, opacity 0.85, evaluation + build both succeeded)
- [ ] Move this plan to `docs/plans/completed/` after user confirms manual verification in Post-Completion

## Technical Details

**Exact Nix additions** (to `programs.alacritty.settings` attrset):

```nix
font = {
  normal.family = "PragmataPro Mono Liga";
  size = 13;
};

colors.draw_bold_text_with_bright_colors = true;

env.COLORTERM = "truecolor";
```

**Note on `colors.draw_bold_text_with_bright_colors` nesting:** This key lives under the `[colors]` table in Alacritty's config schema. Nix syntax `colors.draw_bold_text_with_bright_colors = true;` produces TOML `[colors]` + `draw_bold_text_with_bright_colors = true`, which is the correct shape. Placing it at root (`draw_bold_text_with_bright_colors = true;`) would silently be ignored by Alacritty with a warning at startup — Nix evaluation cannot detect this.

**Interaction with imported `dank-theme.toml`:** The imported theme file defines `[colors.primary]`, `[colors.selection]`, `[colors.cursor]`, `[colors.normal]`, `[colors.bright]` but does NOT define `draw_bold_text_with_bright_colors`. In Alacritty's import semantics, the main config's values override imports, so our setting is authoritative.

**Exact change**:
```nix
window.opacity = 0.85;  # was 1.0
```

**Why each setting:**
- `font.normal.family` only (no `bold`/`italic` blocks): fontconfig auto-resolves styled variants from installed font files. Explicit per-style config is only needed if auto-resolution fails or you intentionally mix fonts.
- `draw_bold_text_with_bright_colors = true`: without this, Alacritty would synthesize bold from the Regular weight and keep normal-palette colors. With this, bold text uses the bright variant of the current palette color, matching the convention most color schemes (including DMS's dank16) are designed for.
- `env.COLORTERM = "truecolor"`: Alacritty already advertises truecolor via its default terminfo, but setting this env var explicitly ensures shell integrations / TUIs that check `$COLORTERM` always see it, even when launched through odd paths (e.g., `su`, `sudo -E` stripped envs).
- `window.opacity = 0.85`: user preference. Niri has no compositor blur, so this is literal see-through to windows/wallpaper behind.

**What we deliberately do NOT add:**
- `font.bold` / `font.italic` blocks (fontconfig handles it)
- `window.blur` (not a real Alacritty setting, and Niri wouldn't render it anyway)
- Shell program override, working directory, TERM override (user chose minimal integration)
- Vi mode, search bindings, URL hints (not requested)

## Post-Completion

**Manual verification** (after `sudo nixos-rebuild switch --flake .#<host>`):
- **Runtime schema check first**: Launch a fresh Alacritty and run `alacritty --print-events 2>&1 | head -30` OR check `journalctl --user --since "5 minutes ago" | grep -i "config\|alacritty"` — must show NO "unused config key" / "Config error" warnings. This is the only way to catch Alacritty schema mismatches that Nix evaluation cannot detect.
- Open a fresh Alacritty window — font should visibly be PragmataPro Mono Liga at size 13
- Window should have subtle transparency (0.85) — slightly see-through to wallpaper/windows behind
- Type ligatured sequences in a text editor or shell (`->`, `=>`, `!=`, `>=`, `<=`, `<-`) — ligatures should render as combined glyphs
- Run `echo -e "\e[1;31mbold red\e[0m normal"` — the bold red should appear bright red (from the bright palette) rather than standard red with synthesized bold weight
- Run `echo $COLORTERM` — should print `truecolor`
- Confirm existing DMS color theming still loads from `~/.config/alacritty/dank-theme.toml` (change wallpaper via DMS to confirm live reload still works)

**If PragmataPro Mono Liga is not installed yet**, Alacritty will fall back to a system monospace font and log a warning. That's the signal to run the (separate, out-of-scope) font installation.
