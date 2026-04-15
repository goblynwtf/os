;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-
;;; Commentary:
;; Runs before init.el.  Handles GC tuning, native-comp settings,
;; UI suppression, and disabling package-enable-at-startup.
;;; Code:

;; ---------- Native compilation ------------------------------------------
;; Silence async native-comp warnings (they are noisy and non-actionable).
(setq native-comp-async-report-warnings-errors 'silent)
;; Native-compile packages when they are installed.
(setq package-native-compile t)

;; ---------- GC tuning ---------------------------------------------------
;; Set GC threshold to maximum during init to avoid GC pauses.
;; Restored to a reasonable value after startup (see end of file).
(setq gc-cons-threshold most-positive-fixnum)

;; ---------- UI suppression (flicker-free startup) -----------------------
;; Disable chrome before any frame is drawn — prevents momentary flash.
(push '(menu-bar-lines . 0)   default-frame-alist)
(push '(tool-bar-lines . 0)   default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

;; ---------- Disable package.el auto-init --------------------------------
;; We call package-initialize manually in init.el.
(setq package-enable-at-startup nil)

;; ---------- Post-startup GC restore ------------------------------------
;; After init finishes, lower GC threshold to 16 MB for normal operation.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024))))

(provide 'early-init)
;;; early-init.el ends here
