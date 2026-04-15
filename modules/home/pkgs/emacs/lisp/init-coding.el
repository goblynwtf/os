;;; init-coding.el --- Programming configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; Treesit-auto (tree-sitter grammar mapping), eglot (LSP), dape (DAP),
;; envrc (direnv integration), nix-mode, project.el, and eldoc.
;;; Code:

;; ---------- Treesit-auto (tree-sitter major-mode remapping) ----------------
(use-package treesit-auto
  :demand t
  :config
  (setq treesit-auto-install nil)
  (add-to-list 'treesit-auto-exempt-modes 'nix-mode)
  (treesit-auto-add-to-auto-mode-alist)
  (global-treesit-auto-mode 1))

;; Maximise tree-sitter font-lock detail
(setq treesit-font-lock-level 4)

;; ---------- Nix-mode -------------------------------------------------------
(use-package nix-mode
  :mode "\\.nix\\'")

;; ---------- Eglot (LSP client, built-in) -----------------------------------
(use-package eglot
  :hook ((rust-ts-mode . eglot-ensure)
         (go-ts-mode   . eglot-ensure)
         (java-ts-mode . eglot-ensure)
         (ruby-ts-mode . eglot-ensure)
         (nix-mode     . eglot-ensure)
         (html-ts-mode . eglot-ensure))
  :config
  (setq eglot-autoshutdown t)
  (setq eglot-events-buffer-size 0)
  (add-to-list 'eglot-server-programs '(nix-mode . ("nixd"))))

;; ---------- Dape (DAP client) ----------------------------------------------
(use-package dape
  :commands dape)

;; ---------- Envrc (direnv integration) -------------------------------------
(use-package envrc
  :demand t
  :config
  (envrc-global-mode 1))

;; ---------- Project (built-in project management) --------------------------
(use-package project
  :ensure nil
  :bind (("C-x p f" . project-find-file)
         ("C-x p r" . project-find-regexp)
         ("C-x p d" . project-dired)
         ("C-x p s" . project-shell)))

;; ---------- Eldoc (built-in documentation) ---------------------------------
(use-package eldoc
  :ensure nil
  :config
  (setq eldoc-echo-area-use-multiline-p nil))

(provide 'init-coding)
;;; init-coding.el ends here
