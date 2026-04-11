# Niri Config Visual Consistency with DankMaterialShell

## Overview

Bring the niri compositor's visual appearance in line with DankMaterialShell (DMS) — rounded corners, matching gaps, matugen-driven colors, proper shadows — and move the niri `config.kdl` into the NixOS flake repository so it is version-controlled AND live-editable without a rebuild.

**Problem solved:**
1. `~/.config/niri/config.kdl` is still the stock 640-line default niri config with hardcoded visual defaults (`gaps 16`, `focus-ring width 4`, hardcoded `#7fc8ff` color, shadows off, rounded-corner rule commented out). It is not managed by Nix and not in the repo.
2. That stock config only includes 5 of the 8 DMS-generated snippet files in `~/.config/niri/dms/`. The three missing includes (`layout.kdl`, `alttab.kdl`, `wpblur.kdl`) are exactly the ones that provide the DMS visual identity: `gaps 4`, `border width 2`, `focus-ring width 2`, `geometry-corner-radius 12`, `clip-to-geometry true`, `draw-border-with-background false`, and the blurred-wallpaper layer rule.
3. Editing the live config requires remembering it lives outside the flake — no git history, no sync to feywild.

**Integration:**
- New shared home-manager module at `modules/home/niri/default.nix` creates a `mkOutOfStoreSymlink` from `~/.config/niri/config.kdl` to the live repo file at `modules/home/niri/config.kdl`.
- One import line added to `modules/home/default.nix` (currently `[ ./desktop ./pkgs ]` → `[ ./desktop ./niri ./pkgs ]`).
- DMS keeps owning `~/.config/niri/dms/` (it needs write access there for matugen template regeneration on theme changes). The existing `hosts/maple/niri-outputs.nix` override for `dms/outputs.kdl` is unaffected.
- Both hosts (maple AND feywild) inherit the new config since `modules/home/` is shared. Host-specific display output pinning continues to live in `hosts/<hostname>/niri-outputs.nix`.

## Context (from discovery)

**Files involved:**
- `modules/home/niri/default.nix` — NEW module, creates the out-of-store symlink
- `modules/home/niri/config.kdl` — NEW minimal DMS-consistent config (~100 lines)
- `modules/home/default.nix` — MODIFY, add `./niri` to imports list
- `modules/home/desktop/default.nix` — unchanged but relevant: already sets `matugenTemplateNiri = true` and `cornerRadius = 12` on `programs.dank-material-shell`
- `hosts/maple/niri-outputs.nix` — unchanged, continues overriding `dms/outputs.kdl` for maple's LG 4K panel
- `~/.config/niri/config.kdl` — EXISTING, unmanaged plain file, must be `rm`-ed once before first rebuild (home-manager refuses to clobber untracked files)
- `~/.config/niri/dms/` — owned by DMS, leave alone

**Related patterns:**
- `hosts/maple/niri-outputs.nix:7` already uses `home-manager.users.fractal.xdg.configFile."niri/dms/outputs.kdl".text = ''...''` — demonstrates that home-manager can write into the niri config dir alongside DMS.
- `modules/home/pkgs/starship/default.nix` (per the 20260410-starship-prompt plan) is the most recent example of a small shared home-manager submodule with a clean `{ ... }:` header and a single purpose.
- `modules/home/default.nix` uses **explicit** imports, not auto-discovery — adding a new subdir requires updating the imports list.

**Dependencies:**
- `config.lib.file.mkOutOfStoreSymlink` — a stock home-manager helper, no flake input changes needed.
- `programs.niri.enable = true` is already set in `modules/system/desktop/default.nix:40`.
- DMS at flake input `dms` (stable branch) is already generating the snippet files.

## Development Approach

