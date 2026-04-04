# Alacritty Adaptive Wallpaper Colors via DMS Matugen

## Overview
- Make Alacritty terminal colors automatically adapt to the current wallpaper, matching DMS's Material You theming
- DMS already generates `~/.config/alacritty/dank-theme.toml` via its built-in matugen template (`matugenTemplateAlacritty: true` by default)
- Alacritty imports that generated theme file and auto-reloads on changes
- Include DMS's recommended base settings (window, cursor, keybindings) so the terminal matches DMS's intended appearance
- **Acceptance criteria**: Alacritty terminal colors change automatically when wallpaper changes via DMS, with no manual intervention

## Context (from discovery)
- **DMS matugen pipeline**: On wallpaper change, DMS runs matugen with `scheme-tonal-spot` algorithm, generating color configs for many apps including Alacritty
- **Generated file**: `~/.config/alacritty/dank-theme.toml` — contains Material Design 3 colors (bg/fg, selection, cursor, full 16-color dank16 palette)
- **DMS base config**: DMS ships an embedded `alacritty.toml` with recommended non-color settings (padding, no decorations, cursor style, keybindings)
- **Alacritty import support**: Alacritty's `general.import` setting accepts a list of TOML files to merge, and watches them for live reload
- **Current state**: Alacritty is a system package in `modules/system/packages/default.nix` with only a Shift+Enter keybinding in `~/.config/alacritty/alacritty.toml`
- **Pattern to follow**: `modules/home/pkgs/bash/default.nix` — minimal home-manager program module

### Files involved
- `modules/system/packages/default.nix` — currently has `alacritty` in systemPackages
- `modules/home/pkgs/default.nix` — imports home-manager program modules (currently only `./bash`)
- `modules/home/pkgs/alacritty/default.nix` — new file for `programs.alacritty` config

## Development Approach
- **testing approach**: `nix flake check` for syntax/evaluation, `nixos-rebuild build` for full build validation
- Complete each task fully before moving to the next
- Make small, focused changes
- `git add` new files before running nix commands (flakes require tracked files)

## Testing Strategy
- **Syntax/evaluation**: `nix flake check` after all changes
- **Full build**: `nixos-rebuild build --flake .#<host>` to verify the config builds successfully
- **Manual verification**: Change wallpaper via DMS UI and confirm Alacritty colors update live

## Progress Tracking
- Mark completed items with `[x]` immediately when done
- Add newly discovered tasks with ➕ prefix
- Document issues/blockers with ⚠️ prefix

## Implementation Steps

### Task 1: Create Alacritty home-manager module and wire it up

**Files:**
- Create: `modules/home/pkgs/alacritty/default.nix`
- Modify: `modules/home/pkgs/default.nix`
- Modify: `modules/system/packages/default.nix`

- [x] Create `modules/home/pkgs/alacritty/default.nix` with `programs.alacritty` config containing:
  - `enable = true`
  - `settings.general.import = [ "~/.config/alacritty/dank-theme.toml" ]` (tilde — Alacritty handles expansion)
  - DMS base settings: `window.decorations = "None"`, `window.padding = { x = 12; y = 12 }`, `window.opacity = 1.0`
  - `scrolling.history = 3023`
  - `cursor.style = { shape = "Block"; blinking = "On" }`, `cursor.blink_interval = 500`, `cursor.unfocused_hollow = true`
  - `mouse.hide_when_typing = true`
  - `selection.save_to_clipboard = false`
  - `bell.duration = 0`
  - Keyboard bindings: Copy, Paste, SpawnNewInstance, font size controls, Shift+Enter (`\n`)
- [x] Add `./alacritty` to imports list in `modules/home/pkgs/default.nix`
- [x] Remove `alacritty` from `environment.systemPackages` in `modules/system/packages/default.nix`
- [x] `git add modules/home/pkgs/alacritty/default.nix`

### Task 2: Validate build

- [x] Run `nix flake check` to verify syntax and evaluation
- [x] Run `nixos-rebuild build --flake .#maple` — alacritty.toml built successfully (unrelated claude-code-2.1.88 npm 404 blocked full system build)
- [x] Verify generated `alacritty.toml` in nix store output contains expected import + settings

### Task 3: Finalize

- [ ] Move this plan to `docs/plans/completed/`

## Technical Details

**Exact Nix expression for the import**:
```nix
settings.general.import = [ "~/.config/alacritty/dank-theme.toml" ];
```
Alacritty natively expands `~` — this matches the path DMS's matugen config writes to.

**DMS embedded base config** (non-color settings to replicate):
```toml
[general]
import = ["~/.config/alacritty/dank-theme.toml"]

[window]
decorations = "None"
padding = { x = 12, y = 12 }
opacity = 1.0

[scrolling]
history = 3023

[cursor]
style = { shape = "Block", blinking = "On" }
blink_interval = 500
unfocused_hollow = true

[mouse]
hide_when_typing = true

[selection]
save_to_clipboard = false

[bell]
duration = 0

[keyboard]
bindings = [
  { key = "C",      mods = "Control|Shift", action = "Copy" },
  { key = "V",      mods = "Control|Shift", action = "Paste" },
  { key = "N",      mods = "Control|Shift", action = "SpawnNewInstance" },
  { key = "Equals", mods = "Control|Shift", action = "IncreaseFontSize" },
  { key = "Minus",  mods = "Control",       action = "DecreaseFontSize" },
  { key = "Key0",   mods = "Control",       action = "ResetFontSize" },
  { key = "Enter",  mods = "Shift",         chars = "\n" },
]
```

**Generated theme format** (`~/.config/alacritty/dank-theme.toml`):
```toml
[colors.primary]
background = '#141218'
foreground = '#e6e0e9'

[colors.normal]
black   = '#1d1b20'
red     = '#f2b8b5'
# ... full 16-color palette from dank16
```

**Graceful degradation**: If `dank-theme.toml` doesn't exist yet (first boot before wallpaper is set), Alacritty logs a warning but works with its built-in default colors.

**Home-manager `programs.alacritty`**:
- `enable = true` installs the package and manages `~/.config/alacritty/alacritty.toml`
- `settings` attrset maps directly to TOML structure via `pkgs.formats.toml`

## Post-Completion

**Manual verification:**
- Change wallpaper through DMS UI and confirm Alacritty colors update live
- Verify colors match DMS panel/shell theming
- Check that `~/.config/alacritty/dank-theme.toml` exists and contains valid TOML after a wallpaper change
- Verify window has no title bar decorations, 12px padding, block cursor
