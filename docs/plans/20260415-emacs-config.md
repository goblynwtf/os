# Emacs Configuration Module

## Overview
Add a fully-configured Emacs setup to the NixOS flake, split between Nix (binary, treesitter grammars, system tools) and Emacs `package.el` + `use-package` (all Emacs Lisp packages). The config targets fast startup via native compilation, deferred loading, and GC tuning, while providing full IDE capabilities (eglot, dape), org-mode GTD + babel, and a modern completion stack (Vertico).

**Acceptance criteria:**
- Emacs launches with doom-one theme, PragmataPro Mono Liga font
- eglot connects to nixd for `.nix` files, rust-analyzer for `.rs` files
- org-capture works (`C-c c`)
- `consult-ripgrep` (`M-s r`) searches project
- `M-x magit-status` shows git state
- `nixos-rebuild build` succeeds without errors

## Context (from discovery)
- **Existing Emacs install**: `emacs-pgtk` in `modules/home/pkgs/default.nix:14` — raw package, no config
- **Already installed system-wide**: `nil` (line 35) and `nixd` (line 34) in `modules/system/packages/default.nix` — do NOT duplicate
- **Not installed anywhere**: `rust-analyzer`, `lldb`, `aspell` — add in emacs module
- **Module pattern**: one subdirectory per app under `modules/home/pkgs/` (alacritty, bash, fish, git, rust, starship, zed), imported from parent `default.nix`
- **Direnv**: installed system-wide — `envrc` package in Emacs will integrate with it

## Development Approach
- **testing approach**: `nix flake check` for Nix evaluation, `nixos-rebuild build --flake .#<host>` for full build validation
- Complete each task fully before moving to the next
- `git add` new files before any Nix evaluation (flake gotcha)
- Config files are symlinked (read-only) — all editing happens in the repo
- **Note**: Nix cannot validate elisp syntax. Elisp errors will only surface when Emacs loads the files. Task 11 includes an `emacs --batch` validation step.

## Validation Commands
- build: `nix build .#nixosConfigurations.feywild.config.system.build.toplevel --dry-run` (or use `nixos-rebuild build`)
- check: `nix flake check`
- elisp: `emacs --batch -l ~/.config/emacs/init.el` (post-build, catches load-time errors)

## Progress Tracking
- Mark completed items with `[x]` immediately when done
- Add newly discovered tasks with ➕ prefix
- Document issues/blockers with ⚠️ prefix

## Solution Overview

**Nix side (`default.nix`):**
- Manual `emacsWithPackages` wrapping `emacs-pgtk` + `treesit-grammars.with-all-grammars` (NOT `programs.emacs` — avoids init.el collision from home-manager)
- Home packages: `rust-analyzer`, `lldb`, `(aspellWithDicts (dicts: with dicts; [ en ]))`
- `xdg.configFile` symlinks for individual files only (`early-init.el`, `init.el`, `lisp/`) — leaves `~/.config/emacs/` writable for `elpa/`, `eln-cache/`, `auto-save-list/` at runtime

**Emacs side (elisp files):**
- `early-init.el` — native-comp settings, GC tuning, UI suppression, disable `package-enable-at-startup`
- `init.el` — package.el setup (MELPA/GNU/NonGNU), `package-refresh-contents` guard, use-package config (always-defer, always-ensure), load-path for `lisp/`, require all modules
- `lisp/init-ui.el` — doom-one theme, doom-modeline, nerd-icons, PragmataPro Mono Liga 17, dashboard
- `lisp/init-completion.el` — vertico, orderless, marginalia, consult, embark, corfu, cape
- `lisp/init-editing.el` — which-key, vundo, move-text, expand-region, rainbow-delimiters, built-in modes (save-place, recentf, auto-revert)
- `lisp/init-coding.el` — treesit-auto (with nix-mode exempted), eglot (hooks for rust/go/java/ruby/nix/html), dape, envrc, nix-mode, project.el, eldoc
- `lisp/init-org.el` — org-mode (GTD: agenda, capture, refile, TODO states), babel (emacs-lisp, shell, ruby, python), org-modern, org-appear
- `lisp/init-writing.el` — markdown-mode, olivetti, flyspell
- `lisp/init-vcs.el` — magit, diff-hl

## Implementation Steps

### Task 1: Create Nix module (`default.nix`)