- **Testing approach:** N/A for unit tests — this is Nix configuration, not application code. Verification uses `nix flake check` (evaluation) + `nixos-rebuild build` (build without activation) as the substitute test layer, with a post-activation manual visual sanity check. Any in-place edits to `modules/home/niri/config.kdl` after the initial switch are verified by niri's automatic config reload (niri watches its config file).
- Complete each task fully before moving to the next.
- Make small, focused changes.
- **CRITICAL: every task MUST include verification** — `nix flake check` after Nix file changes, full build before activation.
- **CRITICAL: all verifications must pass before starting the next task.**
- **CRITICAL: update this plan file when scope changes during implementation.**
- Nix flakes only see git-tracked files → `git add` new files before any `flake check`/`build`.
- Keep hardcoded paths commented — `mkOutOfStoreSymlink` hardcodes the repo checkout path (`$HOME/Developer/os/...`); add an explanatory comment in `config.kdl` header.

## Testing Strategy

- **Evaluation test:** `nix flake check` — catches Nix syntax errors, typos in option names, broken module args. Evaluates both `nixosConfigurations.maple` AND `nixosConfigurations.feywild`, so shared-module changes are verified against both hosts in one command.
- **Build test:** `nixos-rebuild build --flake .#maple` (no sudo per user preference) — builds the full system closure without activating.
- **Manual visual verification (post-switch):**
  - `readlink ~/.config/niri/config.kdl` → should resolve to `/home/fractal/Developer/os/modules/home/niri/config.kdl`
  - Open a new alacritty window: rounded corners at 12px radius, tight 4px gaps, focus ring in matugen color (cyan-ish `#83d2e3` at the time of writing), subtle shadow behind the rounded corners
  - Open Firefox: title-bar rendering should look clean with `prefer-no-csd` (known trade-off: Firefox handles CSD requests inconsistently, minor visual artifacts are acceptable)
  - Alt+Tab: recent-windows highlight should also be rounded (12px) — confirms `alttab.kdl` include works
  - Wallpaper blur layer should render correctly beneath DMS surfaces — confirms `wpblur.kdl` include works
- **Live-edit verification:** after the initial switch, touch `modules/home/niri/config.kdl` directly (e.g. temporarily change gaps back to 8), save, observe niri reload the config without a rebuild. **Do this twice in a row with the same editor (nvim/zed)** — both editors save via write-temp-then-rename, which replaces the inode. The out-of-store symlink points to a path so it remains valid, but niri's inotify watcher is attached to the original inode, so there is a known risk that the second-and-subsequent saves are missed until niri re-reads the file. If the second edit is not picked up automatically, run `niri msg action reload-config` as a manual nudge and note this ergonomic limitation. Revert the test edit afterwards.

## Progress Tracking

- Mark completed items with `[x]` immediately when done
- Add newly discovered tasks with ➕ prefix
- Document issues/blockers with ⚠️ prefix
- Update plan if implementation deviates from original scope
- Keep plan in sync with actual work done

## What Goes Where

- **Implementation Steps** (`[ ]` checkboxes): Nix module creation, config.kdl authoring, imports wiring, `git add`, `nix flake check`, `nixos-rebuild build`.
- **Post-Completion** (no checkboxes): the one-time `rm ~/.config/niri/config.kdl` manual step, `sudo nixos-rebuild switch` (requires sudo + user confirmation), visual sanity check, feywild rollout.

## Pre-Flight Decisions (resolve before Task 1)

These are flagged from the brainstorm and the plan review for the user to confirm before implementation begins.

- [ ] **Feywild checkout at `~/Developer/os` must exist BEFORE running `nixos-rebuild switch --flake .#feywild`.** This is a hard precondition, not a post-completion note. `mkOutOfStoreSymlink` does not verify the target exists at build time — if the repo is not checked out on feywild when the rebuild runs, activation silently creates a dangling symlink and niri fails to load its config on next launch. **Action:** either (a) clone the repo to `~/Developer/os` on feywild first, or (b) defer the feywild rebuild until the checkout exists. If neither is acceptable, the module must be imported per-host from `hosts/<hostname>/default.nix` instead of the shared `modules/home/default.nix`, so the maple rebuild can proceed without affecting feywild.
- [ ] **Confirm shared-module rollout:** visual changes land on both hosts by default. **Default assumption: both hosts, shared module** (subject to feywild checkout above).
- [ ] **Wezterm window rule:** stock config has a `wezterm` initial-configure workaround. User has alacritty configured, not wezterm. **Default assumption: drop the rule.**

