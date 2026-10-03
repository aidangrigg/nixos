;; helper for typst lsp
(defun tinymist-pin-main ()
    (interactive)
    (eglot-execute-command (eglot-current-server) "tinymist.pinMain" (vector (buffer-file-name)))
    (message "Pinned main to %s" (buffer-file-name)))

(setq eglot-code-action-indicator "")
(setq eglot-ignored-server-capabilities '(:inlayHintProvider))

(add-to-list 'eglot-server-programs
             `(typst-ts-mode . ,(eglot-alternatives '(("tinymist") ("typst-lsp"))))
             `(python-mode . ,(eglot-alternatives '(("pylsp") ("pyright")))))

(with-eval-after-load 'eglot
  (defvar-keymap my/eglot-map
    :doc "org-mode bindings"
    "a"  #'eglot-code-actions
    "e"  #'flymake-show-diagnostics-buffer
    "d"  #'consult-flymake
    "r"  #'eglot-rename)

  (keymap-set eglot-mode-map "C-c l" my/eglot-map)
  (keymap-set eglot-mode-map "M-q"   #'eglot-format-buffer)
  (keymap-set eglot-mode-map "C-c t" #'eldoc-box-help-at-point))

;; eldoc
(setq eldoc-idle-delay 0.2
      eldoc-echo-area-use-multiline-p nil
      eglot-report-progress nil)

(setq corfu-quit-no-match nil
      corfu-auto t
      corfu-auto-delay 0.2
      corfu-popupinfo-delay 0.3
      corfu-popupinfo-max-width 70
      corfu-popupinfo-max-height 20)

(add-to-list 'completion-at-point-functions #'cape-dabbrev)
(add-to-list 'completion-at-point-functions #'cape-file)
(add-to-list 'completion-at-point-functions #'cape-elisp-block)
(advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)

(global-corfu-mode)
(corfu-popupinfo-mode)

(editorconfig-mode 1)
(yas-global-mode 1)

(setq zig-format-on-save nil)

(provide 'my-lsp)
