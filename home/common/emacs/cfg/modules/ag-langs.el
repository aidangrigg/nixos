;; c++
(setq c-default-style "bsd")
(add-hook 'c-mode-common-hook
          (lambda ()
            (setq c-basic-offset 4
                  tab-width 4
                  indent-tabs-mode t)
            (c-set-offset 'innamespace 0)))

(add-hook 'c-mode-common-hook #'my-c-setup)
(add-hook 'c-ts-mode-hook #'my-c-setup)
(add-hook 'c++-ts-mode-hook #'my-c-setup)

(provide 'ag-langs)