## Implementation Steps

### Task 1: Create the home-manager niri module

**Files:**
- Create: `modules/home/niri/default.nix`

- [ ] create `modules/home/niri/default.nix` with `{ config, ... }:` header (needs `config` for `config.lib.file.mkOutOfStoreSymlink` and `config.home.homeDirectory`)
- [ ] set `xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Developer/os/modules/home/niri/config.kdl";`
- [ ] add a top-of-file comment explaining the mkOutOfStoreSymlink behavior (live-editable, breaks if checkout moves)

### Task 2: Author the minimal DMS-consistent config.kdl

**Files:**
- Create: `modules/home/niri/config.kdl`

- [ ] add header comment: "Managed by NixOS flake at modules/home/niri/config.kdl. Symlinked to ~/.config/niri/config.kdl via home-manager mkOutOfStoreSymlink. DMS auto-generates everything under ~/.config/niri/dms/ — do not edit there."
- [ ] write `input` block: keyboard `layout "us,ru"` + `options "grp:win_space_toggle"` + `numlock`; touchpad `tap` + `natural-scroll`; empty `mouse {}` and `trackpoint {}` blocks
- [ ] write `layout` block with:
  - `center-focused-column "never"`
  - `preset-column-widths` with `proportion 0.33333`, `proportion 0.5`, `proportion 0.66667`
  - `default-column-width { proportion 0.5; }`
  - empty `focus-ring {}` (width comes from `dms/layout.kdl`, color from `dms/colors.kdl`)
  - `border { off; }` (DMS sets width 2 in layout.kdl; explicitly off means focus-ring is the active indicator)
  - `shadow { on; draw-behind-window true; softness 30; spread 5; offset x=0 y=5; }` — NO hardcoded color (dms/colors.kdl sets it)
- [ ] add top-level `prefer-no-csd` directive
- [ ] keep `screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"`
- [ ] DROP `spawn-at-startup "waybar"` (DMS panel replaces waybar)
- [ ] keep empty `hotkey-overlay {}` and `animations {}` blocks
- [ ] window rules — keep ONLY:
  - `match app-id=r#"firefox$"# title="^Picture-in-Picture$"` → `open-floating true`
- [ ] window rules — DROP:
  - wezterm initial-configure workaround (user uses alacritty, confirm in pre-flight)
  - the standalone `draw-border-with-background false` rule (dms/layout.kdl sets it globally)
  - commented-out keepassxc block-out-from example
  - commented-out `geometry-corner-radius 12` example (dms/layout.kdl sets it globally)
