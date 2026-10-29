;; c++
(setq c-default-style "bsd")

(defun ag/c-style ()
  (setq c-basic-offset 4
        tab-width 4
        indent-tabs-mode t)
  (c-set-offset 'innamespace 0))

(add-hook 'c-mode-common-hook #'ag/c-style)
(add-hook 'c-ts-mode-hook #'ag/c-style)
(add-hook 'c++-ts-mode-hook #'ag/c-style)

(provide 'ag-langs)
