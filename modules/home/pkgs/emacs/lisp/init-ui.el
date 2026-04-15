;;; init-ui.el --- UI configuration -*- lexical-binding: t; -*-
;;; Commentary:
;; Theme (doom-one), modeline, icons, font, line numbers, and dashboard.
;;; Code:

;; ---------- Theme -----------------------------------------------------------
(use-package doom-themes
  :demand t
  :config
  (load-theme 'doom-one t)
  (doom-themes-org-config))

;; ---------- Modeline --------------------------------------------------------
(use-package doom-modeline
  :demand t
  :config
  (doom-modeline-mode 1))

;; ---------- Icons -----------------------------------------------------------
;; Run M-x nerd-icons-install-fonts on first launch to download icon fonts.
(use-package nerd-icons)

;; ---------- Font ------------------------------------------------------------
(set-face-attribute 'default nil
                    :family "PragmataPro Mono Liga"
                    :height 170)

;; ---------- Line numbers & visual polish ------------------------------------
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(global-hl-line-mode 1)
(pixel-scroll-precision-mode 1)

;; ---------- Dashboard -------------------------------------------------------
(use-package dashboard
  :demand t
  :config
  (setq dashboard-center-content t)
  (setq dashboard-items '((recents   . 5)
                          (projects  . 5)
                          (agenda    . 5)))
  (dashboard-setup-startup-hook))

(provide 'init-ui)
;;; init-ui.el ends here