- [ ] `binds` block — keep ALL existing binds EXCEPT `Mod+D fuzzel` AND `Super+Alt+L swaylock`. Explicit keep-list:
  - `Mod+Shift+Slash` show-hotkey-overlay
  - `Mod+T` spawn alacritty
  - `Super+Alt+S` spawn-sh orca toggle (allow-when-locked)
  - `XF86AudioRaiseVolume` / `XF86AudioLowerVolume` / `XF86AudioMute` / `XF86AudioMicMute` (all `allow-when-locked=true`)
  - `XF86AudioPlay` / `XF86AudioStop` / `XF86AudioPrev` / `XF86AudioNext` (all `allow-when-locked=true`)
  - `XF86MonBrightnessUp` / `XF86MonBrightnessDown` (all `allow-when-locked=true`)
  - `Mod+O` toggle-overview (repeat=false)
  - `Mod+Q` close-window (repeat=false)
  - Column/window focus (arrow keys + hjkl): `Mod+Left/Down/Up/Right`, `Mod+H/J/K/L`
  - Column/window move (Ctrl): `Mod+Ctrl+Left/Down/Up/Right`, `Mod+Ctrl+H/J/K/L`
  - `Mod+Home` / `Mod+End` column-first/last
  - `Mod+Ctrl+Home` / `Mod+Ctrl+End` move-column-to-first/last
  - Monitor focus (Shift): `Mod+Shift+Left/Down/Up/Right`, `Mod+Shift+H/J/K/L`
  - Monitor move (Shift+Ctrl): `Mod+Shift+Ctrl+Left/Down/Up/Right`, `Mod+Shift+Ctrl+H/J/K/L`
  - Workspace focus: `Mod+Page_Down/Page_Up`, `Mod+U`, `Mod+I`
  - Workspace move-column: `Mod+Ctrl+Page_Down/Page_Up`, `Mod+Ctrl+U`, `Mod+Ctrl+I`
  - Workspace reorder: `Mod+Shift+Page_Down/Page_Up`, `Mod+Shift+U`, `Mod+Shift+I`
  - Mouse wheel: `Mod+WheelScrollDown/Up` (cooldown-ms=150), `Mod+Ctrl+WheelScrollDown/Up` (cooldown-ms=150)
  - Horizontal wheel: `Mod+WheelScrollRight/Left`, `Mod+Ctrl+WheelScrollRight/Left`, `Mod+Shift+WheelScrollDown/Up`, `Mod+Ctrl+Shift+WheelScrollDown/Up`
  - Workspace indices: `Mod+1..9` focus, `Mod+Ctrl+1..9` move-column-to-workspace
  - `Mod+BracketLeft/BracketRight` consume-or-expel-window-left/right
  - `Mod+Comma` consume-window-into-column, `Mod+Period` expel-window-from-column
  - `Mod+R` switch-preset-column-width, `Mod+Shift+R` switch-preset-window-height, `Mod+Ctrl+R` reset-window-height
  - `Mod+F` maximize-column, `Mod+Shift+F` fullscreen-window, `Mod+Ctrl+F` expand-column-to-available-width
  - `Mod+C` center-column, `Mod+Ctrl+C` center-visible-columns
  - `Mod+Minus/Equal` set-column-width ±10%, `Mod+Shift+Minus/Equal` set-window-height ±10%
  - `Mod+V` toggle-window-floating, `Mod+Shift+V` switch-focus-between-floating-and-tiling
  - `Mod+W` toggle-column-tabbed-display
  - `Ctrl+Shift+S` screenshot, `Ctrl+Print` screenshot-screen, `Alt+Print` screenshot-window
  - `Mod+Escape` toggle-keyboard-shortcuts-inhibit (allow-inhibiting=false)
  - `Mod+Shift+E` quit, `Ctrl+Alt+Delete` quit
  - `Mod+Shift+P` power-off-monitors
- [ ] `binds` block — DROP `Mod+D { spawn "fuzzel"; }` (DMS owns launcher via `dms/binds.kdl` Mod+D spotlight)
- [ ] `binds` block — DROP `Super+Alt+L { spawn "swaylock"; }` (swaylock is NOT installed in this flake — verified via grep, not in `modules/system/packages/` or `modules/home/pkgs/`; keeping the bind would silently fail and mislead. DMS provides its own lock screen and `lockBeforeSuspend = true` is already set.)
- [ ] DMS includes in this exact order at the bottom of the file (later wins on overrides):
  ```
  include "dms/colors.kdl"
  include "dms/layout.kdl"      // NEW — rounded corners, gaps 4, border width 2
  include "dms/alttab.kdl"      // NEW — rounded Alt+Tab highlight
  include "dms/wpblur.kdl"      // NEW — wallpaper-blur layer rule
  include "dms/binds.kdl"       // DMS Mod+D spotlight
  include "dms/outputs.kdl"     // host-managed via hosts/<host>/niri-outputs.nix
  include "dms/windowrules.kdl"
  include "dms/cursor.kdl"
  ```

