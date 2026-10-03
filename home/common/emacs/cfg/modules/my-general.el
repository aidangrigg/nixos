(electric-pair-mode nil)

(setq enable-recursive-minibuffers t)
(setq read-extended-command-predicate #'command-completion-default-include-p)
(setq minibuffer-prompt-properties
 '(read-only t cursor-intangible t face minibuffer-prompt))

;; backups
(setq backup-directory-alist `(("." . "~/.cache/emacs")))
(setq make-backup-files t)               ; backup of a file the first time it is saved.
(setq backup-by-copying t)               ; don't clobber symlinks
(setq version-control t)                 ; version numbers for backup files
(setq delete-old-versions t)             ; delete excess backup files silently
(setq delete-by-moving-to-trash t)
(setq kept-old-versions 6)               ; oldest versions to keep when a new numbered backup is made (default: 2)
(setq kept-new-versions 9)               ; newest versions to keep when a new numbered backup is made (default: 2)
(setq auto-save-default t)               ; auto-save every buffer that visits a file
(setq auto-save-timeout 20)              ; number of seconds idle time before auto-save (default: 30)
(setq auto-save-interval 200)            ; number of keystrokes between auto-saves (default: 300)
(setq create-lockfiles nil)
(setq auto-save-file-name-transforms
      `((".*" "~/.cache/emacs-saves/" t)))


;; isearch
(setq isearch-wrap-pause 'no-ding)

;; Dired
(setq dired-listing-switches "-aBhl  --group-directories-first")
(setq dired-kill-when-opening-new-dired-buffer t)
(setq dired-dwim-target t)
(setq dired-omit-files (rx (seq bol "." (not (any ".")))))

  ;; hunspell
(setq ispell-program-name "hunspell")
(setq ispell-local-dictionary "en_AU")
(setq ispell-local-dictionary-alist
 ;; Please note the list `("-d" "en_AU")` contains ACTUAL parameters passed to hunspell
 ;; You could use `("-d" "en_AU,en_AU-med")` to check with multiple dictionaries
      '(("en_AU" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_AU") nil utf-8)))

;; popper
(setq popper-reference-buffers
      '("\\*Messages\\*"
        "Output\\*$"
        "\\*Async Shell Command\\*"
        help-mode
        compilation-mode))

(popper-mode)
(popper-echo-mode)

(vertico-mode)
(marginalia-mode)
(savehist-mode)

(setq completion-styles '(orderless basic))
(setq completion-category-defaults nil)
(setq completion-category-overrides '((file (styles partial-completion))))

;; consult
(setq xref-show-xrefs-function #'consult-xref
      xref-show-definitions-function #'consult-xref)

(setq consult-async-input-debounce 0.05
      consult-async-input-throttle 0.1
      consult-async-refresh-delay 0.05)

(provide 'my-general)


