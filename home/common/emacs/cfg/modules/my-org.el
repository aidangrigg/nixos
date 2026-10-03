;; deps

(require' org)
(require 'org-tempo)

;; fn

(defun my/daily-agenda ()
  (interactive)
  (org-agenda nil "d"))

(defun my/overview-agenda ()
  (interactive)
  (org-agenda nil "o"))

(defun my/org-roam-search ()
  (interactive)
  (consult-ripgrep org-roam-directory))

(defun my/org-roam-weekly-goto-week ()
  (interactive)
  (let* ((week (format-time-string "%U"))
         (year (format-time-string "%Y"))
         (title (concat "Week " week)))
    (org-roam-capture-
     :templates
     '(("w" "weekly" plain "%?" :if-new
        (file+head "weekly/${year}/${week}.org"
                   "#+title: ${title}\n")
        :immediate-finish t
        :unnarrowed t))
     :info (list :week (concat "week" week) :year year)
     :node (org-roam-node-create :title title)
     :props '(:finalize find-file))))

(defun my/tag-new-node-as-draft ()
  (org-roam-tag-add '("draft")))

(defun my/org-roam-node-from-cite (keys-entries)
  (interactive (list (citar-select-ref)))
  (let ((title (citar-format--entry "${title}" keys-entries))
        (author (citar-format--entry "${author}" keys-entries)))
    (org-roam-capture-
     :templates
     '(("r" "reference" plain "%?" :if-new
        (file+head "reference/${citekey}.org"
                   ":PROPERTIES:\n:ROAM_REFS: [cite:@${citekey}]\n:END:\n#+title: ${title}\n#+author: ${author}")
        :immediate-finish t
        :unnarrowed t))
     :info (list :citekey keys-entries :author author)
     :node (org-roam-node-create :title title)
     :props '(:finalize find-file))))

;; hooks

(add-hook 'org-roam-capture-new-node-hook #'my/tag-new-node-as-draft)
(add-hook 'org-mode-hook 'variable-pitch-mode)
(add-hook 'org-mode-hook 'org-indent-mode)
(add-hook 'org-mode-hook #'org-timed-alerts-mode)

;; binds

(defvar-keymap my/org-roam-map
  :doc "org-roam bindings"
  "l" #'org-roam-buffer-toggle
  "f" #'org-roam-node-find
  "g" #'org-roam-graph
  "i" #'org-roam-node-insert
  "c" #'org-roam-capture
  "d" #'org-roam-dailies-goto-today
  "s" #'my/org-roam-search)
  ;; :map org-mode-map
  ;; ("C-c t" . org-roam-tag-add)

(defvar-keymap my/org-map
  :doc "org-mode bindings"
  "a" #'org-agenda
  "c" #'org-capture
  "d" #'my/daily-agenda
  "o" #'my/overview-agenda)

(keymap-global-set "C-c o" my/org-map)
(keymap-global-set "C-c r" my/org-roam-map)

(with-eval-after-load 'org
  (keymap-set org-mode-map "C-c b" #'org-cite-insert)
  (keymap-set org-mode-map "C-c v" #'org-download-clipboard))

;; custom

(setq org-download-image-dir "~/sync/notes/org/images")

(setq org-agenda-files
      '("~/sync/notes/org/tasks.org"
        "~/sync/notes/org/mobile.org"
        "~/sync/notes/org/birthdays.org"
        "~/sync/notes/org/habits.org"))

(setq org-use-fast-todo-selection 'auto)
(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "PROG(p)" "INTR(i)" "|" "DONE(d!)" "CNCL(c)")))

(setq org-agenda-span 'day) ;; default to daily agenda
(setq org-agenda-todo-ignore-scheduled 'future) ;; hide future tasks in normal view
(setq org-agenda-todo-ignore-time-comparison-use-seconds t)
(setq org-agenda-skip-deadline-prewarning-if-scheduled 'pre-scheduled) ;; hides deadline prewarning

(setq org-agenda-custom-commands
      '(("n" "Agenda / INTR / PROG / NEXT"
         ((agenda "" ((org-super-agenda-groups
                       '((:name "Habits" :habit t :order 9)
                         (:anything t)))))
          (todo "INTR" nil)
          (todo "PROG" nil)
          (todo "NEXT" nil))
         nil)))

(setq org-capture-templates
 '(("t" "Task" entry
    (file+olp "~/sync/notes/org/tasks.org" "Inbox")
    "* TODO %?\n"
    :empty-lines 1)
   ("s" "Shopping List" entry
    (file "~/sync/notes/org/shopping_list.org")
    "* TODO %?\n")))

(setq org-agenda-restore-windows-after-quit t) ; restore window configuration on exit
(setq org-agenda-start-with-log-mode t) ; log mode (shows what has been done)
(setq org-adapt-indentation nil)
;; (setq org-enforce-todo-dependencies t)
(setq org-startup-with-inline-images t)
(setq org-hide-leading-stars t)
(setq org-agenda-skip-timestamp-if-done t)
(setq org-agenda-skip-deadline-if-done t)
(setq org-agenda-skip-scheduled-if-done t)
(setq org-agenda-skip-timestamp-if-deadline-is-shown t)
(setq org-log-into-drawer t)
(setq org-log-repeat t)

;; latex
(setq org-startup-with-latex-preview t)
(setq org-latex-preview-ltxpng-directory "~/.cache/org-ltximg")
(setq org-format-latex-options
      (plist-put org-format-latex-options :scale 1.5))

;; org habit
(setq org-extend-today-until 4) ;; 4am is when day "ends"
(add-to-list 'org-modules 'org-habit t)
(setq org-habit-show-habits-only-for-today t)

;; babel
(org-babel-do-load-languages
   'org-babel-load-languages '((C . t)
			                   (haskell . t)
			                   (shell . t)
			                   (plantuml . t)))

(setq org-plantuml-exec-mode 'plantuml)

;; org roam
(setq org-roam-node-display-template
      (concat "${type:15} ${title:*} " (propertize "${tags:10}" 'face 'org-tag)))

(setq org-roam-completion-everywhere t)
(setq org-roam-directory (file-truename "~/sync/notes/org/zettel"))
(setq org-roam-capture-templates
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
         :unnarrowed t)
        ("yt" "youtube video" plain "%?"
         :target
         (file+head
          "reference/${slug}.org"
          "#+title: ${title}\n#+filetags: :notes:youtube:\n")
         :immediate-finish t
         :unnarrowed t)))

;; org-timed-alerts
(setq alert-default-style 'notifications)
(setq org-timed-alerts-alert-function #'alert)
(setq org-timed-alerts-tag-exclusions nil)
(setq org-timed-alerts-default-alert-props nil)
(setq org-timed-alerts-warning-times '(-10 -5))
(setq org-timed-alerts-agenda-hook-p t)
(setq org-timed-alerts-default-alert-props '(:title (lambda () (save-excursion (org-get-heading t nil t t)))))
(setq org-timed-alerts-todo-exclusions `("DONE"))
(setq org-timed-alerts-final-alert-string "%todo %headline")
(setq org-timed-alerts-warning-string (concat "%todo %headline at %alert-time\n " "%warning-time minute warning"))

;; org-appear
(setq org-hide-emphasis-markers t)
(setq org-appear-autoemphasis t)
(setq org-appear-autolinks t)
(setq org-appear-inside-latex t)
(setq org-appear-autosubmarkers t)
(setq org-appear-trigger 'manual)

(add-hook 'org-mode-hook #'org-appear-mode)
(add-hook 'org-mode-hook
          (lambda ()
            (add-hook 'meow-insert-enter-hook #'org-appear-manual-start nil t)
            (add-hook 'meow-insert-exit-hook #'org-appear-manual-stop nil t)))

;; citar
(setq org-cite-global-bibliography '("~/sync/My Library.bib"))
(setq citar-bibliography org-cite-global-bibliography)
(setq org-cite-insert-processor 'citar)
(setq org-cite-follow-processor 'citar)
(setq org-cite-activate-processor 'citar)

(org-super-agenda-mode)
(org-roam-db-autosync-mode)

(provide 'my-org)



