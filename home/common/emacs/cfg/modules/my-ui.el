(defun my/disable-scroll-bars (frame)
  (modify-frame-parameters
   frame
   '((vertical-scroll-bars . nil)
     (horizontal-scroll-bars . nil))))

(add-hook 'after-make-frame-functions 'my/disable-scroll-bars)

(add-hook 'text-mode-hook #'visual-line-mode)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'prog-mode-hook (lambda () (setq-local show-trailing-whitespace t)))

(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

(add-to-list 'custom-theme-load-path
             "~/.emacs.d/themes/")

(scroll-bar-mode -1) ; Disable visible scrollbar
(tool-bar-mode -1)   ; Disable the toolbar
(tooltip-mode -1)    ; Disable tooltips
(set-fringe-mode 25) ; Give some breathing room
(menu-bar-mode -1)
(blink-cursor-mode 0)
(global-hl-line-mode 0) ;; Cursor line

(setq modus-themes-mixed-fonts t)

(setq even-window-sizes nil)     ; avoid resizing

(setq frame-inhibit-implied-resize t)
(setq inhibit-startup-message t)
(setq ring-bell-function 'ignore)
(setq scroll-margin 8)
(setq show-trailing-whitespace nil)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(setq compilation-scroll-output t)

(setq mode-line-format (delq 'mode-line-modes mode-line-format))

;; olivetti
(setq olivetti-body-width 120)
(add-hook 'org-agenda-mode-hook #'olivetti-mode)
(add-hook 'org-mode-hook #'olivetti-mode)

;; font
(set-face-attribute 'default nil :family "Iosevka" :height 110)
(set-face-attribute 'variable-pitch nil :family "ETBembo" :height 140)
(set-face-attribute 'fixed-pitch nil :family "Iosevka" :height 100)

(custom-theme-set-faces
 'user
 '(variable-pitch ((t (:family "ETBembo" :height 140 :weight thin))))
 '(fixed-pitch ((t ( :family "Iosevka" :height 110 :weight normal)))))

(setq line-spacing 0.1)
(setq modus-themes-headings
      (quote ((1 . (1.5))
              (2 . (1.3))
              (3 . (1.1))
              (4 . (1.1)))))

(provide 'my-ui)