### Task 3: Wire the new module into home-manager imports AND set backupFileExtension

**Files:**
- Modify: `modules/home/default.nix`

- [ ] add `./niri` to the `imports` list, alphabetical order → `[ ./desktop ./niri ./pkgs ]`
- [ ] add `home.backupFileExtension = "hm-bak";` to the same `modules/home/default.nix` — instructs home-manager to rename any conflicting unmanaged file (`~/.config/niri/config.kdl` → `~/.config/niri/config.kdl.hm-bak`) during activation instead of aborting. This eliminates the manual `rm` step and survives the same collision on feywild's first rebuild automatically. **Note:** this setting is home-manager-wide and will also apply to any future conflicting files — intended behavior, cleaner than a per-file manual step.

### Task 4: Stage files and verify evaluation

**Files:**
- (no file edits — verification only)

- [ ] `git add modules/home/niri/default.nix modules/home/niri/config.kdl modules/home/default.nix` (flakes only see git-tracked files — this is the gotcha from CLAUDE.md)
- [ ] run `niri validate -c modules/home/niri/config.kdl` — catches KDL syntax errors and schema violations BEFORE involving home-manager. **Expect include-resolution errors** for the `dms/*.kdl` paths when run from the repo (those files live at `~/.config/niri/dms/`, not in the repo) — ignore those, they are harmless. Look only for KDL parse errors, schema errors, or type mismatches in the main file. If the only errors are of the form "failed to resolve include" for `dms/...`, the hand-written config is valid.
- [ ] run `nix flake check` (no sudo) — must pass, must not introduce new warnings attributable to this change
- [ ] if eval errors: fix in Task 1/2/3 and re-stage before re-running

### Task 5: Full build verification

**Files:**
- (no file edits — verification only)

- [ ] run `nixos-rebuild build --flake .#maple` (no sudo) — must succeed before activation
- [ ] if build errors: diagnose (likely `mkOutOfStoreSymlink` path typo, or a mismatched xdg.configFile attribute) and loop back

### Task 6: Verify acceptance criteria and finalize

- [ ] `git status` shows `modules/home/niri/{default.nix,config.kdl}` staged as new files
- [ ] `modules/home/default.nix` imports list includes `./niri`
- [ ] `nix flake check` passes cleanly
- [ ] `nixos-rebuild build --flake .#maple` passes cleanly
- [ ] confirm NO new hardcoded hex colors in `config.kdl` (grep for `#[0-9a-f]`)
- [ ] confirm all 8 DMS includes are present in `config.kdl` (colors, layout, alttab, wpblur, binds, outputs, windowrules, cursor)
- [ ] confirm `prefer-no-csd` is present
- [ ] confirm `shadow { on ... }` block is present
- [ ] update `CLAUDE.md` if a new pattern is worth capturing (likely: the `mkOutOfStoreSymlink` live-edit pattern — but only if the user wants it as a documented convention for future config files)
- [ ] move this plan to `docs/plans/completed/` after user confirms the activated config looks right

## Technical Details

**`modules/home/niri/default.nix` (target shape):**
```nix
# Live-editable niri config managed via home-manager.
#
# home-manager creates ~/.config/niri/config.kdl as an out-of-store symlink
# pointing at the live file in the repo checkout. This means:
#   - edits to modules/home/niri/config.kdl apply instantly (niri watches its config)
#   - the file is git-tracked and participates in normal commit flow
#   - no nixos-rebuild is needed for config tweaks after the initial switch
#
# Caveat: the symlink target hardcodes ~/Developer/os. Moving the checkout
# breaks the symlink until the next rebuild regenerates it.
{ config, ... }:
{
  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Developer/os/modules/home/niri/config.kdl";
}
```

