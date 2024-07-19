;; Set up $PATH
(if (string-equal "darwin" (symbol-name system-type))
    (progn
      (setenv "PATH" (concat "/opt/homebrew/bin:/Users/zellyn/bin:/Users/zellyn/Development/go/bin:" (getenv "PATH")))
      (setq exec-path (split-string (getenv "PATH") ":"))))

;(setq exec-path (split-string (getenv "PATH") ":")


;; elpaca bootstrap

(defvar elpaca-installer-version 0.6)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil
                              :files (:defaults (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (call-process "git" nil buffer t "clone"
                                       (plist-get order :repo) repo)))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))
(elpaca-wait)

;;; Move custom file
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

;;; Keyboard customizations
(setq mac-command-modifier 'meta)
(global-set-key (kbd "M-o") 'other-window)


;;; General editing

;; Onsave
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Enable things
(put 'narrow-to-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

;;; Go

(use-package go-mode)

(defun my-go-mode-hook ()
  (setq tab-width 2 indent-tabs-mode 1)
  (add-hook 'before-save-hook 'gofmt-before-save))
(add-hook 'go-mode-hook 'my-go-mode-hook)

(use-package go-dlv)

;;; Org-mode
(use-package toc-org)
(add-hook 'org-mode-hook 'toc-org-mode)

;;; Markdown

(use-package markdown-mode)

;; Left and right double quotes
;; (define-key markdown-mode-map "\M-[" (lambda ()
;; 				       (interactive)
;; 				       (insert-char #x201C)))
;; (define-key markdown-mode-map "\M-]" (lambda ()
;; 				       (interactive)
;; 				       (insert-char #x201D)))
;;
;;; UI behaviour customizations

;; Popwin - hide popup windows automatically when done
;; (use-package popwin)
;; (popwin-mode 1)

;;; Custom functions

;; lemon/pikchr
(defun fix-simple ()
  (interactive)
  (beginning-of-buffer)
  (replace-string "/_*" "/*")
  (beginning-of-buffer)
  (replace-string "*_/" "*/")
  (beginning-of-buffer)
  (replace-string "->" "."))


(use-package magit)
(use-package htmlize)
(use-package yaml-mode)

(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (cmake "https://github.com/uyha/tree-sitter-cmake")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (go "https://github.com/tree-sitter/tree-sitter-go")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (make "https://github.com/alemuller/tree-sitter-make")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (roc "https://github.com/faldor20/tree-sitter-roc")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

(server-start)

;; zig
(use-package zig-mode)

;; ripgrep
(use-package ripgrep)

(use-package browse-at-remote)


;; (elpaca :repo "https://gitlab.com/tad-lispy/roc-mode")
;; (elpaca (roc-mode :host gitlab :repo "tad-lispy/roc-mode"))
;; (use-package roc)
;; (use-package roc-mode)


;; Roc

(use-package roc-mode :ensure (roc-mode :host gitlab :repo "tad-lispy/roc-mode"))

;; https://www.reddit.com/r/emacs/comments/6tj8v3/comment/dll8yoy
(defun roc-fmt-region-or-buffer ()
  "use shell command to format buffer or region via roc format"
  ;;

  (let* ((roc-dir (file-truename (expand-file-name "~/roc/roc_nightly")))
	 (command (concat "cd " roc-dir "; ./roc format --stdin --stdout"))
	 (saved-point (point)))

    ;; (message "command: %s" command)

    (if (use-region-p)
	(shell-command-on-region (region-beginning) (region-end) command t t)
      (shell-command-on-region (point-min) (point-max) command t t)
      (goto-char saved-point))))

;; TODO: save output to buffer, check output value, replace only if necessary
;; [[file:elpaca/repos/go-mode/go-mode.el::defun gofmt (]]


;; Copilot

(use-package editorconfig)
(use-package dash)
(use-package s)
(use-package copilot
  :ensure (copilot :host github
		   :repo "copilot-emacs/copilot.el"
		   :files ("dist" "*.el"))
  :bind (:map copilot-completion-map
	      ("<tab>" . copilot-accept-completion)))

;; github-browse-file

(elpaca github-browse-file)

(use-package jsonrpc)
(use-package terraform-mode)


(setq z/keymap (define-keymap
		 "e" #'mc/edit-lines
		 ))

(use-package multiple-cursors
  :bind (("C->" . mc/mark-next-like-this)
	 ("C-<" . mc/mark-previous-like-this)
	 ("C-c C-<" . mc/mark-all-like-this)
         :prefix "C-c m"
         :prefix-map mc-map
         :prefix-docstring "mc"
	 ("e" . mc/edit-lines)
	 ("a" . mc/mark-all-dwim)))

(elpaca-wait)

;; Backup and lock files

(setq lock-file-name-transforms `((".*" "~/.backups/lock-files/" t)))
(setq auto-save-file-name-transforms `((".*" "~/.backups/auto-saves/" t)))

;; Elm

(use-package elm-mode)
(setq elm-mode-hook '(elm-indent-simple-mode))


;;; Custom functions

;; Thanks Dan Lewis
;; https://square.slack.com/archives/C02R18K7D/p1710526650060819?thread_ts=1710515407.734919&cid=C02R18K7D
(defun join-lines ()
  "Make region of multiple lines into a single line, joined with a single space"
  (interactive)
  (save-excursion
    (if mark-active
        (replace-regexp
         "\\s-*\n\\s-*"
         " "
         nil
         (min (point) (mark))
         (max (point) (mark))))))


; (use-package orderless
;   :ensure t
;   :custom
;   (completion-styles '(orderless basic))
;   (completion-category-overrides '((file (styles basic partial-completion)))))

;; Local Variables:
;; no-byte-compile: t
;; End:
