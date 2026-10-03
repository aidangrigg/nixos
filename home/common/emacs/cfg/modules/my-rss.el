(add-hook 'elfeed-show-mode-hook #'olivetti-mode)

(setq elfeed-feeds
      '("https://neilzone.co.uk/index.xml"
        "https://evanhahn.com/blog/index.xml"
        "https://geohot.github.io/blog/feed.xml"
        "https://whhone.com/index.xml"))


(provide 'my-rss)
