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
(setq straight-use-package-by-default t)

;; Org
(use-package org
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
  (org-agenda-start-with-log-mode t)
  (org-adapt-indentation nil)
  (org-enforce-todo-dependencies t)
  (org-startup-with-inline-images t)
  (org-id-track-globally t)
  (org-log-repeat nil)
  (org-hide-leading-stars t)
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
  :config
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
           :if-new (file+head "main/${slug}.org"
                              "#+title: ${title}\n")
           :immediate-finish t
           :unnarrowed t)
          ("r" "reference" plain "%?"
           :if-new
           (file+head "reference/${title}.org" "#+title: ${title}\n")
           :immediate-finish t
           :unnarrowed t)))
  :bind (("C-c r l" . org-roam-buffer-toggle)
         ("C-c r f" . org-roam-node-find)
         ("C-c r g" . org-roam-graph)
         ("C-c r i" . org-roam-node-insert)
         ("C-c r c" . org-roam-capture)
         ;; Dailies
         ("C-c r d" . org-roam-dailies-goto-today))
  :config
  (org-roam-db-autosync-mode))
  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  ;; (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  
  ;; (cl-defmethod org-roam-node-type ((node org-roam-node))
  ;;   "Return the TYPE of NODE."
  ;;   (condition-case nil
  ;;       (file-name-nondirectory
  ;;        (directory-file-name
  ;;         (file-name-directory
  ;;          (file-relative-name (org-roam-node-file node) org-roam-directory))))
  ;;     (error "")))



(use-package org-download
  :bind ((:map org-mode-map
	 ("C-c v" . 'org-download-clipboard)))
  :custom
  (org-download-image-dir "~/sync/notes/org/images"))

(use-package ace-window
  :bind (("M-o" . 'ace-window)))

(use-package auctex
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-master nil)
  (TeX-view-program-selection '((output-pdf "Zathura"))))

;;; Clean up the ui

(use-package emacs
  :preface
  (defun my/disable-scroll-bars (frame)
    (modify-frame-parameters frame
                             '((vertical-scroll-bars . nil)
                               (horizontal-scroll-bars . nil))))
  (defun my/page-down ()
    (interactive)
    (next-line (/ (window-total-height) 2))
    (recenter))

  (defun my/page-up ()
    (interactive)
    (previous-line (/ (window-total-height) 2))
    (recenter))
  :bind (("M-v"   . my/page-up)
         ("C-v"   . my/page-down)
         ("C-c f" . query-replace)
         ("M-h"   . shrink-windows-horizontally)
         ("M-l"   . enlarge-windows-horizontally)
         ("M-j"   . balance-windows))
  :custom

  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))

  (default-frame-alist '((font . "Roboto Mono")))
  
  (inhibit-startup-message t)
  (ring-bell-function 'ignore)
  (scroll-margin 8)
  (show-trailing-whitespace nil)
  (ediff-window-setup-function 'ediff-setup-windows-plain)
  (custom-file (expand-file-name "custom.el" user-emacs-directory))
  (compilation-scroll-output t)

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
  (load-theme 'minimal))

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
  :custom
  (meow-use-clipboard t)
  (meow-expand-hint-remove-delay 0)
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
     '("w" . save-buffer)
     '("f" . consult-fd)
     '("s" . consult-ripgrep)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet))
    (meow-normal-define-key
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
     '("d" . meow-delete)
     '("D" . meow-backward-delete)
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
     '("m" . meow-join)
     '("M" . hydra-surround/body)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("q" . meow-quit)
     '("Q" . meow-goto-line)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("s" . meow-kill)
     '("t" . meow-till)
     '("u" . meow-undo)
     '("U" . meow-undo-in-selection)
     '("v" . meow-visit)
     '("w" . meow-mark-word)
     '("W" . meow-mark-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab)
     '("z" . meow-pop-selection)
     '("/" . isearch-forward)
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

(use-package expand-region
  :bind (("C-." . 'er/expand-region)))

(use-package multiple-cursors
  :bind (("C-c c s" . 'mc/mark-next-like-this)
	 ("C-c c l" . 'mc/edit-lines)
	 ("C-c c d" . 'mc/mark-all-like-this-in-defun)))


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
  )

(use-package which-key
  :config (which-key-mode)
  :config
  (setq which-key-idle-delay 0.3))

;; LSP Tings


(use-package lsp-mode
  :preface
  :bind ((:map lsp-mode-map
	       ("C-c l a" . lsp-execute-code-action)
	       ("C-c l e" . flymake-show-diagnostics-buffer)
	       ("M-q"     . lsp-format-buffer)
	       ("C-c l r" . lsp-rename)))
  :hook ((rust-mode . lsp)
	 (js-mode . lsp)
	 (typescript-ts-mode . lsp)
	 (tsx-ts-mode . lsp)
         (c++-ts-mode . lsp))
  :config
  (setq lsp-fsharp-use-dotnet-tool-for-fsac nil))

(use-package lsp-ui
  :after lsp-mode
  :bind ((:map lsp-ui-mode-map
	       ("C-c k" . lsp-ui-doc-glance))))

(use-package yasnippet
  :custom
  (yas-global-mode t))

(use-package company
  :bind ((:map company-mode-map
	       ("M-/" . company-complete)
	  :map company-active-map
               ("TAB" . company-complete-selection)
               ("C-n" . company-select-next)
               ("C-p" . company-select-previous))
         (:map company-search-map
               ("TAB" . company-complete-selection)
               ("C-n" . company-select-next)
               ("C-p" . company-select-previous)))
  :custom
  (global-company-mode 1)
  (company-global-modes
   '(not text-mode message-mode git-commit-mode org-mode magit-status-mode))
  (company-idle-delay nil)
  (company-require-match nil)
  (company-show-numbers t)
  (company-tooltip-align-annotations t)
  (company-tooltip-limit 10)
  (company-tooltip-minimum 10)
  (company-format-margin-function nil)
  (company-tooltip-minimum-width 50))

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(use-package treesit-auto
  :config
  (global-treesit-auto-mode))

(use-package treesit
  :straight nil)

(use-package rainbow-mode)

(use-package pdf-tools
  :config
  (pdf-tools-install))

;; Programming modes!

(use-package rust-mode)

(use-package direnv
  :config
  (direnv-mode))

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package haskell-mode)

(use-package markdown-mode)

(use-package glsl-mode)

(use-package svelte-mode)

(use-package fsharp-mode
  :defer t
  :ensure t)

(use-package typescript-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode)))

(use-package gdscript-mode
  :straight (gdscript-mode
             :type git
             :host github
             :repo "godotengine/emacs-gdscript-mode"))

