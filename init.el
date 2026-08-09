;;; -*- mode: emacs-lisp, leaf-tree -*-



(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("org"   . "https://orgmode.org/elpa/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    (leaf hydra :ensure t)
    (leaf blackout :ensure t)
    (leaf el-get :ensure t)

    :config
    (leaf-keywords-init))
  )


(leaf *leaf-inits
  :config

 (leaf leaf-convert :ensure t)
  
  (leaf leaf-tree
    :ensure t
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left)))


  
  (leaf cus-edit
    :doc "tools for customizing Emacs and Lisp packages"
    :tag "builtin" "faces" "help"
    :custom `((custom-file . ,(locate-user-emacs-file "custom.el"))))

  (leaf macrostep
    :ensure t
    :bind (("C-c e" . macrostep-expand)))
  
  )

(leaf *emacs-config
  :config

  (leaf *lang
    :config
    ;; ;; デフォルト言語
    (set-language-environment "Japanese")

    ;; ;; デフォルトの文字コード
    (set-default-coding-systems 'utf-8-dos)
    (prefer-coding-system 'utf-8-dos)
    (set-keyboard-coding-system 'cp932)
    (set-terminal-coding-system 'cp932)
    ;; (setq locale-coding-system 'utf-8) ; これがあるとorg-scheduleで曜日が文字化けするのでコメントアウト

    ;; ;; ファイルパスの文字コード
    (setq default-file-name-coding-system 'japanese-cp932-dos)

    ;; SHELL設定
    (setenv "LANG" "ja_JP.UTF-8")
    (setenv "LC_ALL" "ja_JP.UTF-8")
    )

  (leaf *bakcup
    :custom
    (
     (make-backup-files . t)
     (create-lockfiles . nil)
     
;;     (backup-directory-alist . (cons (cons "\\.*$" (expand-file-name "~/.emacs.d/backup"))
;;				     backup-directory-alist))
     )
    )

  (leaf *display
    :custom
    (
     ;; Welcomeメッセージを非表示
     (inhibit-startup-message . t)
     
     ;; ファイル名補完時大文字小文字を区別しない
     (completion-ignore-case . t)

     ;; 画面端 + 5行でスクロールする。
     (scroll-margin . 5)

     ;; スクロールされる行数を1行にする。
     (scroll-conservatively . 1)
     )
    :config
    ;; メニューバーを非表示
    (menu-bar-mode 0)

    ;; ツールバーを非表示
    (tool-bar-mode -1)

    ;; スクロールバー非表示
    (scroll-bar-mode -1)

    ;; yes、noの入力をy、nに変更
    (fset 'yes-or-no-p 'y-or-n-p)

    ;; バッファ自動再読み込み
    (global-auto-revert-mode 1)

    ;; キー入力時、マウスカーソルを左上に移動(一時的)
    (mouse-avoidance-mode 'exile)

    ;; 行番号表示
    (global-display-line-numbers-mode t)

    ;; スクリーンの最大化
    (set-frame-parameter nil 'fullscreen 'maximized)

    ;; 選択範囲を削除してから文字を挿入
    (delete-selection-mode)
    )


  (leaf *revert-buffer
    :config
    (defun revert-all-buffers ()
      "Refreshes all open buffers from their respective files."
      (interactive)
      (dolist (buf (buffer-list))
	(with-current-buffer buf
          (when (and (buffer-file-name) (file-exists-p (buffer-file-name)) (not (buffer-modified-p)))
            (revert-buffer t t t) )))
      (message "Refreshed open files.") )

    (global-auto-revert-mode 1)
    )


  (leaf recentf
    :doc "keep track of recently opened files"
    :tag "builtin"
    :added "2026-08-08")

  (leaf *emacsclient
    :after server
    :config
    ;(require 'server)
    (unless (server-running-p)
      (server-start))
    )

  (leaf *theme
   ;:after generic-x
    :config

    (leaf smart-mode-line
      :doc "A color coded smart mode-line"
      :req "emacs-24.3" "rich-minority-0.1.1"
      :tag "themes" "faces" "mode-line" "emacs>=24.3"
      :url "https://github.com/Malabarba/smart-mode-line"
      :added "2026-08-08"
      :emacs>= 24.3
      :ensure t
      :after rich-minority)




    (add-to-list 'custom-theme-load-path "~/.emacs.d/theme/")
    (load-theme 'hodumi t)
    (initialize-hodumi-theme)
    )

  (leaf *misc
    :custom
    (
     (delete-by-moving-to-trash . 1)
     )
    :config
    ;; ?
    (electric-indent-mode -1)

    ;; font
    (set-face-attribute 'default nil 
			:family "Utatane"
		    :height 110)


    )
  )


(leaf uniquify
  :custom
  ((uniquify-buffer-name-style . 'post-forward-angle-brackets))
  )


(leaf whitespace
  :doc "minor mode to visualize TAB, (HARD) SPACE, NEWLINE"
  :tag "builtin"
  :added "2026-03-22"
  :after cl
  :custom
  (
   ;; スペースの定義は全角スペース
   (whitespace-space-regexp . "\x3000+")
   )
  :config
  ;; 半角スペースと改行を除外
  (dolist (d '((space-mark ?\ ) (newline-mark ?\n)))
    (setq whitespace-display-mappings
          (delete-if
           '(lambda (e) (and (eq (car d) (car e))
                             (eq (cadr d) (cadr e))))
           whitespace-display-mappings)))

  ;; 全角スペースと改行を追加
  (dolist (e '((space-mark   ?\x3000 [?\□])
               (newline-mark ?\n     [?\u21B5 ?\n] [?$ ?\n])))
    (add-to-list 'whitespace-display-mappings e))

  ;; 強調したくない要素を削除
  (dolist (d '(face lines space-before-tab newline-mark
                    indentation empty space-after-tab tab-mark))
    (setq whitespace-style (delq d whitespace-style)))
  )




(leaf view-mode
  :hook my-set-key-atkey-map
  :bind
  (
   ;; <f9> をview-mode切替に設定
   ("<f9>" . view-mode)

   (view-mode
    ("C-c C-q" . view-quit)
    ("f" . forward-char)
    ("b" . backward-char)	
    ("n" . next-line)
    ("p" . previous-line)

    ("a" . mwim-beginning-of-code-or-line)
    ("e" . mwim-end-of-code-or-line)
    ("l" . recenter-top-bottom)
    ))
  :config
  (unbind-key "e" view-mode-map)
  (unbind-key "q" view-mode-map)
  (unbind-key "@" view-mode-map)
  )

(leaf hexl-mode
  :hook my-set-key-atkey-map)

(leaf conf-mode
  :doc "Simple major mode for editing conf/ini/properties files"
  :tag "builtin"
  :added "2026-08-08"
  ;:mode "\\.ini\\'"
  )

(leaf sql
  :doc "specialized comint.el for SQL interpreters"
  :tag "builtin"
  :added "2026-08-08"
;  :mode "\\.sql\\'"
  )


(leaf mwim
  :doc "Switch between the beginning/end of line or code"
  :tag "convenience"
  :url "https://github.com/alezost/mwim.el"
  :added "2026-03-14"
  :ensure t
  :bind
  (
   ("C-a" . mwim-beginning-of-code-or-line) ; aaa
   ("C-e" . mwim-end-of-code-or-line)
   )
  )


(leaf ddskk
  :doc "Daredevil SKK (Simple Kana to Kanji conversion program)."
  :req "ccc-1.43" "cdb-20141201.754"
  :tag "input method" "mule" "japanese"
  :url "https://github.com/skk-dev/ddskk"
  :added "2026-03-14"
  :ensure t
  :custom 
  (
   (skk-show-annotation . nil)
   (skk-search-katakana . 'jisx0201-kana)
   )
  :bind (("C-o" . skk-mode))
  )



(leaf bm
  :doc "Visible bookmarks in buffer"
  :tag "persistent" "faces" "highlight" "bookmark"
  :url "https://github.com/joodland/bm"
  :added "2026-08-06"
  :ensure t
  :bind (("C-M-;" . bm-toggle)
	 ("C-M-n" . bm-next)
	 ("C-M-p" . bm-previous)
	 )
  )

(leaf save-visited-files
  :doc "Save opened files across sessions"
  :url "https://github.com/nflath/save-visited-files"
  :added "2026-08-08"
  :ensure t
  :custom ( (save-visited-files-ignore-tramp-files . t)
	    )
  :config
  (turn-on-save-visited-files-mode)
  )

(leaf *git
  :config

  (leaf magit
    :doc "A Git porcelain inside Emacs."
    :req "emacs-28.1" "compat-31.0" "cond-let-1.1" "llama-1.0" "magit-section-4.7" "seq-2.24" "transient-0.13" "with-editor-3.5"
    :tag "vc" "tools" "git" "emacs>=28.1"
    :url "https://github.com/magit/magit"
    :added "2026-08-08"
    :emacs>= 28.1
    :ensure t
    :after compat cond-let llama magit-section with-editor)

  (leaf git-gutter
    :doc "Port of Sublime Text plugin GitGutter"
    :req "emacs-25.1"
    :tag "emacs>=25.1"
    :url "https://github.com/emacsorphanage/git-gutter"
    :added "2026-03-22"
    :emacs>= 25.1
    :ensure t)
  )


(leaf *minibuffer
  :config

  (leaf diminish
    :doc "Diminished modes are minor modes with no modeline display"
    :req "emacs-24.3"
    :tag "codeprose" "minor" "diminish" "extensions" "emacs>=24.3"
    :url "https://github.com/myrjola/diminish.el"
    :added "2026-03-22"
    :emacs>= 24.3
    :ensure t
    
    :config
    ;; [[http://qiita.com/tadsan/items/c859c5c04724cbda75fc][指定したマイナーモードを表示しない(diminish篇)]]からコピー
    (defmacro safe-diminish (file mode &optional new-name)
      "https://github.com/larstvei/dot-emacs/blob/master/init.org"
      `(with-eval-after-load ,file
	 (diminish ,mode ,new-name)))


    (safe-diminish "abbrev" 'abbrev-mode)
    (safe-diminish "auto-complete" 'auto-complete-mode)
    ;; (safe-diminish "flycheck" 'flycheck-mode)
    (safe-diminish "google-this" 'google-this-mode)
    (safe-diminish "helm-mode" 'helm-mode)
    (safe-diminish "rainbow-mode" 'rainbow-mode)
    (safe-diminish "undo-tree" 'undo-tree-mode)
    (safe-diminish "whitespace" 'global-whitespace-mode)
    (safe-diminish "yasnippet" 'yas-minor-mode)
    (safe-diminish "editorconfig" 'editorconfig-mode)
    (safe-diminish "company" 'company-mode)
    )


  (leaf vertico
    :doc "VERTical Interactive COmpletion"
    :req "emacs-29.1" "compat-30"
    :tag "completion" "matching" "files" "convenience" "emacs>=29.1"
    :url "https://github.com/minad/vertico"
    :added "2026-04-25"
    :emacs>= 29.1
    :ensure t
    :global-minor-mode t
    :bind (vertico-map
	    ("C-r" . vertico-previous)
	    ("C-s" . vertico-next)
	    ("C-l" . vertico-directory-up)

	    )
    )

  (leaf consult
    :tag "completion"
    :ensure t
    :package t
    :global-minor-mode t
    :bind
    (
     ("C-s" . consult-line)
     ("C-x C-b" . switch-to-buffer)))

  (leaf orderless
    :tag "completion"
    :ensure t
    :global-minor-mode t
    :custom
    `((completion-styles . '(orderless))
      (orderless-matching-styles
       . '(
					; orderless-prefixes
					; orderless-flex
           orderless-regexp
           ;; orderless-initialism
	   ;; orderless-literal
	   ))))


  (leaf savehist
    :doc "Save minibuffer history"
    :tag "builtin"
    :added "2026-04-25"
    :global-minor-mode t
    )


  (leaf marginalia
    :doc "Enrich existing commands with completion annotations"
    :req "emacs-29.1" "compat-30"
    :tag "completion" "matching" "help" "docs" "emacs>=29.1"
    :url "https://github.com/minad/marginalia"
    :added "2026-04-25"
    :emacs>= 29.1
    :ensure t
    :global-minor-mode t
    ;; :after compat

    ;; :bind
    ;; (:map minibuffer-mode-map

    ;;       ("M-A" . marginalia-cycle))
    :custom
    (marginalia-max-relative-age . 0)
    :config
    (defun marginalia--time-absolute (time)
      "Format TIME as yyyy-mm-dd hh:mm:ss."
      (format-time-string "%Y-%m-%d %H:%M:%S" time))
    )

  (leaf projectile
    :doc "Manage and navigate projects in Emacs easily."
    :req "emacs-28.1" "compat-30"
    :tag "convenience" "project" "emacs>=28.1"
    :url "https://github.com/bbatsov/projectile"
    :added "2026-07-11"
    :emacs>= 28.1
    :ensure t
    :after compat
    :custom ( (projectile-track-known-projects-automatically . t))
    )

  (leaf consult-projectile
    :doc "Consult integration for projectile"
    :req "emacs-25.1" "consult-0.12" "projectile-2.5.0"
    :tag "convenience" "emacs>=25.1"
    :url "https://gitlab.com/OlMon/consult-projectile"
    :added "2026-07-05"
    :emacs>= 25.1
    :ensure t
    ;:after consult projectile
    :config
    )

  (leaf company
    :doc "Modular text completion framework"
    :req "emacs-26.1" "posframe-1.5.1"
    :tag "matching" "convenience" "abbrev" "emacs>=26.1"
    :url "http://company-mode.github.io/"
    :added "2026-08-02"
    :emacs>= 26.1
    :ensure t
    ;:global-minor-mode t
    :after posframe
    :custom  ((completion-ignore-case . t)
	      (company-idle-delay . 0)
	      (company-minimum-prefix-length . 2)
	      (company-selection-wrap-around . 1)
	      (company-transformers . (company-sort-by-occurrence company-sort-by-backend-importance))
	      )    
    :config
    )
  (global-company-mode) ;何故か:configに置くと動かないので、ここに置く


  (leaf company-statistics
    :doc "Sort candidates using completion history"
    :req "emacs-24.3" "company-0.8.5"
    :tag "matching" "convenience" "abbrev" "emacs>=24.3"
    :url "https://github.com/company-mode/company-statistics"
    :added "2026-08-02"
    :emacs>= 24.3
    :ensure t
    :after company)

  (leaf consult-company
    :doc "Consult frontend for company"
    :req "emacs-27.1" "company-0.9" "consult-0.9"
    :tag "emacs>=27.1"
    :url "https://github.com/mohkale/consult-company"
    :added "2026-08-02"
    :emacs>= 27.1
    :ensure t
    :after company consult
    ) 


  )


(leaf yascroll
  :doc "Yet Another Scroll Bar Mode"
  :req "emacs-26.1"
  :tag "convenience" "emacs>=26.1"
  :url "https://github.com/emacsorphanage/yascroll"
  :added "2026-08-08"
  :emacs>= 26.1
  :ensure t
  :config
  (global-yascroll-bar-mode 1)
  )

(leaf editorconfig
  :doc "EditorConfig Plugin"
  :tag "builtin"
  :added "2026-07-25"

  )


(leaf *common-lisp
  :config
  ;; use roswell
  (load (expand-file-name "C:/Users/USER/.roswell/helper.el"))


  )



(leaf web-mode
  :doc "Major mode for editing web templates"
  :req "emacs-24.3.1"
  :tag "languages" "emacs>=24.3.1"
  :url "https://web-mode.org"
  :added "2026-06-07"
  :emacs>= 24.3
  :ensure t
  :mode ((("\\.php\\"  "\\.ctp\\"). web-mode)
	 (("\\.js\\"). web-mode)
	 )
  )



(leaf copilot
  :doc "An Emacs plugin for GitHub Copilot"
  :req "emacs-27.2" "editorconfig-0.8.2" "jsonrpc-1.0.14" "compat-30" "track-changes-1.4"
  :tag "copilot" "convenience" "emacs>=27.2"
  :url "https://github.com/copilot-emacs/copilot.el"
  :added "2026-07-25"
  :emacs>= 27.2
  :ensure t
;  :after editorconfig jsonrpc compat track-changes
)

(leaf copilot-chat
  :doc "Copilot chat interface"
  :req "emacs-30.1" "aio-1.0" "request-0.3.2" "transient-0.8.3" "polymode-0.2.2" "org-9.4.6" "markdown-mode-2.6" "shell-maker-0.76.2" "mcp-0.1.0"
  :tag "tools" "convenience" "emacs>=30.1"
  :url "https://github.com/chep/copilot-chat.el"
  :added "2026-07-26"
  :emacs>= 30.1
  :ensure t
;  :after aio polymode org markdown-mode shell-maker mcp
)

(leaf elauncher
  ;; :doc "Program launcher for Windows."
  ;; :tag "tools" 
  :el-get "hodumi/elauncher"
  ;:emacs>= 30.1			       
  )


(leaf my-func
  :config
  (defun fix-separate (str lst)
    (cond
     ((string= "" str)
      nil)
     ((not lst) ;最後
      (list :superfluous str))
     ((consp (car lst)) ; (タイトル . 桁数)
      (cons
       (cons (caar lst) (substring str 0 (cdar lst)))
       (fix-separate (substring str (cdar lst)) (cdr lst))))
     (t ; 桁数
      (cons
       (substring str 0 (car lst))
       (fix-separate (substring str (car lst)) (cdr lst))))))


  (defun pritty-print-list (list)
    (dolist (lst list)
      (print lst)))



  (defun repeat-list-item (cnt lst)
    (cond
     ((= cnt 1)
      lst
      )
     (t
      (append
       lst
       (repeat-list-item (1- cnt) lst)))))

  (defun open-init-file ()
    (interactive)
    (find-file "~/.emacs.d/init.el"))





  )

(leaf *key-bind
  :config
  ;; C-h
  (keyboard-translate ?\C-h ?\C-?)

  (leaf *=global
    :bind
    (
     ;; unbind
     ("C-/" . nil)
     ("C-t" . nil)

     ;; 元の「一画面上下移動」を無効化
     ("M-v" . nil)
     ("C-v" . nil)

     ;; C-x kと間違えやすいキーバインドを削除
     ("C-x C-k <RET>" . nil)
     
     ;; 選択削除を可能にするため、
     ;; C-dを`delete-char`から`delete-forward-char`(<del>と同じ関数)に変更
     ("C-d" . delete-forward-char)

     ;; C-S-kを「一行削除」に変更
     ("C-S-k" . kill-whole-line)

     ;; M-d, M-hを1単語ごとに前後削除に変更
     ("M-d" . delete-word)
     ("M-h" . backward-delete-word)

     ;; shell-commandをeshell-commandに変更
     ("M-!" . eshell-command)

     ;; M-<f5>とESC <f5>にrevert-all-buffersを設定
     ("M-<f5>" . revert-all-buffers)
     ("ESC <f5>" . revert-all-buffers)

     ;; <f5>にrevert-bufferを設定
     ("<f5>" . revert-buffer)

     ;; <f10> を折り返し表示のtoggleに設定
     ("<f10>" . toggle-truncate-lines)

     ;; C-!にeshell起動を設定
     ("C-!" . eshell)

     
     ;; C-s -> helm-swoop
     ;;(bind-key (kbd "C-s") 'helm-swoop)

     )
    
    :bind*
    (
     ;; M-pを「一画面上に移動」に変更
     ("M-p" . scroll-down-command)

     ;; M-nを「一画面下に移動」に変更   
     ("M-n" . scroll-up-command)
     )
    )
  (leaf *=@-prefix
    :config

    ;; @ prefixを作成 
    (defvar my-atkey-prefix (kbd "@"))
    (defvar my-atkey-map (make-keymap))
    (define-key global-map my-atkey-prefix my-atkey-map)
    
    (defun my-set-key-atkey-map ()
      (local-set-key my-atkey-prefix my-atkey-map))
    )

  (leaf *=@-key-bind      
    :bind
    (
     ;; @ @
     ("@ @" . (lambda () (interactive) (insert "@")))

     ;; @ gで行ジャンプ       
     ("@ G" . goto-line) ; consult-goto-lineは巨大ファイルだと負荷が大きいためこっちを使う

     ;; @ bで、buffer-listを開く
     ("@ b" . switch-to-buffer)

     ;; @ oで、別ウィンドウに移動
     ("@ o" . other-window)

     ;; @ kで、現在バッファの削除
     ("@ k" . kill-buffer)

     ;; @ vで、プロジェクトのvcを表示
     ("@ v" . magit)

     ;; @ hで、helm-projectileを表示
     ("@ h" . consult-projectile)

     ;; @ p hで、helm-projectileを表示
     ("@ p h" . consult-projectile-switch-project)


     ;; @ 0で、window削除
     ("@ 0" . delete-window)

     ;; @ 2で、window縦分割
     ("@ 2" . split-window-below)

     ;; @ 3で、window横分割
     ("@ 3" . split-window-right)
     
     )
    )
  )



(provide 'init)
