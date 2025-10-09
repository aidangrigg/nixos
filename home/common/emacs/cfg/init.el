;; Bootstrap straight
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install use-package (we'll use this to install packages)
(straight-use-package 'use-package)

(use-package straight
  :custom
  (straight-use-package-by-default t))

;; Org
(use-package org
  :straight (:type built-in)
  :preface
  (defun my/project-orgfile ()
    (interactive)
    (let ((default-directory "~/sync/notes/org/projects/")
	  (project-name (projectile-project-name)))
      (find-file-other-window (expand-file-name (concat project-name ".org")))))
  (defun my/project-agenda ()
    (interactive)
    (let ((org-agenda-files
	   (list
	    (concat "~/sync/notes/org/projects/"
		    (concat (projectile-project-name) ".org")))))
      (call-interactively #'org-agenda)))
  :bind (("C-c o a" . 'org-agenda)
	 ("C-c o c" . 'org-capture)
	 ("C-c o f" . 'my/project-orgfile)
	 ("C-c o p" . 'my/project-agenda))
  :custom
  (org-agenda-window-setup 'only-window); agenda takes whole window
  (org-agenda-restore-windows-after-quit t); restore window configuration on exit
  (org-agenda-start-with-log-mode t)
  (org-adapt-indentation nil)
  (org-enforce-todo-dependencies t)
  (org-startup-with-inline-images t)
  (org-id-track-globally t)
  (org-log-repeat nil)
  (org-hide-leading-stars t)
  (org-latex-preview-ltxpng-directory "~/.cache/org-ltximg")
  (org-startup-with-latex-preview t)
  (org-capture-templates
   '(("t" "Task" entry
      (file+olp "~/sync/notes/org/tasks.org" "Inbox")
      "* TODO %?\n" :empty-lines 1)))
  (org-agenda-files
	'("~/sync/notes/org/tasks.org"
	  "~/sync/notes/org/mobile.org"))
  (org-icalendar-include-todo t)
  (org-icalendar-use-scheduled '(todo-start event-if-todo))
  (org-icalendar-use-deadline '(todo-due event-if-todo))
  (org-habit-show-habits-only-for-today nil)
  (org-agenda-skip-timestamp-if-done t)
  (org-agenda-skip-deadline-if-done t)
  (org-agenda-skip-scheduled-if-done t)
  (org-agenda-skip-timestamp-if-deadline-is-shown t)
  (org-agenda-time-grid
        '((daily today require-timed)
          ()
          "     " "----------------"))
  (org-agenda-current-time-string "   now")
  (org-agenda-compact-blocks nil)
  (org-agenda-hide-tags-regexp ".")
  :config
  ;; agenda stuff
  (setq org-agenda-block-separator nil)
  (setq org-agenda-custom-commands
        '(("d" "Daily Agenda"
           ((agenda "" ((org-agenda-span 'day)
                        (org-agenda-prefix-format "  %?-12t% s")
                        (org-deadline-warning-days 1)))
            (agenda nil ((org-agenda-entry-types '(:timestamp))
                         (org-agenda-format-date "%a [%x]")
                         (org-agenda-span 'week)
                         (org-agenda-prefix-format "  %?t")
                         (org-agenda-overriding-header "\nUpcoming Events\n")))
            (agenda nil ((org-agenda-entry-types '(:deadline))
                         (org-agenda-format-date "")
                         (org-agenda-span 0)
                         (org-deadline-warning-days 60)
                         (org-agenda-prefix-format " %6s [%8T] ")
                         (org-agenda-deadline-leaders '("[DUE]" "(%dd.)" "(+%dd.)"))
                         (org-agenda-overriding-header "\nUpcoming Deadlines")))
            (tags-todo "+university"
                       ((org-agenda-overriding-header "\nUniversity\n")
                        (org-agenda-prefix-format " [%8T] ")))
            ))
          ))
  (add-hook 'org-agenda-mode-hook (lambda () (setq-local show-trailing-whitespace nil)))
  (setq org-format-latex-options
        (plist-put org-format-latex-options :scale 1.5))
  (add-to-list 'org-modules 'org-habit t)
  ;; org mode hooks
  (add-hook 'org-mode-hook 'variable-pitch-mode)
  (add-hook 'org-mode-hook 'org-indent-mode)
  ;; Babel stuff
  (org-babel-do-load-languages
   'org-babel-load-languages '((C . t)
			       (haskell . t)
			       (shell . t))))

(use-package org-roam
  :custom
  (org-roam-directory (file-truename "~/sync/notes/org/zettel"))
  (org-roam-capture-templates
	'(("m" "main" plain "%?"
           :target
           (file+head
            "main/${slug}.org"
            "#+title: ${title}\n")
           :immediate-finish t
           :unnarrowed t)
          ("e" "empty" plain "%?"
           :target
           (file+head
            "main/${slug}.org"
            "#+title: ${title}\n#+filetags: :empty:\n")
           :immediate-finish t
           :unarrowed t)))
  :bind (("C-c r l" . org-roam-buffer-toggle)
         ("C-c r f" . org-roam-node-find)
         ("C-c r g" . org-roam-graph)
         ("C-c r i" . org-roam-node-insert)
         ("C-c r c" . org-roam-capture)
         ("C-c r d" . org-roam-dailies-goto-today)
         :map org-mode-map
         ("M-/" . org-roam-node-insert)
         ("C-c t" . org-roam-tag-add))
  :config
  (org-roam-db-autosync-mode)
  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  (setq org-roam-node-display-template
        (concat "${type:15} ${title:*} " (propertize "${tags:10}" 'face 'org-tag)))

  (cl-defmethod org-roam-node-type ((node org-roam-node))
    "Return the TYPE of NODE."
    (condition-case nil
        (file-name-nondirectory
         (directory-file-name
          (file-name-directory
           (file-relative-name (org-roam-node-file node) org-roam-directory))))
      (error "")))
  (defun my/tag-new-node-as-draft ()
    (org-roam-tag-add '("draft")))
  (add-hook 'org-roam-capture-new-node-hook #'my/tag-new-node-as-draft))

(use-package org-roam-ui)

(use-package citar
  :after typst-ts-mode
  :custom
  (org-cite-global-bibliography '("~/sync/My Library.bib"))
  (citar-bibliography org-cite-global-bibliography)
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  :bind ((:map org-mode-map
               ("C-c b" . #'org-cite-insert)
               :map typst-ts-mode-map
               ("C-c c" . 'citar-insert-keys)))
  :config
  (defun my/org-roam-node-from-cite (keys-entries)
    (interactive (list (citar-select-ref)))
    (let ((title (citar-format--entry "${title}" keys-entries))
          (author (citar-format--entry "${author}" keys-entries)))
      (org-roam-capture- :templates
                         '(("r" "reference" plain "%?" :if-new
                            (file+head "reference/${citekey}.org"
                                       ":PROPERTIES:\n:ROAM_REFS: [cite:@${citekey}]\n:END:\n#+title: ${title}\n#+author: ${author}")
                            :immediate-finish t
                            :unnarrowed t))
                         :info (list :citekey keys-entries :author author)
                         :node (org-roam-node-create :title title)
                         :props '(:finalize find-file)))))

(use-package org-download
  :bind ((:map org-mode-map
	 ("C-c v" . 'org-download-clipboard)))
  :custom
  (org-download-image-dir "~/sync/notes/org/images"))

;; (use-package org-modern
;;   :config
;;   (add-hook 'org-mode-hook #'org-modern-mode)
;;   (set-face-attribute 'org-modern-symbol nil :family "Iosevka"))

(use-package olivetti
  :custom
  (olivetti-body-width 120)
  :config
  (add-hook 'org-agenda-mode-hook #'olivetti-mode)
  (add-hook 'org-mode-hook #'olivetti-mode))

(use-package org-alert
  :ensure t
  :after org
  :custom
  (alert-default-style 'libnotify)
  (org-alert-interval 300)
  (org-alert-notify-cutoff 15)
  (org-alert-notify-after-event-cutoff 10)
  :config
  (org-alert-enable))

(use-package org-appear
  :custom
  (org-hide-emphasis-markers t)
  (org-appear-autoemphasis t)
  (org-appear-autolinks t)
  (org-appear-inside-latex t)
  (org-appear-autosubmarkers t)
  :hook ((org-mode . org-appear-mode))
  :config
  (setq org-appear-trigger 'manual)
  (add-hook 'org-mode-hook (lambda ()
                             (add-hook 'meow-insert-enter-hook
                                       #'org-appear-manual-start
                                       nil
                                       t)
                             (add-hook 'meow-insert-exit-hook
                                       #'org-appear-manual-stop
                                       nil
                                       t))))

(use-package auctex
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-master nil)
  (TeX-view-program-selection '((output-pdf "Zathura"))))

;;; Clean up the ui

(use-package emacs
  :straight (:type built-in)
  :preface
  (defun my/disable-scroll-bars (frame)
    (modify-frame-parameters frame
                             '((vertical-scroll-bars . nil)
                               (horizontal-scroll-bars . nil))))
  :bind (("C-c a"   . save-buffer)
         ("M-/" . completion-at-point)
         ("M-h" . windmove-left)
         ("M-l" . windmove-right)
         ("M-k" . windmove-up)
         ("M-j" . windmove-down)
         :map my/window-map
         ("h" . split-window-horizontally)
         ("v" . split-window-vertically)
         ("d" . delete-other-windows))
  :custom

  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))

  ;; (display-buffer-base-action
  ;;  '((display-buffer-reuse-window display-buffer-same-window)
  ;;    (reusable-frames . t)))

  (even-window-sizes nil)     ; avoid resizing

  (frame-inhibit-implied-resize t)
  (inhibit-startup-message t)
  (ring-bell-function 'ignore)
  (scroll-margin 8)
  (show-trailing-whitespace t)
  (ediff-window-setup-function 'ediff-setup-windows-plain)
  (custom-file (expand-file-name "custom.el" user-emacs-directory))
  (compilation-scroll-output t)

  ;; modeline
  (mode-line-format (delq 'mode-line-modes mode-line-format))

  ;; backups
  (backup-directory-alist `(("." . "~/.cache/emacs")))
  (make-backup-files t)               ; backup of a file the first time it is saved.
  (backup-by-copying t)               ; don't clobber symlinks
  (version-control t)                 ; version numbers for backup files
  (delete-old-versions t)             ; delete excess backup files silently
  (delete-by-moving-to-trash t)
  (kept-old-versions 6)               ; oldest versions to keep when a new numbered backup is made (default: 2)
  (kept-new-versions 9)               ; newest versions to keep when a new numbered backup is made (default: 2)
  (auto-save-default t)               ; auto-save every buffer that visits a file
  (auto-save-timeout 20)              ; number of seconds idle time before auto-save (default: 30)
  (auto-save-interval 200)            ; number of keystrokes between auto-saves (default: 300)
  (create-lockfiles nil)
  (auto-save-file-name-transforms
   `((".*" "~/.cache/emacs-saves/" t)))

  ;; isearch
  (isearch-wrap-pause 'no-ding)

  ;; Dired
  (dired-listing-switches "-aBhl  --group-directories-first")
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-dwim-target t)
  (dired-omit-files (rx (seq bol "." (not (any ".")))))

  ;; hunspell
  (ispell-program-name "hunspell")
  (ispell-local-dictionary "en_AU")
  (ispell-local-dictionary-alist
   ;; Please note the list `("-d" "en_AU")` contains ACTUAL parameters passed to hunspell
   ;; You could use `("-d" "en_AU,en_AU-med")` to check with multiple dictionaries
   '(("en_AU" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_AU") nil utf-8)))

  :config
  (set-face-attribute 'default nil :family "Iosevka" :height 120)
  (set-face-attribute 'variable-pitch nil :family "ETBembo" :height 140)
  (set-face-attribute 'fixed-pitch nil :family "Iosevka" :height 120)

  (custom-theme-set-faces
   'user
   '(variable-pitch ((t (:family "ETBembo" :height 140 :weight thin))))
   '(fixed-pitch ((t ( :family "Iosevka" :height 120 :weight normal)))))
  ;; (setq default-frame-alist '((font . "Iosevka-14")))

  (define-prefix-command 'my/window-map)
  (bind-key "C-c w" my/window-map)

  (add-hook 'text-mode-hook #'visual-line-mode)

  (scroll-bar-mode -1) ; Disable visible scrollbar
  (tool-bar-mode -1)   ; Disable the toolbar
  (tooltip-mode -1)    ; Disable tooltips
  (set-fringe-mode 25) ; Give some breathing room
  (menu-bar-mode -1)
  (blink-cursor-mode 0)
  (load custom-file)
  (electric-pair-mode 0)
  (global-hl-line-mode 0) ;; Cursor line
  (add-hook 'after-make-frame-functions 'my/disable-scroll-bars)
  (add-hook 'prog-mode-hook 'display-line-numbers-mode)
  (add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)
  (add-to-list 'custom-theme-load-path
               "~/.emacs.d/themes/")

  (setq line-spacing 0.1)

  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-mixed-fonts t)

  (setq modus-themes-headings
        (quote ((1 . (1.5))
                (2 . (1.3))
                (3 . (1.1))
                (4 . (1.1)))))

  (load-theme 'modus-operandi))

(use-package gruvbox-theme)

(use-package dbus
  :after gruvbox
  :straight (:type built-in)
  :config
  (defun my/set-theme-from-dbus-value (value)
    "Set the appropiate theme according to the color-scheme setting value."
    (message "value is %s" value)
    (if (equal value '1)
        (progn (message "Switch to dark theme")
               ;; (modus-themes-load-theme 'modus-vivendi))
               (consult-theme 'gruvbox-dark-hard))
      (progn (message "Switch to light theme")
             ;; (modus-themes-load-theme 'modus-operandi))))
             (consult-theme 'gruvbox-light-hard))))
  (defun my/color-scheme-changed (path var value)
    "DBus handler to detect when the color-scheme has changed."
    (when (and (string-equal path "org.freedesktop.appearance")
               (string-equal var "color-scheme"))
      (my/set-theme-from-dbus-value (car value))
      ))
  ;; Register for future changes
  (dbus-register-signal
   :session "org.freedesktop.portal.Desktop"
   "/org/freedesktop/portal/desktop" "org.freedesktop.portal.Settings"
   "SettingChanged"
   #'my/color-scheme-changed)

  ;; Request the current color-scheme
  (dbus-call-method-asynchronously
   :session "org.freedesktop.portal.Desktop"
   "/org/freedesktop/portal/desktop" "org.freedesktop.portal.Settings"
   "Read"
   (lambda (value) (my/set-theme-from-dbus-value (caar value)))
   "org.freedesktop.appearance"
   "color-scheme"
   ))

(use-package hydra)

(use-package surround
  :after hydra
  :config
  (defhydra hydra-surround (:color blue)
    "Surround..."
    ("s" surround-insert "surround")
    ("c" surround-change "change")
    ("k" surround-kill "kill inner")
    ("K" surround-kill-outer "kill outer")
    ("q" nil "close")))

(use-package meow
  :after surround
  :preface
  (defun my/page-down ()
    (interactive)
    (next-line (/ (window-total-height) 2))
    (recenter))
  (defun my/page-up ()
    (interactive)
    (previous-line (/ (window-total-height) 2))
    (recenter))
  :custom
  (meow-use-clipboard t)
  (meow-expand-hint-remove-delay 0)
  (meow-use-cursor-position-hack nil)
  :config
  (meow-thing-register 'angle '(regexp "<" ">") '(regexp "<" ">"))
  (add-to-list 'meow-char-thing-table '(?a . angle))
  (defun meow-setup ()
    (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
    (meow-motion-overwrite-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     ;; SPC j/k will run the original command in MOTION state.
     '("j" . "H-j")
     '("k" . "H-k")
     ;; Use SPC (0-9) for digit arguments.
     '("b" . consult-buffer)
     '("f" . consult-fd)
     '("s" . consult-ripgrep)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet))
    (meow-normal-define-key
     '("M-h" . windmove-left)
     '("M-l" . windmove-right)
     '("0" . meow-expand-0)
     '("9" . meow-expand-9)
     '("8" . meow-expand-8)
     '("7" . meow-expand-7)
     '("6" . meow-expand-6)
     '("5" . meow-expand-5)
     '("4" . meow-expand-4)
     '("3" . meow-expand-3)
     '("2" . meow-expand-2)
     '("1" . meow-expand-1)
     '("-" . negative-argument)
     '(";" . meow-reverse)
     '("," . meow-inner-of-thing)
     '("." . meow-bounds-of-thing)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("c" . meow-change)
     '("d" . meow-kill)
     '("D" . my/page-down)
     '("e" . meow-next-word)
     '("E" . meow-next-symbol)
     '("f" . meow-find)
     '("g" . meow-cancel-selection)
     '("G" . meow-grab)
     '("h" . meow-left)
     '("H" . meow-left-expand)
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("j" . meow-next)
     '("J" . meow-next-expand)
     '("k" . meow-prev)
     '("K" . meow-prev-expand)
     '("l" . meow-right)
     '("L" . meow-right-expand)
     '("m" . hydra-surround/body)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("q" . meow-quit)
     '("Q" . meow-goto-line)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("t" . meow-till)
     '("u" . meow-undo)
     '("U" . my/page-up)
     '("v" . my/page-down) ;; TODO change this
     '("w" . meow-mark-word)
     '("W" . meow-mark-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab) ;; useless
     '("z" . meow-visit)
     '("/" . meow-join)
     '("'" . repeat)
     '("<escape>" . ignore)))
  (meow-setup)
  (meow-global-mode 1))

;; Projectile

(use-package projectile
  :config
  (projectile-mode)
  :bind (("C-c p" . 'projectile-command-map))
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/projects")
    (setq projectile-project-search-path '("~/projects")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package rg)

;; Magit

(use-package magit
  :bind (("C-c g" . 'magit)))

(use-package vertico
  ;; :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
  ;; (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  ;; (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

(use-package orderless
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package consult
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-fd)                  ;; Alternative: consult-fd
         ("M-s g" . consult-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config
  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"
  (consult-customize consult-buffer :preview-key "M-/"))

(use-package which-key
  :config (which-key-mode)
  :config
  (setq which-key-idle-delay 0.3))

;; LSP

(use-package eglot
  :straight (:type built-in)
  :custom
  (eglot-code-action-indicator "")
  (eglot-ignored-server-capabilities '(:inlayHintProvider))
  :config
  (add-to-list 'eglot-server-programs
               `(typst-ts-mode . ,(eglot-alternatives
                                   '(("tinymist")
                                     ("typst-lsp")))))
  :bind((:map eglot-mode-map
              ("C-c l a"  . eglot-code-actions)
              ("C-c l e"  . flymake-show-diagnostics-buffer)
              ("M-q"      . eglot-format-buffer)
              ("C-c l r"  . eglot-rename))))

(use-package eldoc
  :custom
  (eldoc-idle-delay 0))

(use-package eldoc-box
  :after eglot
  :bind((:map eglot-mode-map
              ("C-c t"   . eldoc-box-help-at-point))))

(use-package yasnippet
  :custom
  (yas-global-mode t))

(use-package corfu
  :custom
  (corfu-quit-no-match nil)
  (corfu-popupinfo-delay 0.3)
  (corfu-popupinfo-max-width 70)
  (corfu-popupinfo-max-height 20)
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster))

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(use-package treesit
  :straight (:type built-in))

(use-package rainbow-mode)

(use-package pdf-tools
  :config
  (pdf-tools-install))

(use-package direnv)

;; Programming modes!

(use-package rust-mode)

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package csv-mode)

(use-package haskell-mode)

(use-package markdown-mode)

(use-package glsl-mode)

(use-package svelte-mode)

(use-package typst-ts-mode
  :straight '(:type git :host codeberg :repo "meow_king/typst-ts-mode"))

(use-package typescript-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode)))

;; (use-package gdscript-mode
;;   :straight (gdscript-mode
;;              :type git
;;              :host github
;;              :repo "godotengine/emacs-gdscript-mode"))

(use-package zig-mode
  :bind(:map zig-mode-map
        ("M-q" . zig-format-buffer))
  :custom
  (zig-format-on-save nil))