**Files:**
- Create: `modules/home/pkgs/emacs/default.nix`
- Modify: `modules/home/pkgs/default.nix`

- [x] Create `modules/home/pkgs/emacs/default.nix` with `{ pkgs, ... }:` signature
- [x] Define `emacs` let-binding: `(pkgs.emacsPackagesFor pkgs.emacs-pgtk).emacsWithPackages` wrapping `treesit-grammars.with-all-grammars`
- [x] Add `home.packages` for wrapped emacs, `rust-analyzer`, `lldb`, `(aspellWithDicts (dicts: with dicts; [ en ]))`
- [x] Add `xdg.configFile` entries: `"emacs/early-init.el".source`, `"emacs/init.el".source`, `"emacs/lisp".source` (individual symlinks, directory stays writable)
- [x] Add `./emacs` to imports in `modules/home/pkgs/default.nix`
- [x] Remove `emacs-pgtk` from `home.packages` in `modules/home/pkgs/default.nix`
- [x] `git add` new files, run `nix flake check` to validate

### Task 2: Create `early-init.el`

**Files:**
- Create: `modules/home/pkgs/emacs/early-init.el`

- [x] Native compilation: silence async warnings, enable `package-native-compile`
- [x] GC tuning: set `gc-cons-threshold` to `most-positive-fixnum` during init, restore 16MB after startup
- [x] UI suppression: disable menu-bar, tool-bar, scroll-bars via `default-frame-alist` (no flicker)
- [x] Disable `package-enable-at-startup` (manual init in `init.el`)
- [x] `git add` new file

### Task 3: Create `init.el` (entry point)

**Files:**
- Create: `modules/home/pkgs/emacs/init.el`

- [ ] Configure `package-archives` (MELPA, GNU ELPA, NonGNU ELPA), call `package-initialize`
- [ ] Add `(unless package-archive-contents (package-refresh-contents))` — prevents first-launch failures
- [ ] Configure `use-package`: `always-ensure t`, `always-defer t`
- [ ] Add `lisp/` to `load-path` via `user-emacs-directory`
- [ ] `require` all modules: init-ui, init-completion, init-editing, init-coding, init-org, init-writing, init-vcs
- [ ] `git add` new file

### Task 4: Create `lisp/init-ui.el`

**Files:**
- Create: `modules/home/pkgs/emacs/lisp/init-ui.el`

- [ ] `doom-themes`: `:demand t`, load `doom-one`, enable `doom-themes-org-config`
- [ ] `doom-modeline`: `:demand t`, enable mode
- [ ] `nerd-icons` package (comment: run `M-x nerd-icons-install-fonts` on first launch)
- [ ] Font: PragmataPro Mono Liga, height 170
- [ ] Line numbers in `prog-mode`, `global-hl-line-mode`, `pixel-scroll-precision-mode`
- [ ] `dashboard`: `:demand t`, centered, items (recents, projects, agenda)
- [ ] `(provide 'init-ui)`

### Task 5: Create `lisp/init-completion.el`

**Files:**
- Create: `modules/home/pkgs/emacs/lisp/init-completion.el`

- [ ] `vertico`: `:demand t`, enable mode
- [ ] `orderless`: `:demand t`, set `completion-styles`
- [ ] `marginalia`: `:demand t`, enable mode
- [ ] `consult`: bind `C-s` → consult-line, `C-x b` → consult-buffer, `M-s r` → consult-ripgrep, `M-s f` → consult-find, `M-y` → consult-yank-pop, `M-g g` → consult-goto-line
- [ ] `embark` + `embark-consult`: bind `C-.` → embark-act, `C-;` → embark-dwim
- [ ] `corfu`: `:demand t`, auto-complete with 0.2s delay, 2-char prefix, global mode
- [ ] `cape`: add `cape-file` and `cape-dabbrev` to completion-at-point-functions
- [ ] `(provide 'init-completion)`

### Task 6: Create `lisp/init-editing.el`

**Files:**
- Create: `modules/home/pkgs/emacs/lisp/init-editing.el`

- [ ] `which-key`: `:demand t`, 0.5s delay
- [ ] `electric-pair-mode` in `prog-mode` (built-in)
- [ ] `rainbow-delimiters`: hook `prog-mode`
- [ ] `vundo`: bind `C-x u`
- [ ] `move-text`: bind `M-<up>`, `M-<down>`
- [ ] `expand-region`: bind `C-=`
- [ ] Built-in settings: `whitespace-cleanup` on save, `use-short-answers`, `save-place-mode`, `recentf-mode` (50 items), `global-auto-revert-mode`, UTF-8 defaults
- [ ] `(provide 'init-editing)`