**`modules/home/niri/config.kdl` override order (critical):**

Per [niri's include documentation](https://github.com/YaLTeR/niri/wiki/Configuration:-Include) — **verified empirically with `niri validate` against scratch configs**:
- `include` directives are **positional** and processed top-to-bottom
- Most sections (`layout`, `input`, etc.) are **merged**: an include can set only a few properties and only those change
- **Duplicate keys across main + include are resolved by position — later wins** (confirmed: a later `include` with a `gaps` value overrides a hand-written `layout { gaps X }` from earlier in the main config)
- **Multipart sections** (`window-rule`, `output`, `workspace`) are inserted as-is, **not merged** — they accumulate rather than override. This is why our Firefox PiP window rule and DMS's global rounded-corner window rule coexist without conflict.
- **Exceptions — sections that are REPLACED entirely, not merged** (from niri docs): `struts`, `preset-column-widths`, individual subsections inside `animations`, and pointing-device subsections inside `input`. Our `preset-column-widths` is safe because `dms/layout.kdl` does not touch it — but if a future DMS version starts emitting `preset-column-widths`, our hand-written values would be wiped out, not merged. Worth a comment in the config.

Our ordering:
1. Hand-written blocks at the top of `config.kdl` — stock defaults (input, layout shell, prefer-no-csd, shadows, window rules, binds)
2. `dms/colors.kdl` — overrides focus-ring/border/shadow colors with matugen values
3. `dms/layout.kdl` — overrides gaps/widths AND adds the global rounded-corner window rule
4. `dms/alttab.kdl` — adds recent-windows highlight radius
5. `dms/wpblur.kdl` — adds wallpaper-blur layer rule
6. `dms/binds.kdl` — adds `Mod+D` spotlight bind (our config has no `Mod+D` so there is no conflict after we drop the fuzzel bind)
7. `dms/outputs.kdl` — adds host-specific output config (this file itself is overridden by `hosts/maple/niri-outputs.nix` which writes it declaratively; on feywild, DMS writes it normally)
8. `dms/windowrules.kdl` / `dms/cursor.kdl` — currently empty, reserved for future DMS features

**Why explicit `border { off; }` even though we do not draw a border:**
Without the explicit `off`, niri uses its stock default (visible border). `dms/layout.kdl` (verified contents: `layout { gaps 4; border { width 2 } focus-ring { width 2 } }`) sets the border *width* but does not disable the border outright. Because `border` is a merged subsection, our `off` + DMS's `width 2` combine after the include, and niri honors the `off` flag — border is hidden, width value is stored but visually inert.

**home-manager version requirement:**
`config.lib.file.mkOutOfStoreSymlink` has been in home-manager since release-20.09 (2020). The flake's `home-manager` input follows `nixpkgs-unstable`, which is far ahead of that — requirement is satisfied, no action needed.

**Why empty `focus-ring {}` rather than omitting the block:**
Omitting would use stock defaults (width 4 and hardcoded color). The empty block is a placeholder that `dms/layout.kdl` and `dms/colors.kdl` then fill in.

**Visual diff summary (current → target):**

| Setting | Current `config.kdl` | After |
|---|---|---|
| `gaps` | 16 (hardcoded) | 4 (from `dms/layout.kdl`) |
| `focus-ring width` | 4 | 2 (from `dms/layout.kdl`) |
| `focus-ring active-color` | `#7fc8ff` | matugen (from `dms/colors.kdl`) |
| `border width` | 4 (but `off`) | 2 (from `dms/layout.kdl`), explicit `off` preserved |
| `geometry-corner-radius` | commented out | 12 (from `dms/layout.kdl`) |
| `clip-to-geometry` | commented out | `true` (from `dms/layout.kdl`) |
| `draw-border-with-background` | `false` (standalone rule) | `false` (from `dms/layout.kdl`, our rule removed) |
| `prefer-no-csd` | absent | **present** |
| `shadow` | block present but `on` commented out | **on**, draw-behind-window, DMS-colored |
| `dms/layout.kdl` include | missing | **present** |
| `dms/alttab.kdl` include | missing | **present** |
| `dms/wpblur.kdl` include | missing | **present** |
| `Mod+D` bind | fuzzel (overridden anyway) | dropped (DMS spotlight via `dms/binds.kdl`) |
| `Super+Alt+L` bind | swaylock (binary not installed) | dropped (DMS lockscreen + lockBeforeSuspend) |
| `spawn-at-startup "waybar"` | present | dropped (DMS replaces waybar) |
| stock tutorial comments | ~400 lines | dropped (~100 lines total) |

## Post-Completion

*Items requiring manual intervention — no checkboxes*

**No manual cleanup required (Task 3 handles this automatically):**

With `home.backupFileExtension = "hm-bak";` set in Task 3, home-manager will rename the existing `~/.config/niri/config.kdl` to `~/.config/niri/config.kdl.hm-bak` during activation and place the new symlink cleanly. Same behavior applies on feywild's first switch. The old DMS backup files (`config.kdl.backup*`, `config.kdl.dmsbackup*`) in the same directory are unaffected — they can be left alone or cleaned up manually later.

**If you prefer NOT to set a repo-wide backupFileExtension** (e.g. because you want future conflicts to be loud rather than silently backed up), remove the `home.backupFileExtension` line from Task 3 and instead run the one-shot `rm ~/.config/niri/config.kdl` manually before the first switch. Trade-off: loud-fail on future conflicts vs. quiet auto-backup.

**Activation (requires sudo):**
```bash
sudo nixos-rebuild switch --flake .#maple
```
Per user memory (`feedback_avoid_sudo.md`): this is one of the few commands where sudo is genuinely required.

**Post-switch visual verification:**
- `readlink ~/.config/niri/config.kdl` → should show `/home/fractal/Developer/os/modules/home/niri/config.kdl`
- Open a new alacritty window → rounded 12px corners, 4px gaps between windows, focus ring in matugen color, subtle shadow
- Trigger Alt+Tab (DMS recent-windows) → highlight should be rounded
- Open Firefox PiP → should open floating (rule preserved)
- `Mod+D` → DMS spotlight (not fuzzel)
- Wallpaper should blur correctly under DMS surfaces

**Known trade-off accepted during brainstorm:**
- `prefer-no-csd` may cause rendering differences in Firefox / Electron apps (Slack) that previously drew their own titlebars. Minor artifacts expected and acceptable.

**Live-edit sanity test (optional, post-switch):**
- See the full procedure in **Testing Strategy → Live-edit verification** above — do not duplicate here to avoid drift. Key reminder: test **two consecutive saves** to catch the atomic-rename inotify gotcha.

**Feywild host rollout:**
- Same `sudo nixos-rebuild switch --flake .#feywild` on the laptop when user next uses it.
- Feywild must also have the repo checked out at `~/Developer/os` for the symlink target to resolve. Verify before switching. If the checkout path differs, the symlink will dangle until the path is fixed — the system still boots but niri's config load will fail.
- Feywild's DMS output config will be whatever DMS wrote last (there is no `hosts/feywild/niri-outputs.nix` equivalent); this is unchanged by this plan.

**Future iterations (out of scope for this plan):**
- Move other ad-hoc dotfiles into `modules/home/<name>/` with the same `mkOutOfStoreSymlink` pattern if the live-edit ergonomics prove valuable.
- Consider a niri-flake home-manager module (sodiboo/niri-flake `programs.niri`) for a fully-typed Nix-native config — would eliminate the KDL file entirely but adds an input dependency and more coupling to DMS's file-based overrides.
- Document the `mkOutOfStoreSymlink` pattern in `CLAUDE.md` if it becomes a repeated convention.
