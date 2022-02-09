;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))
;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

(setq straight-check-for-modifications '(check-on-save))
 (defvar bootstrap-version)
 (let ((bootstrap-file
        (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
       (bootstrap-version 5))
   (unless (file-exists-p bootstrap-file)
     (with-current-buffer
         (url-retrieve-synchronously
          "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
          'silent 'inhibit-cookies)
       (goto-char (point-max))
       (eval-print-last-sexp)))
   (load bootstrap-file nil 'nomessage))
 (setq package-enable-at-startup nil)
 (straight-use-package 'use-package)
 (setq straight-use-package-by-default t)

(push "~/.emacs.d/lisp" load-path)
(use-package no-littering) ;; Use no-littering to automatically set common paths to the new user-emacs-directory

(use-package org
  :straight org-contrib)
  (use-package general)
  (use-package git-gutter-fringe)
  (use-package diminish)
  (use-package gnuplot)
  (use-package htmlize)
  (use-package dsvn)
  (use-package daemons)
(use-package hide-mode-line)

;; (defun open-edit-menu-at-position (event)
;;   "Opens the edit menu at the given position"
;;   (interactive "e")
;;   (mouse-minibuffer-check event)
;;   (x-popup-menu event menu-bar-edit-menu))
(use-package mouse3
  :config
  (setq mouse3-menu-always-flag t  )
 ;; (global-set-key (kbd "<mouse-3>") 'mouse3-action-wo-save-then-kill)
  )

(if (fboundp 'with-eval-after-load)
    (defalias 'after-load 'with-eval-after-load)
  (defmacro after-load (feature &rest body)
    "After FEATURE is loaded, evaluate BODY."
    (declare (indent defun))
    `(eval-after-load ,feature
       '(progn ,@body))))

(defun add-auto-mode (mode &rest patterns)
  "Add entries to `auto-mode-alist' to use `MODE' for all given file `PATTERNS'."
  (dolist (pattern patterns)
    (add-to-list 'auto-mode-alist (cons pattern mode))))

(defun sanityinc/string-all-matches (regex str &optional group)
  "Find all matches for `REGEX' within `STR', returning the full match string or group `GROUP'."
  (let ((result nil)
        (pos 0)
        (group (or group 0)))
    (while (string-match regex str pos)
      (push (match-string group str) result)
      (setq pos (match-end group)))
    result))

(defun delete-this-file ()
  "Delete the current file, and kill the buffer."
  (interactive)
  (unless (buffer-file-name)
    (error "No file is currently being edited"))
  (when (yes-or-no-p (format "Really delete '%s'?"
                             (file-name-nondirectory buffer-file-name)))
    (delete-file (buffer-file-name))
    (kill-this-buffer)))

(defun rename-this-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (unless filename
      (error "Buffer '%s' is not visiting a file!" name))
    (progn
      (when (file-exists-p filename)
        (rename-file filename new-name 1))
      (set-visited-file-name new-name)
      (rename-buffer new-name))))

(defvar after-make-console-frame-hooks '()
  "Hooks to run after creating a new TTY frame")
(defvar after-make-window-system-frame-hooks '()
  "Hooks to run after creating a new window-system frame")
(defun run-after-make-frame-hooks (frame)
  "Run configured hooks in response to the newly-created FRAME.
  Selectively runs either `after-make-console-frame-hooks' or
  `after-make-window-system-frame-hooks'"
  (with-selected-frame frame
    (run-hooks (if window-system
                   'after-make-window-system-frame-hooks
                 'after-make-console-frame-hooks))))
(add-hook 'after-make-frame-functions 'run-after-make-frame-hooks)
(defconst sanityinc/initial-frame (selected-frame)
  "The frame (if any) active during Emacs initialization.")
(add-hook 'after-init-hook
          (lambda () (when sanityinc/initial-frame
                       (run-after-make-frame-hooks sanityinc/initial-frame))))

(global-set-key [mouse-4] (lambda () (interactive) (scroll-down 1)))
(global-set-key [mouse-5] (lambda () (interactive) (scroll-up 1)))
(autoload 'mwheel-install "mwheel")
(defun sanityinc/console-frame-setup ()
  (xterm-mouse-mode 1) ; Mouse in a terminal (Use shift to paste with middle button)
  (mwheel-install))
(add-hook 'after-make-console-frame-hooks 'sanityinc/console-frame-setup)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package move-dup
  :config(global-move-dup-mode)
  :bind( ("M-<up>" . md-move-lines-up)
         ("M-<down>" . md-move-lines-down)
         ("C-c d" . move-dup-duplicate-down)
         ("C-c u" . move-dup-duplicate-up)))

(use-package whole-line-or-region
  :defer nil
  :config (whole-line-or-region-global-mode t)
  :bind ("M-j". comment-indent))

(setq initial-scratch-message
              (concat ";; Hey, Your a Geniuse " user-login-name "!!!\n;; Keep up the great work!  - Emacs ♥\n\n"))

(add-to-list 'default-frame-alist '(font .  "Source Code Pro Medium 14"))
(set-face-attribute 'default nil :height 150)

(use-package doom-themes
  :straight t
  :config
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
	    doom-themes-enable-italic t)     ; if nil, italics is universally disabled
  (load-theme 'doom-one t)
  (doom-themes-org-config))
;; to load theme properly when new client frame is created 
(add-hook 'after-make-frame-functions
            (lambda (frame)
              (with-selected-frame frame
                (load-theme 'doom-one t))))
;; Don't prompt to confirm theme safety. This avoids problems with
;; first-time startup on Emacs > 26.3.
(setq custom-safe-themes t)

(use-package dimmer
  :init (dimmer-mode)
  :config (setq-default dimmer-fraction 0.15)
  (advice-add 'frame-set-background-mode :after (lambda (&rest args) (dimmer-process-all)))
  (defun sanityinc/display-non-graphic-p ()
    (not (display-graphic-p)))
  (add-to-list 'dimmer-exclusion-predicates 'sanityinc/display-non-graphic-p))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(defun sanityinc/maybe-suspend-frame ()
  (interactive)
  (if (display-graphic-p)
      (message "suspend-frame disabled for graphical displays.")
    (suspend-frame)))
(global-unset-key (kbd "C-z"))
(global-set-key (kbd "C-z M-z") 'sanityinc/maybe-suspend-frame)
(global-set-key (kbd "C-z") 'undo)

(setq use-file-dialog nil)
(setq use-dialog-box nil)
(setq inhibit-startup-screen t)
(set-fringe-mode '(nil . 0))

;;(set-face-background 'vertical-border  "#586e75")
;;(set-face-foreground 'vertical-border (face-background 'vertical-border))
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'set-scroll-bar-mode)
  (set-scroll-bar-mode nil))
(when (fboundp 'menu-bar-mode)
  (menu-bar-mode -1))

;; (let ((no-border '(internal-border-width . 0)))
;;   (add-to-list 'default-frame-alist no-border)
;;   (add-to-list 'initial-frame-alist no-border))

;; Non-zero values for `line-spacing' can mess up ansi-term and co,
;; so we zero it explicitly in those cases.
(add-hook 'term-mode-hook
          (lambda ()
            (setq line-spacing 0)))

;; Change global font size easily
(use-package default-text-scale)
(add-hook 'after-init-hook 'default-text-scale-mode)
(setq-default tab-width 4)

(defun sanityinc/adjust-opacity (frame incr)
  "Adjust the background opacity of FRAME by increment INCR."
  (unless (display-graphic-p frame)
    (Error "Cannot adjust opacity of this frame"))
  (let* ((oldalpha (or (frame-parameter frame 'alpha) 100))
         ;; The 'alpha frame param became a pair at some point in
         ;; emacs 24.x, e.g. (100 100)
         (oldalpha (if (listp oldalpha) (car oldalpha) oldalpha))
         (newalpha (+ incr oldalpha)))
    (when (and (<= frame-alpha-lower-limit newalpha) (>= 100 newalpha))
      (modify-frame-parameters frame (list (cons 'alpha newalpha))))))

;; TODO: use seethru package instead?
(global-set-key (kbd "M-C-9") (lambda () (interactive) (sanityinc/adjust-opacity nil -2)))
(global-set-key (kbd "M-C-7") (lambda () (interactive) (sanityinc/adjust-opacity nil 2)))
(global-set-key (kbd "M-C-8") (lambda () (interactive) (modify-frame-parameters nil `((alpha . 100)))))

(if (display-graphic-p)
    (sanityinc/adjust-opacity nil -2)
  (add-hook 'after-make-frame-functions
            (lambda (frame)
              (when (display-graphic-p frame)
                (with-selected-frame frame
                  (sanityinc/adjust-opacity nil -2))))))

(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))

(setq-default fringes-outside-margins t
                indicate-buffer-boundaries nil
                fringe-indicator-alist (delq (assq 'continuation fringe-indicator-alist)
                                             fringe-indicator-alist))



;;(setq left-margin-width 12)
;; (setq right-margin-width 12)
(setq internal-border 40)
(setq frame-internal-border-width 60)
(setq bottom-divider-width 20)
(set-window-buffer nil (current-buffer))

(use-package beacon
  :config
  (setq-default beacon-lighter "")
  (setq-default beacon-size 30)
  :init
  (beacon-mode 1))

;; Emoji: 😄, 🤦, 🏴󠁧󠁢󠁳󠁣󠁴󠁿
;; (set-fontset-font t 'symbol "Apple Color Emoji")
(set-fontset-font t 'symbol "Noto Color Emoji" nil 'append)
(set-fontset-font t 'symbol "Segoe UI Emoji" nil 'append)
(set-fontset-font t 'symbol "Symbola" nil 'append)

(use-package centaur-tabs
  :demand
  :config
 (setq centaur-tabs-style "slant"
     centaur-tabs-height 32
     centaur-tabs-set-icons t
     centaur-tabs-set-modified-marker t
     centaur-tabs-show-navigation-buttons t
     centaur-tabs-set-bar 'under
     uniquify-buffer-name-style 'forward
     x-underline-at-descent-line t)
  (centaur-tabs-headline-match)
  ;; (centaur-tabs-mode t)
  (setq uniquify-separator "/")
  (setq uniquify-buffer-name-style 'forward)
 (defun centaur-tabs-buffer-groups ()
    "`centaur-tabs-buffer-groups' control buffers' group rules.

Group centaur-tabs with mode if buffer is derived from `eshell-mode' `emacs-lisp-mode' `dired-mode' `org-mode' `magit-mode'.
All buffer name start with * will group to \"Emacs\".
Other buffer group by `centaur-tabs-get-group-name' with project name."
    (list
     (cond

   ((derived-mode-p 'prog-mode)
    "Editing")
   ((derived-mode-p 'vterm-mode)
    "Term")
   ((derived-mode-p 'dired-mode)
    "Dired")
   ((memq major-mode '(helpful-mode
               help-mode))
    "Help")
   ((or (string-equal "*" (substring (buffer-name) 0 1))
        (memq major-mode '(magit-process-mode
               magit-status-mode
               magit-diff-mode
               magit-log-mode
               magit-file-mode
               magit-blob-mode
               magit-blame-mode
               )))
    "Emacs")
   ((memq major-mode '(org-mode
               org-agenda-clockreport-mode
               org-src-mode
               org-agenda-mode
               org-beamer-mode
               org-indent-mode
               org-bullets-mode
               org-cdlatex-mode
               org-agenda-log-mode
               diary-mode))
    "OrgMode")
   (t
    (centaur-tabs-get-group-name (current-buffer))))))
(defun centaur-tabs-hide-tab (x)
 "Do no to show buffer X in tabs."
 (let ((name (format "%s" x)))
   (or
    ;; Current window is not dedicated window.
    (window-dedicated-p (selected-window))

    ;; Buffer name not match below blacklist.
    (string-prefix-p "*epc" name)
    (string-prefix-p "*helm" name)
    (string-prefix-p "*Helm" name)
    (string-prefix-p "*Compile-Log*" name)
    (string-prefix-p "*lsp" name)
    (string-prefix-p "*company" name)
    (string-prefix-p "*Flycheck" name)
    (string-prefix-p "*tramp" name)
    (string-prefix-p " *Mini" name)
    (string-prefix-p "*help" name)
    (string-prefix-p "*straight" name)
    (string-prefix-p " *temp" name)
    (string-prefix-p "*Help" name)
    (string-prefix-p "*mybuf" name)
    (string-prefix-p "*Messages" name)

    ;; Is not magit buffer.
    (and (string-prefix-p "magit" name)
     (not (file-name-extension name))))))
  :bind
  ("C-c x b" . centaur-tabs-backward)
  ("C-c x f" . centaur-tabs-forward)
  ("C-c x s" . centaur-tabs-counsel-switch-group))

(straight-use-package 'dirvish)
(use-package dired
  :straight (:type built-in)
  :defer 1
  :commands (dired dired-jump)
  :config

  (setq-default dired-dwim-target t)
  (use-package diredfl
    :config
    (require 'dired-x)
    :hook (dired-mode . diredfl-mode)
    )
  ;; Prefer g-prefixed coreutils version of standard utilities when available
  (let ((gls (executable-find "gls")))
    (when gls (setq insert-directory-program gls)))

  (setq dired-listing-switches "-agho --group-directories-first"
        dired-omit-verbose nil)
  (setq dired-recursive-deletes 'top)
  (autoload 'dired-omit-mode "dired-x")

  (use-package dired-single
    :commands (dired dired-jump))

  (add-hook 'dired-load-hook
            (lambda ()
              (interactive)
              (dired-collapse)))

  (add-hook 'dired-mode-hook
            (lambda ()
              (interactive)
              (dired-omit-mode 1)
              (setq mode-line-format nil)
              (hl-line-mode 1)))    

  (use-package dired-ranger
    :defer t
    :config
    (put 'dired-find-alternate-file 'disabled nil)   
    (define-key dired-mode-map "b" 'dired-single-up-directory)
    (define-key dired-mode-map "f" 'dired-find-alternate-file)
    (define-key dired-mode-map "l" 'dired-single-buffer)
    (define-key dired-mode-map "y" 'dired-ranger-copy)
    (define-key dired-mode-map "X" 'dired-ranger-move)
    (define-key dired-mode-map "H" 'dired-omit-mode)
    (define-key dired-mode-map "p" 'dired-ranger-paste))
  
  (use-package dired-collapse
    :defer t)
  
  (use-package all-the-icons-dired
    :defer t)
  (add-hook 'dired-mode-hook 'all-the-icons-dired-mode))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (define-key dired-mode-map "." #'dired-hide-dotfiles-mode)
  (setq dired-omit-files "^\\(?:\\..*\\|.*~\\)$"))

;; ;; Hook 
;; up dired-x global bindings without loading it up-front
(define-key ctl-x-map "\C-j" 'dired-jump)
(define-key ctl-x-map "\C-d" 'dired-jump-other-window)

(use-package diff-hl  ; mark git change
  :config
  (after-load 'dired
    (add-hook 'dired-mode-hook 'diff-hl-dired-mode)))

(use-package openwith
:ensure t
:config
(setq openwith-associations
      (cond
       ((string-equal system-type "darwin")
        '(("\\.\\(dmg\\|doc\\|docs\\|xls\\|xlsx\\)$"
           "open" (file))
          ("\\.\\(mp4\\|mp3\\|webm\\|avi\\|flv\\|mov\\)$"
           "open" ("-a" "VLC" file))))
       ((string-equal system-type "gnu/linux")
        '(("\\.\\(mp4\\|mp3\\|webm\\|avi\\|flv\\|mov\\)$"
           "xdg-open" (file))))))
(openwith-mode +1))

(use-package vertico
  :config
  (setq completion-styles '(substring orderless))
  :init (vertico-mode))

(use-package embark
  :after vertico
  :bind (("M-a" . embark-act) 
         :map vertico-map
             ("C-c C-o" . embark-export)
             ("C-c C-c" . embark-act)
             ("C-h B" . embark-bindings))
  :config
  (setq embark-action-indicator
      (lambda (map _target)
        (which-key--show-keymap "Embark" map nil nil 'no-paging)
        #'which-key--hide-popup-ignore-command)
      embark-become-indicator embark-action-indicator))

(use-package orderless
  :init
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion))))
  (defun sanityinc/use-orderless-in-minibuffer ()
    (setq-local completion-styles '(substring orderless)))
  (add-hook 'minibuffer-setup-hook 'sanityinc/use-orderless-in-minibuffer))

(use-package embark-consult
  :after (embark consult)
  :demand t
  :hook (embark-collect-mode . embark-consult-preview-minor-mode))
(use-package consult-flycheck)

(use-package affe
  :after (orderless consult)
  :config
  (setq affe-regexp-function #'orderless-pattern-compiler
        affe-highlight-function #'orderless--highlight)
  ;; Manual preview key for `affe-grep'
  (consult-customize affe-grep :preview-key (kbd "M-."))
      ;; (global-set-key (kbd "M-?") 'sanityinc/affe-grep-at-point)
      ;; (sanityinc/no-consult-preview sanityinc/affe-grep-at-point)
      ;;  (sanityinc/no-consult-preview affe-grep)
       )

(use-package savehist
  :init
  (savehist-mode))

(use-package marginalia
  :after vertico
  :ensure t
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))

(defmacro sanityinc/no-consult-preview (&rest cmds)
  `(with-eval-after-load 'consult
     (consult-customize ,@cmds :preview-key (kbd "M-P"))))
(sanityinc/no-consult-preview
 consult-ripgrep
 consult-git-grep consult-grep
 consult-bookmark consult-recent-file consult-xref
 consult--source-file consult--source-project-file consult--source-bookmark)
(setq-default consult-project-root-function 'projectile-project-root)
(defun sanityinc/affe-grep-at-point (&optional dir initial)
  (interactive (list prefix-arg (when-let ((s (symbol-at-point)))
                                    (symbol-name s))))
  (affe-grep dir initial))
(global-set-key (kbd "M-?") 'sanityinc/affe-grep-at-point)
(sanityinc/no-consult-preview sanityinc/affe-grep-at-point)
(with-eval-after-load 'affe (sanityinc/no-consult-preview affe-grep))

(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c h" . consult-history)
         ;;("C-c m" . consult-mode-command)
         ("C-c b" . consult-bookmark)
         ("C-c k" . consult-kmacro)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x M-b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ("<help> a" . consult-apropos)            ;; orig. apropos-command
         ;; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-project-imenu)
         ;; M-s bindings (search-map)
         ("M-s f" . consult-find)
         ("M-s L" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s m" . consult-multi-occur)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch)
         :map isearch-mode-map
         ("M-e" . consult-isearch)                 ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch)               ;; orig. isearch-edit-string
         ("M-s l" . consult-line))                 ;; needed by consult-line to detect isearch

  ;; Enable automatic preview at point in the *Completions* buffer.
  ;; This is relevant when you use the default completion UI,
  ;; and not necessary for Vertico, Selectrum, etc.
  ;;:hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Optionally replace `completing-read-multiple' with an enhanced version.
  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key (kbd "M-."))
  ;; (setq consult-preview-key (list (kbd "<S-down>") (kbd "<S-up>")))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme
   :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-file consult--source-project-file consult--source-bookmark
   sanityinc/affe-grep-at-point affe-grep
   :preview-key (kbd "M-."))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; (kbd "C-+")

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; Optionally configure a function which returns the project root directory.
  ;; There are multiple reasonable alternatives to chose from.
  ;;;; 1. project.el (project-roots)
  (setq consult-project-root-function
        (lambda ()
          (when-let (project (project-current))
            (car (project-roots project)))))
  ;;;; 2. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-root-function #'projectile-project-root)
  ;;;; 3. vc.el (vc-root-dir)
  ;; (setq consult-project-root-function #'vc-root-dir)
  ;;;; 4. locate-dominating-file
  ;; (setq consult-project-root-function (lambda () (locate-dominating-file "." ".git")))
)

(use-package multi-vterm
  :straight t
  :config
  (setq vterm-buffer-name-string "%s")
  :bind (
         ( "C-c t" . multi-vterm-dedicated-toggle)
         ( "C-c T" . multi-vterm)
         :map term-mode-map
         ("C-b" . term-send-left)
         ("C-f" . term-send-right)))
(add-hook 'vterm-mode-hook (lambda ()
                             (setq vterm-buffer-maximum-size 1000
                                   vterm-scroll-to-bottom-on-output t
                                   multi-vterm-scroll-show-maximum-output t
                                   multi-vterm-dedicated-select-after-open-p t
                                   mode-line-format nil)
                             (define-key vterm-mode-map (kbd "C-y") 'vterm-yank)))
(defun vterm-clear-buffer ()
  "Clear terminal"
  (interactive)
  (let ((inhibit-read-only t))
    (erase-buffer)
    (vterm-send-input)))

;; Show number of matches while searching
(use-package anzu
  :config
  (add-hook 'after-init-hook 'global-anzu-mode)
  (setq anzu-mode-lighter "")
  (global-set-key [remap query-replace-regexp] 'anzu-query-replace-regexp)
  (global-set-key [remap query-replace] 'anzu-query-replace))

;; Search back/forth for the symbol at point
;; See http://www.emacswiki.org/emacs/SearchAtPoint
(defun isearch-yank-symbol ()
  "*Put symbol at current point into search string."
  (interactive)
  (let ((sym (thing-at-point 'symbol)))
    (if sym
        (progn
          (setq isearch-regexp t
                isearch-string (concat "\\_<" (regexp-quote sym) "\\_>")
                isearch-message (mapconcat 'isearch-text-char-description isearch-string "")
                isearch-yank-flag t))
      (ding)))
  (isearch-search-and-update))

(define-key isearch-mode-map "\C-\M-w" 'isearch-yank-symbol)
(defun sanityinc/isearch-exit-other-end ()
  "Exit isearch, but at the other end of the search string.
This is useful when followed by an immediate kill."
  (interactive)
  (isearch-exit)
  (goto-char isearch-other-end))

(define-key isearch-mode-map [(control return)] 'sanityinc/isearch-exit-other-end)

(setq-default grep-highlight-matches t
              grep-scroll-output t)
(use-package wgrep
  :config
   (dolist (key (list (kbd "C-c C-q") (kbd "w")))
    (define-key grep-mode-map key 'wgrep-change-to-wgrep-mode)))
(when (and (executable-find "ag")
           (use-package ag))
  (use-package wgrep-ag
    :bind("M-?" . ag-project)
    :config
    (setq-default ag-highlight-search t)))
(when (and (executable-find "rg")
           (use-package rg))
  (global-set-key (kbd "M-?") 'rg-project))

(use-package fullframe)
(after-load 'ibuffer
  (fullframe ibuffer ibuffer-quit))
(use-package ibuffer-vc)

(defun ibuffer-set-up-preferred-filters ()
  (ibuffer-vc-set-filter-groups-by-vc-root)
  (unless (eq ibuffer-sorting-mode 'filename/process)
    (ibuffer-do-sort-by-filename/process)))

(add-hook 'ibuffer-hook 'ibuffer-set-up-preferred-filters)

(setq-default ibuffer-show-empty-filter-groups nil)

(require 'ibuf-ext)
(add-to-list 'ibuffer-never-show-predicates "^\\*")
(after-load 'ibuffer
  ;; Use human readable Size column instead of original one
  (define-ibuffer-column size-h
    (:name "Size" :inline t)
    (file-size-human-readable (buffer-size))))


;; Modify the default ibuffer-formats (toggle with `)
(setq ibuffer-formats
      '((mark modified read-only vc-status-mini " "
              (name 22 22 :left :elide)
              " "
              (size-h 9 -1 :right)
              " "
              (mode 12 12 :left :elide)
              " "
              vc-relative-file)
        (mark modified read-only vc-status-mini " "
              (name 22 22 :left :elide)
              " "
              (size-h 9 -1 :right)
              " "
              (mode 14 14 :left :elide)
              " "
              (vc-status 12 12 :left)
              " "
              vc-relative-file)))

(setq ibuffer-filter-group-name-face 'font-lock-doc-face)

(global-set-key (kbd "C-x C-b") 'ibuffer)

(use-package flycheck
  :defer t
  :config
    (setq flycheck-check-syntax-automatically '(mode-enabled save new-line)) ;to ignore idel flycheck
   (setq flycheck-display-errors-function #'flycheck-display-error-messages-unless-error-list)
    (global-flycheck-mode 1))

(add-hook 'emacs-startup-hook 'recentf-mode)
  (setq-default
   recentf-max-saved-items 1000
   recentf-exclude '("/tmp/" "/ssh:"))

(global-set-key (kbd "M-/") 'hippie-expand)
(setq hippie-expand-try-functions-list
      '(try-complete-file-name-partially
        try-complete-file-name
        try-expand-dabbrev
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill))

(setq tab-always-indent 'complete)
(add-to-list 'completion-styles 'initials t)
(use-package company
  :diminish company-mode
  :bind(("M-C-/" . company-complete)
        (:map company-mode-map 
              ( "M-/" . company-complete))    
         (:map company-active-map
               ( "M-/" . company-other-backend)  
               ( "C-n" . company-select-next)    
               ( "C-p" . company-select-previous)
               ("C-d" . company-show-doc-buffer)
               ("M-." . company-show-location)))
  :config 
  (dolist (backend '(company-eclim company-semantic))
      (delq backend company-backends))
  (setq-default company-dabbrev-other-buffers 'all
                company-tooltip-align-annotations t)
  (global-company-mode))

(use-package company-quickhelp
    :init (company-quickhelp-mode 1))

(use-package mmm-mode)
(require 'mmm-auto)
(setq mmm-global-mode 'buffers-with-submode-classes)
(setq mmm-submode-decoration-level 2)

(use-package unfill)
(when (fboundp 'electric-pair-mode)
  (add-hook 'after-init-hook 'electric-pair-mode))
(when (eval-when-compile (version< "24.4" emacs-version))
  (add-hook 'after-init-hook 'electric-indent-mode))
(use-package list-unicode-display)

(setq-default
 blink-cursor-interval 0.4
 bookmark-default-file (expand-file-name ".bookmarks.el" user-emacs-directory)
 buffers-menu-max-size 30
 case-fold-search t
 column-number-mode t
 delete-selection-mode t
 ediff-split-window-function 'split-window-horizontally
 ediff-window-setup-function 'ediff-setup-windows-plain
 indent-tabs-mode nil
 make-backup-files nil
 mouse-yank-at-point t
 save-interprogram-paste-before-kill t
 scroll-preserve-screen-position 'always
 set-mark-command-repeat-pop t
 tooltip-delay 1.5
 truncate-lines nil
 truncate-partial-width-windows nil)

;;(add-hook 'after-init-hook 'global-auto-revert-mode)
(use-package autorevert
  :defer t
  :diminish 'auto-revert-mode
  :config
  (setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)
  )

(add-hook 'after-init-hook 'transient-mark-mode)

(use-package vlf)
(defun ffap-vlf ()
  "Find file at point with VLF."
  (interactive)
  (let ((file (ffap-file-at-point)))
    (unless (file-exists-p file)
      (error "File does not exist: %s" file))
    (vlf file)))

(set 'ad-redefinition-action 'accept)
(global-set-key (kbd "RET") 'newline-and-indent)
(defun sanityinc/newline-at-end-of-line ()
  "Move to end of line, enter a newline, and reindent."
  (interactive)
  (move-end-of-line 1)
  (newline-and-indent))

(global-set-key (kbd "C-<return>") 'sanityinc/newline-at-end-of-line)

(after-load 'subword
  (diminish 'subword-mode))

;;; uncomment if you wnat line numbers do not use linum-mode because it is not optimized
(when (fboundp 'display-line-numbers-mode)
  (setq-default display-line-numbers-width 3)
  (add-hook 'prog-mode-hook 'display-line-numbers-mode))

(use-package goto-line-preview
  :config
  (global-set-key [remap goto-line] 'goto-line-preview)

  (when (fboundp 'display-line-numbers-mode)
    (defun sanityinc/with-display-line-numbers (f &rest args)
      (let ((display-line-numbers t))
        (apply f args)))
    (advice-add 'goto-line-preview :around #'sanityinc/with-display-line-numbers)))

(use-package rainbow-delimiters
  :config
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(when (fboundp 'global-prettify-symbols-mode)
  (add-hook 'after-init-hook 'global-prettify-symbols-mode))


;;----------------------------------------------------------------------------
;; Zap *up* to char is a handy pair for zap-to-char
;;----------------------------------------------------------------------------
(autoload 'zap-up-to-char "misc" "Kill up to, but not including ARGth occurrence of CHAR.")
(global-set-key (kbd "M-Z") 'zap-up-to-char)

;;----------------------------------------------------------------------------
;; Show matching parens
;;----------------------------------------------------------------------------
(add-hook 'after-init-hook 'show-paren-mode)

;;----------------------------------------------------------------------------
;; Expand region
;;----------------------------------------------------------------------------
(use-package expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

;;----------------------------------------------------------------------------
;; Don't disable case-change functions
;;----------------------------------------------------------------------------
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

;;----------------------------------------------------------------------------
;; Rectangle selections, and overwrite text when the selection is active
;;----------------------------------------------------------------------------
(cua-selection-mode t)                  ; for rectangles, CUA is nice

;;----------------------------------------------------------------------------
;; Handy key bindings
;;----------------------------------------------------------------------------
(global-set-key (kbd "C-.") 'set-mark-command)
(global-set-key (kbd "C-x C-.") 'pop-global-mark)

(use-package avy
  :config
  (global-set-key (kbd "C-o") 'avy-goto-char-timer))

(use-package multiple-cursors)
;; multiple-cursors
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-+") 'mc/mark-next-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
;; From active region to multiple cursors:
(global-set-key (kbd "C-c m r") 'set-rectangular-region-anchor)
(global-set-key (kbd "C-c m c") 'mc/edit-lines)
(global-set-key (kbd "C-c m e") 'mc/edit-ends-of-lines)
(global-set-key (kbd "C-c m a") 'mc/edit-beginnings-of-lines)

(defun kill-back-to-indentation ()
  "Kill from point back to the first non-whitespace character on the line."
  (interactive)
  (let ((prev-pos (point)))
    (back-to-indentation)
    (kill-region (point) prev-pos)))

(global-set-key (kbd "C-M-<backspace>") 'kill-back-to-indentation)

(defun sanityinc/backward-up-sexp (arg)
  "Jump up to the start of the ARG'th enclosing sexp."
  (interactive "p")
  (let ((ppss (syntax-ppss)))
    (cond ((elt ppss 3)
           (goto-char (elt ppss 8))
           (sanityinc/backward-up-sexp (1- arg)))
          ((backward-up-list arg)))))
(global-set-key [remap backward-up-list] 'sanityinc/backward-up-sexp) ; C-M-u, C-M-up

;; Some local minor modes clash with CUA rectangle selection

(defvar-local sanityinc/suspended-modes-during-cua-rect nil
  "Modes that should be re-activated when cua-rect selection is done.")

(eval-after-load 'cua-rect
  (advice-add 'cua--deactivate-rectangle :after
              (lambda (&rest _)
                (dolist (m sanityinc/suspended-modes-during-cua-rect)
                  (funcall m 1)
                  (setq sanityinc/suspended-modes-during-cua-rect nil)))))

(defun sanityinc/suspend-mode-during-cua-rect-selection (mode-name)
  "Add an advice to suspend `MODE-NAME' while selecting a CUA rectangle."
  (eval-after-load 'cua-rect
    (advice-add 'cua--activate-rectangle :after
                (lambda (&rest _)
                  (when (bound-and-true-p mode-name)
                    (push mode-name sanityinc/suspended-modes-during-cua-rect)
                    (funcall mode-name 0))))))

(sanityinc/suspend-mode-during-cua-rect-selection 'whole-line-or-region-local-mode)


;;----------------------------------------------------------------------------
;; Random line sorting
;;----------------------------------------------------------------------------
(defun sanityinc/sort-lines-random (beg end)
  "Sort lines in region from BEG to END randomly."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (goto-char (point-min))
      (let ;; To make `end-of-line' and etc. to ignore fields.
          ((inhibit-field-text-motion t))
        (sort-subr nil 'forward-line 'end-of-line nil nil
                   (lambda (s1 s2) (eq (random 2) 0)))))))

(use-package highlight-escape-sequences)
(add-hook 'after-init-hook 'hes-mode)

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

(defun sanityinc/disable-features-during-macro-call (orig &rest args)
  "When running a macro, disable features that might be expensive.
ORIG is the advised function, which is called with its ARGS."
  (let (post-command-hook
        font-lock-mode
        (tab-always-indent (or (eq 'complete tab-always-indent) tab-always-indent)))
    (apply orig args)))

(advice-add 'kmacro-call-macro :around 'sanityinc/disable-features-during-macro-call)

(use-package symbol-overlay
  :diminish symbol-overlay-mode
  :bind (:map symbol-overlay-mode-map
              ("M-i" . symbol-overlay-put)       
              ("M-I" . symbol-overlay-remove-all)
              ("M-n" . symbol-overlay-jump-next) 
              ("M-p" . symbol-overlay-jump-prev)))
  (dolist (hook '(org-mode hook prog-mode-hook html-mode-hook yaml-mode-hook conf-mode-hook))
    (add-hook hook 'symbol-overlay-mode))

(setq-default show-trailing-whitespace nil)
;;; Whitespace
(defun sanityinc/show-trailing-whitespace ()
  "Enable display of trailing whitespace in this buffer."
  (setq-local show-trailing-whitespace t))

(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook 'sanityinc/show-trailing-whitespace))

(use-package whitespace-cleanup-mode
  :diminish whitespace-cleanup-mode)
(add-hook 'after-init-hook 'global-whitespace-cleanup-mode)
(global-set-key [remap just-one-space] 'cycle-spacing)

(use-package diff-hl
  :defer t
  :config
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  (add-hook 'after-init-hook 'global-diff-hl-mode)
  (after-load 'diff-hl
    (define-key diff-hl-mode-map
      (kbd "<left-fringe> <mouse-1>")
      'diff-hl-diff-goto-hunk)))
(use-package browse-at-remote)

(use-package git-blamed)
;;  (use-package gitignore-mode)
;;  (use-package gitconfig-mode)
  (use-package git-timemachine
    :config
    (global-set-key (kbd "C-x v t") 'git-timemachine-toggle))

  (use-package magit
    :defer t
    :config
    (setq-default magit-diff-refine-hunk t)

    ;; Hint: customize `magit-repository-directories' so that you can use C-u M-F12 to
    ;; quickly open magit on any one of your projects.
    (global-set-key [(meta f12)] 'magit-status)
    (global-set-key (kbd "C-x g") 'magit-status)
    (global-set-key (kbd "C-x M-g") 'magit-dispatch)

    (defun sanityinc/magit-or-vc-log-file (&optional prompt)
      (interactive "P")
      (if (and (buffer-file-name)
               (eq 'Git (vc-backend (buffer-file-name))))
          (if prompt
              (magit-log-buffer-file-popup)
            (magit-log-buffer-file t))
        (vc-print-log)))

    (after-load 'vc
      (define-key vc-prefix-map (kbd "l") 'sanityinc/magit-or-vc-log-file)))

  (after-load 'magit
    (define-key magit-status-mode-map (kbd "C-M-<up>") 'magit-section-up))

  (use-package magit-todos)

  (use-package fullframe)
  (after-load 'magit
    (fullframe magit-status magit-mode-quit-window))

  (use-package git-commit
    :config
    (add-hook 'git-commit-mode-hook 'goto-address-mode))

  ;; Convenient binding for vc-git-grep
  (after-load 'vc
    (define-key vc-prefix-map (kbd "f") 'vc-git-grep))

(setq-default compilation-scroll-output t)
(use-package alert)

;; Customize `alert-default-style' to get messages after compilation

(defun sanityinc/alert-after-compilation-finish (buf result)
  "Use `alert' to report compilation RESULT if BUF is hidden."
  (when (buffer-live-p buf)
    (unless (catch 'is-visible
              (walk-windows (lambda (w)
                              (when (eq (window-buffer w) buf)
                                (throw 'is-visible t))))
              nil)
      (alert (concat "Compilation " result)
             :buffer buf
             :category 'compilation))))

(after-load 'compile
  (add-hook 'compilation-finish-functions
            'sanityinc/alert-after-compilation-finish))

(defvar sanityinc/last-compilation-buffer nil
  "The last buffer in which compilation took place.")

(after-load 'compile
  (defun sanityinc/save-compilation-buffer (&rest _)
    "Save the compilation buffer to find it later."
    (setq sanityinc/last-compilation-buffer next-error-last-buffer))
  (advice-add 'compilation-start :after 'sanityinc/save-compilation-buffer)

  (defun sanityinc/find-prev-compilation (orig &optional edit-command)
    "Find the previous compilation buffer, if present, and recompile there."
    (if (and (null edit-command)
             (not (derived-mode-p 'compilation-mode))
             sanityinc/last-compilation-buffer
             (buffer-live-p (get-buffer sanityinc/last-compilation-buffer)))
        (with-current-buffer sanityinc/last-compilation-buffer
          (funcall orig edit-command))
      (funcall orig edit-command)))
  (advice-add 'recompile :around 'sanityinc/find-prev-compilation))

(global-set-key [f6] 'recompile)

(defun sanityinc/shell-command-in-view-mode (start end command &optional output-buffer replace &rest other-args)
  "Put \"*Shell Command Output*\" buffers into view-mode."
  (unless (or output-buffer replace)
    (with-current-buffer "*Shell Command Output*"
      (view-mode 1))))
(advice-add 'shell-command-on-region :after 'sanityinc/shell-command-in-view-mode)

(after-load 'compile
  (require 'ansi-color)
  (defun sanityinc/colourise-compilation-buffer ()
    (when (eq major-mode 'compilation-mode)
      (ansi-color-apply-on-region compilation-filter-start (point-max))))
  (add-hook 'compilation-filter-hook 'sanityinc/colourise-compilation-buffer))

(use-package yasnippet                
  :straight t
  :config
  (setq yas-verbosity 1)                      ; No need to be so verbose
  (setq yas-wrap-around-region t)
  (use-package yasnippet-snippets
    :straight t)
  (with-eval-after-load 'yasnippet
    (setq yas-snippet-dirs '(yasnippet-snippets-dir)))

  (yas-reload-all)
  (yas-global-mode t)
  (define-key yas-minor-mode-map (kbd "C-c s") #'yas-insert-snippet)

  (defun company-yasnippet-or-completion ()
    "Solve company yasnippet conflicts."
    (interactive)
    (let ((yas-fallback-behavior
           (apply 'company-complete-common nil)))
      (yas-expand)))

  (add-hook 'company-mode-hook
            (lambda ()
              (substitute-key-definition
               'company-complete-common
               'company-yasnippet-or-completion
               company-active-map))))

(use-package paredit
  :diminish paredit-mode " Par"
  :hook (paredit-mode-hook . maybe-map-paredit-newline)
  :init
  (defun maybe-map-paredit-newline ()
    (unless (or (memq major-mode '(inferior-emacs-lisp-mode cider-repl-mode))
                (minibufferp))
      (local-set-key (kbd "RET") 'paredit-newline)))
  :config
;; Suppress certain paredit keybindings to avoid clashes, including
;; my global binding of M-?
(define-key paredit-mode-map (kbd "DEL") 'delete-backward-char)
(dolist (binding '("C-<left>" "C-<right>" "C-M-<left>" "C-M-<right>" "M-s" "M-?"))
  (define-key paredit-mode-map (read-kbd-macro binding) nil)))

(use-package ispell
  :defer t
  :config
  (when (executable-find ispell-program-name)
  ;; Add spell-checking in comments for all programming language modes
  (add-hook 'prog-mode-hook 'flyspell-prog-mode)
  (after-load 'flyspell
    (define-key flyspell-mode-map (kbd "C-;") nil)
    (add-to-list 'flyspell-prog-text-faces 'nxml-text-face)))
  )

(use-package projectile
  :bind(:map projectile-mode-map ("C-c p" . projectile-command-map))
  :config
  (when (executable-find "rg")
    (setq-default projectile-generic-command "rg --files --hidden"))
  (setq-default projectile-mode-line-prefix " Proj")   ;; Shorter modeline
  (projectile-mode))
  (use-package ibuffer-projectile)

(add-auto-mode 'tcl-mode "^Portfile\\'")
(fset 'yes-or-no-p 'y-or-n-p)

(add-hook 'prog-mode-hook 'goto-address-prog-mode)
(setq goto-address-mail-face 'link)

(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)
(add-hook 'after-save-hook 'sanityinc/set-mode-for-new-scripts)

(defun sanityinc/set-mode-for-new-scripts ()
  "Invoke `normal-mode' if this file is a script and in `fundamental-mode'."
  (and
   (eq major-mode 'fundamental-mode)
   (>= (buffer-size) 2)
   (save-restriction
     (widen)
     (string= "#!" (buffer-substring (point-min) (+ 2 (point-min)))))
   (normal-mode)))

(straight-use-package 'info-colors)
(add-hook 'Info-selection-hook 'info-colors-fontify-node)

;; Handle the prompt pattern for the 1password command-line interface
(after-load 'comint
  (setq comint-password-prompt-regexp
        (concat
         comint-password-prompt-regexp
         "\\|^Please enter your password for user .*?:\\s *\\'")))

(use-package regex-tool
  :config
  (setq-default regex-tool-backend 'perl))

(after-load 're-builder
  ;; Support a slightly more idiomatic quit binding in re-builder
  (define-key reb-mode-map (kbd "C-c C-k") 'reb-quit))

(add-auto-mode 'conf-mode "^Procfile\\'")

(require 'init-windows)

(use-package counsel)
(setq counsel-linux-app-format-function 'counsel-linux-app-format-function-name-pretty)

 (defun emacs-run-launcher ()
   "Create and select a frame called emacs-run-launcher which consists only of a minibuffer and has specific dimensions. Run counsel-linux-app on that frame, which is an emacs command that prompts you to select an app and open it in a dmenu like behaviour. Delete the frame after that command has exited"
   (interactive)
   (with-selected-frame (make-frame '((name . "emacs-run-launcher")
				       (minibuffer . only)
				       (width . 120)
				       (height . 11)))
     (unwind-protect
	  (counsel-linux-app)
	(delete-frame))))

(provide 'org-version)
  (use-package org
    :straight org-contrib
    :bind (
           (:map org-mode-map
                 ( "C-M-<up>" . org-up-element)))
    :config
    (setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))
    (require 'ox-extra)
    ;; (ox-extras-activate '(latex-header-blocks ignore-headlines))

    (setq org-src-tab-acts-natively t)
    (setq org-latex-pdf-process (list "latexmk -pdflatex='lualatex -shell-escape -interaction nonstopmode' -pdf -output-directory=%o -f %f"))
  
    )
  (setq org-log-done t
        org-edit-timestamp-down-means-later t
        org-hide-emphasis-markers t
        org-catch-invisible-edits 'show
        org-export-coding-system 'utf-8
        org-fast-tag-selection-single-key 'expert
        org-html-validation-link nil
        org-image-actual-width nil
        ;;org-adapt-indentation nil
        org-edit-src-content-indentation 0
        org-export-kill-product-buffer-when-displayed t
        org-tags-column 80
        org-startup-folded t
        org-startup-with-inline-images t
        org-archive-mark-done nil
        org-archive-location "%s_archive::* Archive")
(defun gtd () (interactive) (org-agenda 'nil "g"))
  (use-package org-cliplink
    :bind (
           ("C-c l" . org-store-link)
           ("C-c a" .  gtd)))

(straight-use-package '(org-appear :type git :host github :repo "awth13/org-appear"))
(add-hook 'org-mode-hook 'org-appear-mode)

(setq header-line-format " ")
(custom-set-faces
   '(org-document-title ((t (:height 3.2))))
   '(header-line ((t (:height 3 :weight bold))))
   '(org-level-1 ((t (:foreground "#98be65" :height 1.6))))
  '(org-level-2 ((t (:foreground "#da8548" :height 1.2))))
  '(org-level-3 ((t (:foreground "#a9a1e1" :height 1.1))))
  '(header-line ((t (:height 2))))
;;  `(pdf-view-midnight-colors '("#ffffff" . "#fbf8ef"))
  )
;;(lamb;; da () (progn
;;              (setq left-margin-width 2)
;;              (setq right-margin-width 2)
;;              (set-window-buffer nil (current-buffer))))


;; ;;(
;;(setq header-line-format " ")

(setq org-directory "/home/snehrbass/doc")
(setq org-default-notes-file (concat org-directory "/inbox.org"))
(setq org-agenda-files (list "/home/snehrbass/doc/inbox.org"
                          "/home/snehrbass/doc/projects.org" ))

(global-set-key (kbd "C-c c") 'org-capture)
;; (setq org-capture-templates
;;       '(("t" "Todo" entry (file+headline "" "Inbox") ;"" => `org-default-notes-file'
;;          "** TODO %?\n  %i\n  %a":clock-resume t)
;;         ("c" "CURRENT" entry (clock) 
;;          "%U\n" :clock-resume t)
;;         ("j" "Journal" entry (file+olp+datetree "~/doc/status/journal.org")
;;          "* %?\nEntered on %U\n  %i\n  %a":clock-resume t)
;;         ))
(setq org-capture-templates
      `(("e" "Next" entry (file "")  ; "" => `org-default-notes-file'
         "* NEXT %?\n%U\n" :clock-resume t)
        ("t" "todo" entry (file "")
	     "* TODO %?\n%u\n%a\n" :clock-in t :clock-resume t)
        ("n" "note" entry (file "")
         "* %? :NOTE:\n%U\n%a\n" :clock-resume t)
        ))

(with-eval-after-load 'org-agenda
  (add-hook 'org-agenda-mode-hook
            (lambda () (add-hook 'window-configuration-change-hook 'org-agenda-align-tags nil t))))

(use-package org-bullets
  :straight t
  :defer t
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")) 
  :init
  (setq org-ellipsis " "))

(add-hook 'org-mode-hook
          (lambda ()
            ;;(push '("[ ]" .  "🞎") prettify-symbols-alist)
            (push '("[X]" . "✓" ) prettify-symbols-alist)
            (push '("#+TITLE:" . "") prettify-symbols-alist)
            (push '("#+title: " . "") prettify-symbols-alist)
            ;;(push '("[-]" . "◫" ) prettify-symbols-alist)
            (prettify-symbols-mode)
            ))

(with-eval-after-load 'org
  ;; This is needed as of Org 9.2
  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python")))
(after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   `((dot . t)
     (emacs-lisp . t)
     (gnuplot . t)
     (latex . t)
     (octave . t)
     (python . t)
     (,(if (locate-library "ob-sh") 'sh 'shell) . t)
     (sql . t)
     (sqlite . t))))

(use-package org-pomodoro
  :commands (org-pomodoro)
  :bind ((:map org-agenda-mode-map
              ("P" . org-pomodoro)))
  :config
  (setq org-pomodoro-keep-killed-pomodoro-time t)
  (setq
   alert-user-configuration (quote ((((:category . "org-pomodoro")) libnotify nil))))
  (setq org-pomodoro-finished-sound "/home/snehrbass/Music/bell.wav"
        org-pomodoro-long-break-sound "/home/snehrbass/Music/bell.wav"
        org-pomodoro-short-break-sound "/home/snehrbass/Music/bell.wav"
        org-pomodoro-start-sound "/home/snehrbass/Music/bell.wav"
        org-pomodoro-killed-sound "/home/snehrbass/Music/bell.wav")
  )

(defun ruborcalor/org-pomodoro-time ()
  "Return the remaining pomodoro time"
  (if (org-pomodoro-active-p)
      (cl-case org-pomodoro-state
        (:pomodoro
           (format "%d min - %s" (/ (org-pomodoro-remaining-seconds) 60) org-clock-heading))
        (:short-break
         (format "Short Break: %d min" (/ (org-pomodoro-remaining-seconds) 60)))
        (:long-break
         (format "Long Break: %d min" (/ (org-pomodoro-remaining-seconds) 60)))
        (:overtime
         (format "Overtime! %d min" (/ (org-pomodoro-remaining-seconds) 60))))
    "No Active Pomodoro"))

(defvar sanityinc/org-global-prefix-map (make-sparse-keymap) 
  "A keymap for handy global access to org helpers, particularly clocking.")
(define-key sanityinc/org-global-prefix-map (kbd "j") 'org-clock-goto)
(define-key sanityinc/org-global-prefix-map (kbd "l") 'org-clock-in-last)
(define-key sanityinc/org-global-prefix-map (kbd "i") 'org-clock-in)
(define-key sanityinc/org-global-prefix-map (kbd "o") 'org-clock-out)
(define-key global-map (kbd "C-c o") sanityinc/org-global-prefix-map)

;; Save the running clock and all clock history when exiting Emacs, load it on startup
(org-clock-persistence-insinuate)
(setq org-clock-persist t)
(setq org-clock-in-resume t)

;; Save clock data and notes in the LOGBOOK drawer
(setq org-clock-into-drawer t)
;; Save state changes in the LOGBOOK drawer
(setq org-log-into-drawer t)
;; Removes clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)

;; Show clock sums as hours and minutes, not "n days" etc.
(setq org-time-clocksum-format
      '(:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t))

               ;;; Show the clocked-in task - if any - in the header line
(defun sanityinc/show-org-clock-in-header-line ()
  (setq-default header-line-format '((" " org-mode-line-string " "))))

(defun sanityinc/hide-org-clock-from-header-line ()
  (setq-default header-line-format nil))

(add-hook 'org-clock-in-hook 'sanityinc/show-org-clock-in-header-line)
(add-hook 'org-clock-out-hook 'sanityinc/hide-org-clock-from-header-line)
(add-hook 'org-clock-cancel-hook 'sanityinc/hide-org-clock-from-header-line)

(after-load 'org-clock
  (define-key org-clock-mode-line-map [header-line mouse-2] 'org-clock-goto)
  (define-key org-clock-mode-line-map [header-line mouse-1] 'org-clock-menu))

(use-package org-fragtog
  :hook (org-mode . org-fragtog-mode)
  :config
    (setq org-support-shift-select t))

(defun toggle-org-pdf-export-on-save ()
  (interactive)
  (if (memq 'org-latex-export-to-pdf after-save-hook)
      (progn
        (remove-hook 'after-save-hook 'org-latex-export-to-pdf t)
        (message "Disabled org pdf export on save for current buffer..."))
    (add-hook 'after-save-hook 'org-latex-export-to-pdf nil t)
    (message "Enabled org export on save for current buffer...")))

(defun toggle-org-html-export-on-save ()
  (interactive)r
  (if (memq 'org-html-export-to-html after-save-hook)
      (progn
        (remove-hook 'after-save-hook 'org-html-export-to-html t)
        (message "Disabled org html export on save for current buffer..."))
    (add-hook 'after-save-hook 'org-html-export-to-html nil t)
    (message "Enabled org html export on save for current buffer...")))

(use-package org-pretty-table
  :straight (:host github :repo "Fuco1/org-pretty-table"
                   :branch "master")
  :demand t
  :hook (org-mode . org-pretty-table-mode))
(use-package pretty-mode
  :config
  (global-pretty-mode t)
  (global-prettify-symbols-mode 1)
  (pretty-deactivate-groups
   '(:equality
     :ordering
     :ordering-double
     :ordering-triple
     :arrows
     :arrows-twoheaded
     :punctuation
     :logic
     :sets
     :sub-and-superscripts
     :subscripts
     :arithmetic-double
     :arithmetic-triple))

  (pretty-activate-groups
   '(:greek :arithmetic-nary)))
(use-package writeroom-mode
  :bind ((:map writeroom-mode-map
               ("C-M-<" . writeroom-decrease-width)
               ("C-M->" . writeroom-increase-width))
         (:map org-mode-map
               ("C-c v" . prose-mode)))
  :hook (org-mode . prose-mode)
  :config
  (setq writeroom-width 140
        writeroom-mode-line nil
        writeroom-global-effects '(writeroom-set-alpha
                                   writeroom-set-menu-bar-lines
                                   writeroom-set-tool-bar-lines
                                   writeroom-set-vertical-scroll-bars
                                   writeroom-set-bottom-divider-width))
  :init
  (defun toggle-mode-line () "toggles the modeline on and off"
         (interactive)
         (setq mode-line-format
               (if (equal mode-line-format nil)
                   (default-value 'mode-line-format)) )
         (redraw-display))

  (define-minor-mode prose-mode
    "Set up a buffer for prose editing.
 This enables or modifies a number of settings so that the
 experience of editing prose is a little more like that of a
 typical word processor."
    nil " Prose" nil
    (if prose-mode
        (progn
          (when (fboundp 'writeroom-mode)
            (writeroom-mode 1))
          (setq truncate-lines nil
                word-wrap t
                cursor-type 'bar)
          (when (eq major-mode 'org)
            (kill-local-variable 'buffer-face-mode-face))
          (buffer-face-mode 1)
          (setq-local blink-cursor-interval 0.6)
          (setq-local show-trailing-whitespace nil)
          (setq-local line-spacing 0.2)
          (setq-local electric-pair-mode nil)
          (ignore-errors (flyspell-mode 1))
          (visual-line-mode 1))
      (kill-local-variable 'truncate-lines)
      (kill-local-variable 'word-wrap)
      (kill-local-variable 'cursor-type)
      (kill-local-variable 'blink-cursor-interval)
      (kill-local-variable 'show-trailing-whitespace)
      (kill-local-variable 'line-spacing)
      (kill-local-variable 'electric-pair-mode)
      (buffer-face-mode -1)
      (flyspell-mode -1)
      (visual-line-mode -1)
      (when (fboundp 'writeroom-mode)
        (writeroom-mode 0)))))

(use-package calfw
  ;; :straight (calfw-cal calfw-org calfw-ical)
  :init
  (use-package calfw-cal)
  (use-package calfw-org)
  (use-package calfw-ical)
  (setq cfw:fchar-junction ?╋
		cfw:fchar-vertical-line ?┃
		cfw:fchar-horizontal-line ?━
		cfw:fchar-left-junction ?┣
		cfw:fchar-right-junction ?┫
		cfw:fchar-top-junction ?┳
		cfw:fchar-top-left-corner ?┏
		cfw:fchar-top-right-corner ?┓)
  (setq frame-inhibit-implied-resize t)) ;; to prevent resizing

(defun open-calendar ()
  "CFW config calendars."
  (interactive)
  (if (string= (frame-parameter (selected-frame) 'name) "cfw:Calendar")
      (progn
        (set-face-attribute 'default (selected-frame) :font "Source Code Pro Bold 11")
        (cfw:open-calendar-buffer
         :contents-sources
         (list
          (cfw:org-create-source "#7f9f7f")
          (cfw:ical-create-source "Personal" "~/doc/Personal.ics" "#707D86")
                                        ; (cfw:ical-create-source "Work" "~/Documents/Work.ics" "Orange")
          ))
        )
    (progn
      (cfw:open-calendar-buffer
       :contents-sources
       (list
        (cfw:org-create-source "#7f9f7f")
        (cfw:ical-create-source "Personal" "~/doc/Personal.ics" "#707D86")
                                        ; (cfw:ical-create-source "Work" "~/Documents/Work.ics" "Orange")
        )))
    ))
(add-hook 'cfw:calendar-mode-hook
          (lambda ()
            (interactive)
            (setq mode-line-format nil)
            (set-fringe-mode '(1 . 1)) 
            ;; (cfw:refresh-calendar-buffer nil)
            ))
(add-hook 'server-after-make-frame-hook
          (lambda ()
            (setq inhibit-message t)
            (run-with-idle-timer 0 nil (lambda () (setq inhibit-message nil)))))

(setq org-refile-use-cache nil)

;; Targets include this file and any file contributing to the agenda - up to 5 levels deep
(setq org-refile-targets '((nil :maxlevel . 5) (org-agenda-files :maxlevel . 5)))

(with-eval-after-load 'org-agenda
  (add-to-list 'org-agenda-after-show-hook 'org-show-entry))

(advice-add 'org-refile :after (lambda (&rest _) (org-save-all-org-buffers)))

;; Exclude DONE state tasks from refile targets
(defun sanityinc/verify-refile-target ()
  "Exclude todo keywords with a done state from refile targets."
  (not (member (nth 2 (org-heading-components)) org-done-keywords)))
(setq org-refile-target-verify-function 'sanityinc/verify-refile-target)

(defun sanityinc/org-refile-anywhere (&optional goto default-buffer rfloc msg)
  "A version of `org-refile' which allows refiling to any subtree."
  (interactive "P")
  (let ((org-refile-target-verify-function))
    (org-refile goto default-buffer rfloc msg)))

(defun sanityinc/org-agenda-refile-anywhere (&optional goto rfloc no-update)
  "A version of `org-agenda-refile' which allows refiling to any subtree."
  (interactive "P")
  (let ((org-refile-target-verify-function))
    (org-agenda-refile goto rfloc no-update)))

;; Targets start with the file name - allows creating level 1 tasks
;;(setq org-refile-use-outline-path (quote file))
(setq org-refile-use-outline-path t)
(setq org-outline-path-complete-in-steps nil)

;; Allow refile to create parent tasks with confirmation
(setq org-refile-allow-creating-parent-nodes 'confirm)

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n/!)" "INPROGRESS(i/!)" "|" "DONE(d!/!)")
              (sequence "PROJECT(p)" "|" "DONE(d!/!)" "CANCELLED(c@/!)")
              (sequence "WAITING(w@/!)" "DELEGATED(e!)" "HOLD(h)" "|" "CANCELLED(c@/!)")))
      org-todo-repeat-to-state "NEXT")
(setq org-todo-keyword-faces
      (quote (("NEXT" :inherit warning)
              ("PROJECT" :inherit font-lock-string-face))))

(setq-default org-agenda-clockreport-parameter-plist '(:link t :maxlevel 3))
(let ((active-project-match "-INBOX/PROJECT"))
  (setq org-stuck-projects
        `(,active-project-match ("NEXT")))
  (setq org-agenda-compact-blocks t
        org-agenda-sticky t
        org-agenda-start-on-weekday nil
        org-agenda-span 'day
        org-agenda-include-diary nil
        org-agenda-sorting-strategy
        '((agenda habit-down time-up user-defined-up effort-up category-keep)
          (todo category-up effort-up)
          (tags category-up effort-up)
          (search category-up))
        org-agenda-window-setup 'current-window
        org-agenda-custom-commands
        `(("N" "Notes" tags "NOTE"
           ((org-agenda-overriding-header "Notes")
            (org-tags-match-list-sublevels t)))
          ("g" "GTD"
           ((agenda "" nil)
            (tags "INBOX"
                  ((org-agenda-overriding-header "Inbox")
                   (org-tags-match-list-sublevels nil)))
            (stuck ""
                   ((org-agenda-overriding-header "Stuck Projects")
                    (org-agenda-tags-todo-honor-ignore-options t)
                    (org-tags-match-list-sublevels t)
                    (org-agenda-todo-ignore-scheduled 'future)))
            (tags-todo "-INBOX"
                       ((org-agenda-overriding-header "Next Actions")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        (org-agenda-skip-function
                         '(lambda ()
                            (or (org-agenda-skip-subtree-if 'todo '("HOLD" "WAITING"))
                                (org-agenda-skip-entry-if 'nottodo '("NEXT")))))
                        (org-tags-match-list-sublevels t)
                        (org-agenda-sorting-strategy
                         '(todo-state-down effort-up category-keep))))
            (tags-todo ,active-project-match
                       ((org-agenda-overriding-header "Projects")
                        (org-tags-match-list-sublevels t)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "-INBOX/-NEXT"
                       ((org-agenda-overriding-header "Orphaned Tasks")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        (org-agenda-skip-function
                         '(lambda ()
                            (or (org-agenda-skip-subtree-if 'todo '("PROJECT" "HOLD" "WAITING" "DELEGATED"))
                                (org-agenda-skip-subtree-if 'nottododo '("TODO")))))
                        (org-tags-match-list-sublevels t)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "/WAITING"
                       ((org-agenda-overriding-header "Waiting")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "/DELEGATED"
                       ((org-agenda-overriding-header "Delegated")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "-INBOX"
                       ((org-agenda-overriding-header "On Hold")
                        (org-agenda-skip-function
                         '(lambda ()
                            (or (org-agenda-skip-subtree-if 'todo '("WAITING"))
                                (org-agenda-skip-entry-if 'nottodo '("HOLD")))))
                        (org-tags-match-list-sublevels nil)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            ;; (tags-todo "-NEXT"
            ;;            ((org-agenda-overriding-header "All other TODOs")
            ;;             (org-match-list-sublevels t)))
            )))))
  (add-hook 'org-agenda-mode-hook 'hl-line-mode)

(defun emacs-agenda ()
  "Launch emacs agenda as new frame."
  (interactive)
  (with-selected-frame (make-frame '((name . "emacs-agenda")
				     (width . 100)
				     (height . 40)))
   (gtd)
   (local-set-key (kbd "q") '(lambda ()
            (interactive)
            (if  (string-equal x-resource-name "emacs-agenda")
                (delete-frame)
              (org-agenda-quit))))))

(use-package toc-org
  :hook (org-mode . toc-org-mode))

(defun dw/org-babel-tangle-dont-ask ()
  ;; Dynamic scoping to the rescue
  (let ((org-confirm-babel-evaluate nil))
    (org-babel-tangle)))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'dw/org-babel-tangle-dont-ask
                                              'run-at-end 'only-in-org-mode)))

(use-package org-attach-screenshot
  :config
  (setq org-attach-screenshot-command-line "/usr/share/sway/scripts/grimshot copy area") )

(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode)
  :hook (pdf-tools-enabled . hide-mode-line-mode)
  :hook (pdf-tools-enabled . pdf-view-midnight-minor-mode)
  :hook (pdf-tools-enabled . pdf-view-printer-minor-mode)
  :config
  (pdf-tools-install 'no-query)
  (setq-default pdf-view-display-size 'fit-page)
  :bind (
         :map pdf-view-mode-map
         ("h" . pdf-annot-add-highlight-markup-annotation)
         ("t" . pdf-annot-add-text-annotation)
         ("D" . pdf-annot-delete))
  )

(use-package latex
  :straight (auctex auctex-latexmk company-math company-auctex cdlatex)
  :defer t
  :custom
  (cdlatex-simplify-sub-super-scripts nil)
  (reftex-default-bibliography
   '("~/doc/references.bib"))
  (bibtex-dialect 'biblatex)
  :mode
  ("\\.tex\\'" . latex-mode)
  :bind (:map LaTeX-mode-map
              ("C-c C-e" . cdlatex-environment)
              )
  :hook
  (LaTeX-mode . outline-minor-mode)
  (LaTeX-mode . TeX-PDF-mode)
  (LaTeX-mode . company-mode)
  (LaTeX-mode . flyspell-mode)
  (LaTeX-mode . flycheck-mode)
  (LaTeX-mode . LaTeX-math-mode)
  (LaTeX-mode . turn-on-reftex)
  (LaTeX-mode . TeX-source-correlate-mode)
  (LaTeX-mode . try/latex-mode-setup)
  (LaTeX-mode . turn-on-cdlatex)

  :config
  (setq TeX-auto-save t
        TeX-parse-self t
        TeX-save-query nil
        reftex-plug-into-AUCTeX t
        TeX-view-program-selection '((output-pdf "PDF Tools"))
        TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view))
        TeX-source-correlate-start-server t)
  (setq-default TeX-master nil)
  (setq auctex-latexmk-inherit-TeX-PDF-mode t)
  ;; very important so that PDFView refesh itself after comilation
  (add-hook 'TeX-after-compilation-finished-functions
            #'TeX-revert-document-buffer)
  (auctex-latexmk-setup))

(with-eval-after-load 'ox-latex
  (add-to-list 'org-latex-classes
               '("new-aiaa"
                 "\\documentclass{new-aiaa}
          [NO-DEFAULT-PACKAGES]
          [PACKAGES]
          [EXTRA]"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
  (add-to-list 'org-latex-classes
               '("org-article"
                 "\\documentclass{org-article}
       [NO-DEFAULT-PACKAGES]
       [PACKAGES]
       [EXTRA]"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

;; (require-package 'org-ref)
;; (setq org-ref-bibliography-notes "~/doc/references/notes.org"
;;       reftex-default-bibliography '("~/doc/references/references.bib")
;;       org-ref-default-bibliography '("~/doc/references/references.bib")
;;       org-ref-pdf-directory "~/doc/references/bibtex-pdfs/")
;; (setq bibtex-completion-bibliography "~/doc/references/references.bib"
;;       bibtex-completion-library-path "~/doc/references/bibtex-pdfs"
;;       bibtex-completion-notes-path "~/doc/references/helm-bibtex-notes")

(use-package markdown-mode
  :config
  (add-auto-mode 'markdown-mode "\\.md\\.html\\'")
  (after-load 'whitespace-cleanup-mode
    (push 'markdown-mode whitespace-cleanup-mode-ignore-modes)))

(use-package org-roam
  :straight t
  :init
  (setq org-roam-v2-ack t)

  :diminish(org-roam-mode)
  :custom
  (org-roam-directory "~/doc/Roam/")
  (org-roam-completion-everywhere t)
  (org-roam-completion-system 'default)
  (org-roam-dailies-directory "Journal/")
  (setq org-roam-dailies-capture-templates
      '(("d" "default" entry
         "* %?"
         :target (file+head "%<%Y-%m-%d>.org"
                            "#+title: %<%Y-%m-%d>\n"))))
  :bind (("C-c n f"   . org-roam-node-find)
           ("C-c n d"   . org-roam-dailies-goto-date)
           ("C-c n n"   . org-roam-buffer-display-dedicated)
           ("C-c n c"   . org-roam-dailies-capture-today)
           ("C-c n C" . org-roam-dailies-capture-tomorrow)
           ("C-c n t"   . org-roam-dailies-goto-today)
           ("C-c n y"   . org-roam-dailies-goto-yesterday)
           ("C-c n r"   . org-roam-dailies-goto-tomorrow)
           ("C-c n g"   . org-roam-graph)
         :map org-mode-map
         (("C-c n i" . org-roam-node-insert))))

(use-package org-roam-ui
  :straight
    (:host github :repo "org-roam/org-roam-ui" :branch "main" :files ("*.el" "out"))
    :after org-roam
;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
;;         a hookable mode anymore, you're advised to pick something yourself
;;         if you don't care about startup time, use
;;  :hook (after-init . org-roam-ui-mode)
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start nil))

(use-package lsp-mode
  :straight t
  :init
  (setq lsp-keymap-prefix "C-c l")
  ;; uncomment to enable gopls http debug server
  ;; :custom (lsp-gopls-server-args '("-debug" "127.0.0.1:0"))
  :commands (lsp lsp-deferred)
  :custom
  (lsp-idle-delay 0.6)
  (lsp-rust-analyzer-server-display-inlay-hints t)
  :config (progn
            ;; use flycheck, not flymake
            (setq lsp-prefer-flymake nil)))

(use-package lsp-ui
  :straight t
  :custom
  (lsp-ui-doc-position 'bottom)
  (lsp-ui-doc-delay 2 )
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-eldoc-enable-hover nil)
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  :hook (lsp-mode . lsp-ui-mode))

(use-package go-mode
  :config (progn
            (setq compile-command "go build -v && go test -v -cover && go vet && golint") 
            )
  :hook ((go-mode . lsp-deferred)
   (before-save . lsp-format-buffer)
   (before-save . lsp-organize-imports))
  :bind (:map go-mode-map
               ("C-c C-c" . compile))
  )

(use-package ccls
  :straight t
  :config
  (setq ccls-executable "ccls")
  (setq lsp-prefer-flymake nil)
  (setq-default flycheck-disabled-checkers '(c/c++-clang c/c++-cppcheck c/c++-gcc))
  :hook ((c-mode c++-mode objc-mode) .
         (lambda () (require 'ccls) (lsp))))
(defun lsp-cpp-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'cc-mode-hook #'lsp-cpp-install-save-hooks)

(use-package rustic
  :ensure
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status))
  :config
  ;; uncomment for less flashiness
  ;; (setq lsp-eldoc-hook nil)
  ;; (setq lsp-enable-symbol-highlighting nil)
  ;; (setq lsp-signature-auto-activate nil)

  ;; comment to disable rustfmt on save
  (setq rustic-format-on-save t)
  (add-hook 'rustic-mode-hook 'rk/rustic-mode-hook))

(defun rk/rustic-mode-hook ()
  ;; so that run C-c C-c C-r works without having to confirm, but don't try to
  ;; save rust buffers that are not file visiting. Once
  ;; https://github.com/brotzeit/rustic/issues/253 has been resolved this should
  ;; no longer be necessary.
  (when buffer-file-name
    (setq-local buffer-save-without-query t)))

(straight-use-package 'haskell-mode)

(use-package csv-mode)
(add-auto-mode 'csv-mode "\\.[Cc][Ss][Vv]\\'")
(setq csv-separators '("," ";" "|" " " ", "))

(use-package yaml-mode
  :config
  (add-auto-mode 'yaml-mode "\\.yml\\.erb\\'")
  (add-hook 'yaml-mode-hook 'goto-address-prog-mode))

(use-package docker
  :config
  (fullframe docker-images tablist-quit)
  (fullframe docker-machines tablist-quit)
  (fullframe docker-volumes tablist-quit)
  (fullframe docker-networks tablist-quit)
  (fullframe docker-containers tablist-quit))
(use-package dockerfile-mode)
(use-package docker-compose-mode)

(setq gc-cons-threshold (* 2 1000 1000))