### Task 7: Create `lisp/init-coding.el`

**Files:**
- Create: `modules/home/pkgs/emacs/lisp/init-coding.el`

- [ ] `treesit-auto`: `:demand t`, disable auto-install (`treesit-auto-install nil`), add to auto-mode-alist, global mode; add `nix-mode` to `treesit-auto-exempt-modes` to prevent conflict
- [ ] Set `treesit-font-lock-level` to 4
- [ ] `nix-mode`: associate `\.nix$`
- [ ] `eglot` (built-in): hooks for `rust-ts-mode`, `go-ts-mode`, `java-ts-mode`, `ruby-ts-mode`, `nix-mode`, `html-ts-mode`; autoshutdown, disable event log; add nixd for nix-mode
- [ ] `dape`: lazy-load via `:commands dape` (built-in configs handle lldb-dap, delve, etc.)
- [ ] `envrc`: `:demand t`, `envrc-global-mode` (critical for project-level LSP servers via direnv)
- [ ] `project` (built-in): keybindings for find-file, find-regexp, dired, shell
- [ ] `eldoc` (built-in): compact echo area
- [ ] `(provide 'init-coding)`

### Task 8: Create `lisp/init-org.el`

**Files:**
- Create: `modules/home/pkgs/emacs/lisp/init-org.el`

- [ ] `org` (built-in): bind `C-c a` (agenda), `C-c c` (capture), `C-c l` (store-link)
- [ ] Set `org-directory` to `~/org`, `org-agenda-files` to `~/org`
- [ ] TODO workflow: `TODO(t)` → `IN-PROGRESS(i)` → `WAITING(w)` | `DONE(d)` / `CANCELLED(c)`
- [ ] Capture templates: Task (inbox.org), Note (notes.org), Journal (journal.org datetree)
- [ ] Refile: targets from agenda files, max level 3, outline path completion
- [ ] Visual: `org-startup-indented`, `org-hide-leading-stars`, `org-ellipsis " ▾"`, `org-pretty-entities`
- [ ] Babel: load languages (emacs-lisp, shell, ruby, python), disable confirm on eval
- [ ] `org-modern`: hook `org-mode`
- [ ] `org-appear`: hook `org-mode`
- [ ] `(provide 'init-org)`

### Task 9: Create `lisp/init-writing.el`

**Files:**
- Create: `modules/home/pkgs/emacs/lisp/init-writing.el`

- [ ] `markdown-mode`: associate `.md`, `.markdown`
- [ ] `olivetti`: hook `org-mode` and `markdown-mode`, body width 80
- [ ] `flyspell` (built-in): hook `text-mode` (full), hook `prog-mode` (prog-only — comments/strings)
- [ ] `(provide 'init-writing)`

### Task 10: Create `lisp/init-vcs.el`

**Files:**
- Create: `modules/home/pkgs/emacs/lisp/init-vcs.el`

- [ ] `magit`: bind `C-x g` → magit-status
- [ ] `diff-hl`: `:demand t`, global mode, magit post-refresh hook
- [ ] `(provide 'init-vcs)`

### Task 11: Validate full build

- [ ] `git add` all new files
- [ ] Run `nix flake check`
- [ ] Run `nixos-rebuild build --flake .#feywild` (or whichever host is current)
- [ ] Verify no evaluation errors or conflicts
- [ ] Run `emacs --batch -l init.el` to catch elisp load-time errors (after build)

### Task 12: Update documentation

- [ ] Update `CLAUDE.md` module tree to include `emacs/` under `modules/home/pkgs/`

## Post-Completion

**First launch checklist (manual):**
- Run `M-x nerd-icons-install-fonts` to download icon fonts
- Create `~/org/` directory with `inbox.org`, `notes.org`, `journal.org`
- First startup will be slow — `package.el` downloads all packages from MELPA, then native compilation runs in background
- Subsequent startups should be fast (sub-second with proper defer)

**Optional future enhancements (not in scope):**
- AI integration (gptel, ellama)
- Email (mu4e, notmuch)
- RSS (elfeed)
- Terminal (vterm)
- File tree sidebar (treemacs)
- Split init.el modules further if config grows
