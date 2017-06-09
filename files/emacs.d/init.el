;;; -*- lexical-binding: t -*-
;;;
;;; Copyright (C) 2017 Mike Gerwitz
;;;
;;;  This program is free software: you can redistribute it and/or modify
;;;  it under the terms of the GNU General Public License as published by
;;;  the Free Software Foundation, either version 3 of the License, or
;;;  (at your option) any later version.
;;;
;;;  This program is distributed in the hope that it will be useful,
;;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;;  GNU General Public License for more details.
;;;
;;;  You should have received a copy of the GNU General Public License
;;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;;

;; ;_; Guile Scheme please
(require 'cl)

(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("org" . "http://orgmode.org/elpa/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))

(package-initialize)
;;(require 'undo-tree)
(require 'fill-column-indicator)
(require 'w3m)

(defface hidden '((t (:foreground nil :background nil)))
  "Hide text")

;; anti-gui!
                                        ;(scroll-bar-mode -1)
                                        ;(fringe-mode 0)
                                        ;(tooltip-mode -1)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq cursor-in-selected-window nil)
(setq-default indicate-buffer-boundaries '((top . left) (bottom . left)))

(fringe-mode nil)

(add-to-list 'default-frame-alist
             '(font . "DejaVuSansMono:hinting=full:hintstyle=hintslight:antialias=true:pixelsize=10"))

(setq
 inhibit-splash-screen t

 ;; anti-gui!
 use-dialog-box  nil

 ;; what's that thing I did N days ago?
 history-length 1024

 enable-recursive-minibuffers t
 isearch-resume-in-command-history t

 ;; TODO: can we actually make this height 0 like in vim?
 window-min-height 0
 resize-mini-windows t

 ;; scrolling
 scroll-margin         3
 scroll-conservatively 1
 recenter-redisplay    nil
 evil-want-C-u-scroll  t

 ;; undo entire insert as a unit
 evil-want-fine-undo 'no

 ;; save after each bookmark modification
 bookmark-save-flag 1

 ;; shell indentation
 sh-indentation  2
 sh-basic-offset 2

 ;; save-my-ass features
 backup-directory-alist         '(("." . "~/tmp/"))
 auto-save-file-name-transforms '((".*" "~/tmp/" t))
 kept-new-versions              8
 kept-old-versions              2
 delete-old-versions            t

 ;; X primary selection
 x-select-enable-clipboard nil
 x-select-enable-primary   t
 mouse-drag-copy-region    t

 ;; this will not often be used, since most of my editing is done using
 ;; a VCS
 version-control t

 ;; not defined until 24.3; I do not need lockfiles, because all shared
 ;; editing occurs via a VCS
 create-lockfiles nil

 ;; line numbering (we ignore nlinum-format for performance)
 nlinum-format-function
  (lambda (line width)
    (let ((str (concat (number-to-string line) " ")))
      (when (< (length str) width)
        ;; Left pad to try and right-align the line-numbers.
        (setq str (concat (make-string (- width (length str)) ?0) str)))
      (put-text-property 0 width 'face 'linum str)
      ;; FIXME: this relies on the fact that the format has a trailing space
      (put-text-property (1- width) width 'face 'hidden str)
      str))

 ;; various options for major modes (faces disabled in favor of fci)
 fill-column 76
 whitespace-style '(face
                    spaces
                    tabs
                    newline
                    space-mark
                    tab-mark
                    trailing)

 ;; ediff
 ediff-split-window-function 'split-window-horizontally

 ;; desktop
 desktop-restore-frames             t
 desktop-resture-in-current-display t
 desktop-restore-forces-onscreen    nil

 ;; org mode
 org-directory                  "~/org"
 org-startup-indented           t
 org-startup-truncated          nil
 org-enfroce-todo-dependencies  t
 org-default-notes-file         (concat org-directory "/scratch.org")

 ;; browser
 browse-url-browser-function 'w3m-browse-url)

;; right-aligned line numbering
;;(global-nlinum-mode)

;; TODO: submit a patch to fci to use face so that this can be themed
(setq-default fci-handle-truncate-lines nil
              fci-rule-color            "#262626")

(icomplete-mode)

(set 'electric-indent-chars
     (remq ?\n electric-indent-chars))


(defun desktop-save-in-desktop-dir-quiet ()
  (interactive)
  (if (eq (desktop-owner) (emacs-pid))
      (desktop-save desktop-dirname)))
(add-hook 'auto-save-hook 'desktop-save-in-desktop-dir-quiet)


(defun set-tab-width (width)
  "Set tab width to WIDTH and generate tab stops"
  (setq tab-width width)
  (setq tab-stop-list
        (number-sequence width 120 width)))

(setq-default indent-tabs-mode nil)
(set-tab-width 4)

(defun disable-mode-fn (mode)
  "Return function to disable `MODE'"
  (lambda ()
    (funcall mode -1)))

(global-set-key (kbd "C-x g") 'magit-status)

(global-hi-lock-mode 1)
(column-number-mode 1)

(eval-after-load "outline" '(require 'foldout))

(defconst my-mode-hooks
  `((turn-on-auto-fill . (text-mode-hook
                          prog-mode-hook))

    ;; perf issues
    ;; (fci-mode         . (prog-mode-hook))

    ;; highlight lines (no global mode, since that makes disabling it
    ;; per-buffer a PITA)
    (hl-line-mode . (text-mode-hook
                     prog-mode-hook))

    (show-paren-mode     . (prog-mode-hook))
    (electric-pair-mode  . (prog-mode-hook))
    (which-function-mode . (prog-mode-hook))
    (flyspell-prog-mode  . (prog-mode-hook))
    (diff-hl-mode  . (prog-mode-hook))
    (diff-hl-flydiff-mode  . (prog-mode-hook))
    (adaptive-wrap-prefix-mode . (prog-mode-hook))

    (,(apply-partially 'c-set-style "psr2") . (php-mode-hook))

    (flyspell-mode      . (text-mode-hook))

    (whitespace-mode . (text-mode-hook
                        prog-mode-hook))

    (rainbow-delimiters-mode . (lisp-mode-hook))

    (flymake-mode . (php-mode-hook))

    ;; skimpy tabbing
    (,(apply-partially 'set-tab-width 2) . (shell-mode-hook
                                            nxml-mode-hook))

    ;; knock it off prog modes
    (,(apply-partially 'set-fill-column 76) . (prog-mode-hook))

    ;; these modes do not cooperate with electric-pair-mode
    (,(disable-mode-fn 'electric-pair-mode) . (nxml-mode-hook))

    ;; flyspell is too much atop of the slow nxml processing
    (,(disable-mode-fn 'flyspell-mode) . (nxml-mode-hook))

    ;; FIXME: until I can figure out a consistent solution to face
    ;; precedence; it highlights whitespace in its own face, unless you load
    ;; whitespace-mode after it, so we'll get rid of it for now
    (,(disable-mode-fn 'whitespace-mode) . (message-mode-hook
                                            sql-mode-hook))

    ;; no line highlighting in terminals
    (,(disable-mode-fn 'hl-line-mode) . (term-mode-hook)))
  "List of pairs defining functions to be applied to hooks

The purpose of this is to be able to determine, at a glance, all modes to
which the given function or minor mode apply.  It is trivial to see the
reverse by inspecting the runtime value of those hooks.")

;; apply mode hooks
(mapc (lambda (pair)
        (let ((f     (car pair))
              (modes (cdr pair)))
          (mapc (lambda (mode)
                  (add-hook mode f t))
                modes)))
      my-mode-hooks)

;; do not get in the way of scrolling in termianls
(add-hook 'term-mode-hook
          (lambda ()
            (setq scroll-margin 0)))

(define-key global-map
  (kbd "RET") 'newline-and-indent)

(define-key global-map
  (kbd "\C-C \C-X \C-W")
  (lambda ()
    (interactive)
    (setq browse-url-browser-function
          (if (eq browse-url-browser-function 'browse-url-default-browser)
              'w3m-browse-url
            'browse-url-default-browser))
    (message (symbol-name browse-url-browser-function))))

;; CamelCase and such screws with things
;;(add-hook 'flyspell-prog-mode-hook
;;          (lambda ()
;;            (setq flyspell-prog-text-faces
;;                  (delete 'font-lock-string-face flyspell-prog-text-faces))))

(setq ispell-extra-args '("-C"
                          "--sug-mode=ultra"
                          "--run-together-limit=5"))

(define-key global-map
  "\C-cc" 'org-capture)

(global-auto-revert-mode)

(add-to-list 'load-path "~/.emacs.d/wiki")
(add-to-list 'load-path "~/.emacs.d/contrib")

(add-to-list 'load-path "~/gitrepos/rainbow-delimiters")
(add-to-list 'load-path "~/gitrepos/emacs-soap-client")

(require 'rainbow-delimiters)
(require 'sentence-highlight)
(require 'evil)
(require 'evil-search-highlight-persist)
(require 'evil-matchit)
(require 'evil-surround)
(require 'org-collector)

(evil-mode 1)
(global-evil-search-highlight-persist t)
(global-evil-matchit-mode t)
(global-evil-surround-mode t)

;; desktop (the first line is suggested by frameset-filter-alist docs)
(setq frameset-filter-alist (copy-tree frameset-filter-alist))
;; I don't know why the default is to not save frame names, but that is
;; deeply frustrating with many frames (I use them like tabs in vim)
(add-to-list 'frameset-filter-alist
             '(name . nil))


(winner-mode)

(defun evil-window-select-expand (direction)
  "Select window in DIRECTION and expand to fill available frame height"
  (windmove-do-window-select direction)
  (evil-window-set-height nil))

;; move up/down a window and expand to full height
(mapc #'(lambda (assoc)
          (eval `(evil-define-key 'normal global-map
                   ,(car assoc)
                   (lambda ()
                     (interactive)
                     (evil-window-select-expand ,(cdr assoc))))))
      '(("\C-k" . 'up)
        ("\C-j" . 'down)))

(defun select-prev-frame-name ()
  (interactive)
  (let ((name (cadr frame-name-history)))
    (if name
        (progn
          (select-frame-by-name name)
          (setq frame-name-history
                (cons name frame-name-history)))
      (user-error "No previous frame"))))


(defun start-new-sprint ()
  "Delete all dev-* frames to prepare for new sprint"
  (interactive)
  (dolist (frame (frame-list))
    (let ((name (cdr (assq 'name (frame-parameters frame)))))
      (if (neq (string-match-p "^dev-" name) nil)
          (delete-frame frame)))))


(evil-define-key 'normal global-map
  "]s" 'flyspell-goto-next-error
  "]e" 'next-error
  "[e" 'previous-error
  "gt" 'other-frame
  "gT" (lambda (n)
         (interactive "p")
         (other-frame (- n)))
  "\C-w/" 'select-frame-by-name
  "\C-w," 'select-prev-frame-name
  ;; note that you can still return to Emacs mode in insert mode
  "\C-z" 'suspend-emacs)

(defun my-get-serious (&optional flag)
  (interactive)
  ;; just use nlinum mode as an indicator of whether we're
  ;; serious or not
  (let ((arg (or flag
                 (if (my-serious-p) -1 t))))
    (nlinum-mode arg)
    (color-identifiers-mode arg)

    ;; should already be enabled for prog modes, but
    ;; enabling it twice causes issues when disabling
    (unless whitespace-mode
      (whitespace-mode arg))

    ;; shh (clear noisy messages from above)
    (message "")))


(defun my-get-serious-exclusive ()
  (interactive)
  (save-selected-window
    (dolist (window (window-list))
      (select-window window)
      (my-get-serious -1)))
  (my-get-serious t))


(defun my-serious-p ()
  (and (eq nlinum-mode t)
       (eq color-identifiers-mode t)))


(defun my-nonserious-linum ()
  (interactive)
  (if (my-serious-p)
      (my-get-serious -1))
  (nlinum-mode (if nlinum-mode -1 t)))

;; i = "into", like "get into it"
(global-set-key (kbd "C-c i") 'my-get-serious)
(global-set-key (kbd "C-c I") 'my-get-serious-exclusive)
(global-set-key (kbd "C-c l") 'my-nonserious-linum)

(global-set-key (kbd "C-x C-M-f") 'fiplr-find-file)

;; not only obnoxious, but the output mode doesn't parse ASCII color
;; sequences
(setq phpunit-arg "--colors=never")

(add-hook 'php-mode-hook
          (lambda ()
            (define-key js-mode-map (kbd "C-x t t")
              (my-switch-test-buffer-then-call 'phpunit-current-class))
            (define-key js-mode-map (kbd "C-x t p")
              (my-switch-test-buffer-then-call 'phpunit-current-project))))

(add-hook 'js-mode-hook
          (lambda ()
            (define-key js-mode-map (kbd "C-x t t")
              (my-switch-test-buffer-then-call 'mocha-test-file))
            (define-key js-mode-map (kbd "C-x t p")
              (my-switch-test-buffer-then-call 'mocha-test-project))))

(defun my-switch-test-buffer-then-call (fn)
  (lambda ()
    (interactive)
    (let (orig-window (selected-window))
      (my-switch-test-buffer)
      (funcall fn)
      (select-window (orig-window)))))

(defun my-test-buffer-name ()
  (let* ((base (file-name-base (buffer-file-name)))
         (ext (file-name-extension (buffer-file-name)))
         (base-nontest (replace-regexp-in-string "Test$" "" base)))
    (concat base-nontest "Test." ext)))

(defun my-switch-test-buffer ()
  (interactive)
  (select-window (display-buffer (my-test-buffer-name))))


;; TODO: upstream
(defun evil-mc-undo-cursor-here ()
  (interactive)
  (evil-mc-undo-cursor-at-pos (point)))
(evil-define-key 'normal evil-mc-key-map
  "grx" 'evil-mc-undo-cursor-here)

;; TODO: Move to general config
(evil-define-key 'insert global-map
  "\C-x\C-l" 'evil-complete-next-line)

;; TODO: Move to general config
(evil-define-key 'visual global-map
  [(control ?\=)] 'my-align-eq)

(defun my-align-eq ()
  (interactive)
  (let ((align-on "=>?"))
    (save-excursion
      (move-beginning-of-line nil))
    (align-regexp (region-beginning)
                  (region-end)
                  (concat "\\(\\s-*\\)" align-on))))

;; TODO: Move to general config
(setq help-window-select t)

(setq-default text-scale-mode-amount 5
              text-scale-mode-step 1.2)

(setq gnus-mime-display-multipart-related-as-mixed t)


;;; Gnus
(load-file "~/.emacs.d/conf/gnus.el")

;; TODO: ADD TO GENERAL
(evilem-default-keybindings "SPC")
(setq-default evil-symbol-word-search t)
(setq-default default-cursor-in-non-selected-windows nil)

(add-to-list
 'command-switch-alist
 '("gnus" . (lambda (&rest ignore)
              (add-hook 'emacs-startup-hook 'gnus t)
              (add-hook 'gnus-after-exiting-gnus-hook
                        'save-buffers-kill-emacs))))

(defun highlight-todos ()
  (font-lock-add-keywords nil
                          '(("\\<TODO:.*$"
                             0
                             'warning)))
  (font-lock-add-keywords nil
                          '(("\\<\\(FIXME\\|XXX\\):.*$"
                             0
                             'font-lock-warning-face prepend))))

(add-hook 'text-mode-hook 'highlight-todos t)
(add-hook 'prog-mode-hook 'highlight-todos t)

(add-hook 'js2-mode-hook (lambda ()
                           (setq c-doc-comment-style 'javadoc)))

;; wtf js3-mode
(add-hook 'js3-mode-hook 'highlight-todos t)
(add-hook 'js3-mode-hook 'whitespace-mode t)

(add-to-list
 'auto-mode-alist
 '("\\.md\\'" . markdown-mode))

(load-theme 'ample-mg t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["color-238" "#cd7542" "#6aaf50" "#baba36" "#5180b3" "#ab75c3" "color-144" "#bdbdb3"])
 '(bm-highlight-style (quote bm-highlight-only-fringe))
 '(bmkp-auto-light-when-set (quote any-bookmark))
 '(bmkp-last-as-first-bookmark-file "~/.emacs.d/bookmarks")
 '(bmkp-light-style-autonamed (quote lfringe))
 '(comment-auto-fill-only-comments t)
 '(custom-safe-themes
   (quote
    ("8db4b03b9ae654d4a57804286eb3e332725c84d7cdab38463cb6b97d5762ad26" "b5fd06da95ae695d2b075f76c62c802b019a62e41e917f999c324417fda06b49" "3e5eba2c31bcc306fa2ad1a0ab27a42eb9f0565a487d89745da7644e2c41ef48" "a300fb5fae1398bc8dcdc133ad4cb40a85e28414dbac459d6b3ebfe5b28b9450" "58282dafa3ebe1666c3218d788e6ea38263dc3a4a9ebb1adab42feba944094f9" "177f551d5cd3039a7be96aaf40e9b3bae5d9d8d09b19a6fba0da4a0dd30f6630" "f764d020a57f72ead1aea66a7f6fd60bc0694ffbe484b004e6031737ab29755c" "e1a5fd2bd7e75accab12975f8f2bf279eb6d3751b4c44179b19b7dd22ffef2ac" "224f8b9ce25e0a828c77c000c35ba2c53a23d4e66101014dc3eb1a8f8d4f88f7" "49bbce1be3fd69cf5064606c925e20032c3ba8f219a3caafd8de0f555d0c92b9" "0d5bc72d4b603c123fc2a3244f1241bceb80e2aeb9cab3d66686ae9b941bfc66" "6f2dce845220dc2246afbb126b3ed9452d4abd8f824c7a1916bd8855031e32aa" "dd16769bccf70f0fa60d63f3b43234296ef76ba4fcc66ea50f99f814b9a2d1db" "4f6fa7077a35f59173fafd0d0cf3f261b02297dba38980a5f247e92cc0168329" "cdd667935dbf5a0499fe5ec40dfb52f489b0dc35c543df6394b3ae5d6989bb07" "26afa77b4b06497e677c7cfeed1013497202171a4419cc897d57631d5cd37c88" "31b872a851e8d209e9841900d03e82e0b5a4edd5b5264c1b5760b27f99b38494" "cdf2bcf6a8dc55f6ea1952ea801b354694d4637141a1d583517b64b6f251c14d" "965fc2b6331dfa8e7ef23dac6bda28e99bce4c2281017afb4a69b1271c75f26b" "43ce8339120968d44f0469fa4c27a50e8ad5d23d77fc0a1e0db73efb6b993867" "e59ae2921898d80da3b96946e5209f7444f41ade8447d6dfc1af60742c83da17" "9371453e41aac21d5b497495f62addde1403f66d9ed5d3d1c99c6bca97f90d2b" "fb544d15e7b86166dac42852dbdca1c925a3c264727a2ad5405e83e9518779d5" "b42f254097e35ef7ffc358f1761752a4e57b87666ea68acd4f14c6e6fcc00600" "0ef12f3616401e66056902a57801cf1f8d1424862c14a8d81948f7ebeccf2e29" "6dd8165dbfcaa4e2bff47a49047ddc9aefef72f13a581e35e841e208085cb234" "15510277fdb3328ff2f09fbbbf1d076f4b6fc9780307e3aa8cad15f9be130418" "33703cf1e77822f53234f978715a708a34443bb2a4aa743b46fa4ff0ad5b87a3" "39575c14b899508d4396237f9fd395187dba7f6fe3f55e208d9b7e6757a8f787" "3bd2ac0df813db3e0c621ba2b60ef4c35ff0a170d29dde7775b4c63d77b86d85" "38d233bd1fc80b1a5742d250be01f13a5ca30d4d1c97dd35d2649b26946f1569" "bdc08f2bf6f81d35b50774fb0af6ebdaa53a52997877e5a8645cff73c1ad0ec4" "5921766f185dc88e7be19f975fe8bcf74acfe0f9a30b65d48b0dccb64513002e" "8756857b912e7d45e66faa98f09492f49e3b85b9cfad9d66e8e56fa3845c771b" "d673ab6d6dd920b494779a4f40e98944dc811e8109fd12a2573bc1da004414a3" "6f2c9853eb36fd91e7d7614ac64db74dac2e7a68ca7228210a8a41ecfbae418d" "1952011134c26364c2596299c0d6014cf32e24065d0c16ef7f8f262d3bd0d7e7" "4c00f87e7cbae6adfe6760567d2ed3688650a6990bab665cc944f0ba063e3308" "aa1ed7440b86675ad08dff79f95300b176172d4426c7f066ca221966b718be3c" "1ddf74c4e2c409d7f5a43be420f74b59937a79ff99b87990aaa983784c71206f" "a98480fb482f331058b949c8daebc8bba87498820605b959472a84e643406a4f" "5a4b738abb68ee9e764a88b39dbed8c4603b5e814d53d950a22c9942099a12d7" default)))
 '(desktop-auto-save-timeout 10)
 '(desktop-restore-forces-onscreen (quote all))
 '(desktop-restore-in-current-display t)
 '(desktop-restore-reuses-frames :keep)
 '(ediff-split-window-function (quote split-window-horizontally) t)
 '(electric-pair-mode t)
 '(geiser-guile-binary "/opt/guile-2.2.0/bin/guile")
 '(jiralib-host "")
 '(jiralib-url "https://lovullo.atlassian.net")
 '(js-indent-first-init nil)
 '(js2-bounce-indent-p nil)
 '(js2-highlight-level 3)
 '(js2-include-node-externs t)
 '(js2-missing-semi-one-line-override t)
 '(js2-strict-trailing-comma-warning nil)
 '(js3-boring-indentation t)
 '(js3-continued-expr-mult 4)
 '(js3-enter-indents-newline t)
 '(js3-expr-indent-offset 4)
 '(js3-indent-dots t)
 '(js3-indent-level 4)
 '(js3-lazy-dots t)
 '(js3-mirror-mode t)
 '(js3-paren-indent-offset 0)
 '(js3-square-indent-offset 4)
 '(js3-strict-trailing-comma-warning nil)
 '(mocha-command "node_modules/.bin/mocha --harmony_destructuring")
 '(org-agenda-files
   (quote
    ("~/gitrepos/gerwitm-lv-notes/projects/" "~/gitrepos/gerwitm-lv-notes/")))
 '(org-agenda-window-setup (quote current-window))
 '(org-default-notes-file "~/gitrepos/gerwitm-lv-notes/scratch.org")
 '(org-src-fontify-natively t)
 '(package-selected-packages
   (quote
    (mocha unicode-fonts bookmark+ color-identifiers-mode js2-mode php-scratch php-refactor-mode evil-mc-extras evil-mc ggtags phpunit gitlab diff-hl yasnippet evil-magit php-mode zeal-at-point yaml-mode web-mode w3m twig-mode sentence-highlight rainbow-delimiters puppet-mode projectile php-extras org-jira nlinum mc-extras markdown-mode magit less-css-mode jira htmlize hackernews goto-last-change geiser geben flymake-puppet flymake-phpcs flymake-php flycheck fiplr fill-column-indicator expand-region evil-surround evil-search-highlight-persist evil-matchit evil-easymotion evil ess csharp-mode crosshairs color-theme-zenburn color-theme-wombat color-theme-vim-insert-mode color-theme-twilight color-theme-tangotango color-theme-tango color-theme-solarized color-theme-sanityinc-tomorrow color-theme-sanityinc-solarized color-theme-railscasts color-theme-monokai color-theme-molokai color-theme-library color-theme-ir-black color-theme-heroku color-theme-gruber-darker color-theme-github color-theme-emacs-revert-theme color-theme-eclipse color-theme-dpaste color-theme-dg color-theme-complexity color-theme-cobalt color-theme-buffer-local color-theme-actress aggressive-indent adaptive-wrap ac-php)))
 '(persp-mode t)
 '(projectile-globally-ignored-file-suffixes (quote ("xmlo" "csvo" "xmle")))
 '(send-mail-function (quote sendmail-send-it))
 '(undo-tree-auto-save-history t)
 '(undo-tree-history-directory-alist (quote (("." . "~/.emacs.d/undo/"))))
 '(yas-global-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(avy-lead-face ((t (:background "red" :foreground "white"))))
 '(avy-lead-face-0 ((t (:background "blue" :foreground "white"))))
 '(avy-lead-face-1 ((t (:background "cyan" :foreground "white"))))
 '(avy-lead-face-2 ((t (:background "magenta" :foreground "white"))))
 '(js2-object-property ((t (:inherit font-lock-variable-name-face))))
 '(magit-blame-heading ((t (:background "grey25" :foreground "white"))))
 '(org-block ((t (:inherit org-block-background))))
 '(org-block-background ((t (:background "gray15"))))
 '(org-column ((t (:background "color-236" :strike-through nil :underline nil :slant normal :weight normal)))))
(put 'narrow-to-region 'disabled nil)

                                        ; '(js3-boring-indentation t)
                                        ; '(js3-continued-expr-mult 4)
                                        ; '(js3-enter-indents-newline t)
                                        ; '(js3-expr-indent-offset 4)
                                        ; '(js3-indent-dots t)
                                        ; '(js3-indent-level 4)
                                        ; '(js3-lazy-dots t)
                                        ; '(js3-paren-indent-offset 0)
                                        ; '(js3-square-indent-offset 4)


;;;;;;
(setq fiplr-ignored-globs
      '((directories
         (".git" ".svn" ".hg" ".bzr" ".cvs" "vendor" "node_modules" "cache"))
        (files
         (".#*" "*~" "*.so" "*.jpg" "*.png" "*.gif" "*.pdf" "*.gz" "*.zip"))))

(setq *grizzl-read-max-results* 50)

(setq max-mini-window-height 0.9)

(setq flymake-phpcs-standard "LoVullo")
(setq flycheck-phpcs-standard "LoVullo")

(require 'subr-x)
;;;;;


(defun close-fat-fingers ()
  "Close Emacs in a way that won't piss me off.  Usually this is when I
fat-finger `C-x C-c' in a GUI session by pressing between both keys."
  (interactive)
  (and (or (frame-parameter nil 'client)
           (yes-or-no-p "Are you sure you want to quit, Mr. Fat Fingers? "))
       (save-buffers-kill-emacs)))

(defun close-other-frames-fat-fingers ()
  "`C-x 5 1' is dangerously close to `C-x 5 2', and can't be undone."
  (interactive)
  (and (yes-or-no-p "Are you sure you want to close all other frames, Mr. Fat Fingers? "))
       (delete-other-frames))

(global-set-key (kbd "C-x C-c") 'close-fat-fingers)
(global-set-key (kbd "C-x 5 1") 'close-other-frames-fat-fingers)

(global-set-key (kbd "C-c a") 'org-agenda)


(defun geben-dump-current-word ()
  "Evaluate a word at where the cursor is pointing."
  (interactive)
  (let ((expr (concat "var_dump(" (current-word) ")")))
    (message expr)
    (when expr
      (geben-with-current-session session
                                  (geben-dbgp-command-eval session expr)))))


(defun my-guess-php-bundle (&optional file-name)
  (let* ((dirname (file-name-directory
                   (or file-name buffer-file-name))))
    (fiplr-find-root dirname '("Lib"))))


;; TODO: this calls the one above; maybe combine?
(defun my-guess-php-bundle-subpath (&optional file-name)
  (let* ((dirname (file-name-directory
                   (or file-name buffer-file-name)))
         (bundle-path (my-guess-php-bundle file-name)))
    (substring dirname
               (length bundle-path)
               -1)))


(defun my-guess-php-ns (&optional file-name)
  (let* ((dirname (file-name-directory
                   (or file-name buffer-file-name)))
         (prefix (concat (fiplr-find-root dirname '("src"))
                         "src/")))
    (replace-regexp-in-string "/"
                              "\\\\"
                              (substring dirname
                                         (length prefix)
                                         -1))))

(defun my-guess-php-sut (&optional file-name)
  (let* ((the-file-name (or file-name buffer-file-name))
         (ns (my-guess-php-ns the-file-name)))
    (replace-regexp-in-string
     "\\\\[Tt]ests?\\\\"
     "\\\\"
     (replace-regexp-in-string
      "Test$"
      ""
      (concat
       ns
       "\\"
       (file-name-sans-extension
        (file-name-nondirectory the-file-name)))))))

(defun my-php-sut-file-name (&optional test-file-name)
  (let* ((the-test-file-name (or test-file-name
                                 buffer-file-name)))
    (replace-regexp-in-string "/[Tt]ests?/"
                              "/"
                              (replace-regexp-in-string "Test\.php$"
                                                        ".php"
                                                        the-test-file-name))))

(defun my-php-test-file-name (&optional sut-file-name)
  (let* ((the-sut-file-name (or sut-file-name
                                buffer-file-name))
         (bundle-path (my-guess-php-bundle sut-file-name))
         (bundle-sub-path (my-guess-php-bundle-subpath sut-file-name)))
    (concat bundle-path
            "Tests/"
            bundle-sub-path
            "/"
            (replace-regexp-in-string
             "\.php$"
             "Test.php"
             (file-name-nondirectory the-sut-file-name)))))

(defun my-make-php-sut (&optional test-file-name split)
  (interactive)
  (let* ((sut-file-name (my-php-sut-file-name test-file-name)))
    (set-buffer
     (find-file sut-file-name))
    (when (zerop (buffer-size))
      (insert "class")
      (yas-expand))))

(defun my-make-php-test (&optional sut-file-name split)
  (interactive)
  (let* ((test-file-name (my-php-test-file-name sut-file-name)))
    (set-buffer
     (find-file test-file-name))
    (when (zerop (buffer-size))
      (insert "testcase")
      (yas-expand))))


(defun my-make-php-exception (exception-path)
  (interactive (list
                (read-directory-name "Exception path: "
                                     (concat (my-guess-php-bundle)
                                             "Exception/"))))
  (set-buffer
   (find-file exception-path))
  (when (zerop (buffer-size))
    (insert "exception")
    (yas-expand)))


(defvar my-marked-window nil)

(defun my-mark-window ()
  (interactive)
  (setq my-marked-window (selected-window)))

(defun my-jump-marked-window ()
  (interactive)
  (select-window my-marked-window))

(defun my-swap-marked-window ()
  (interactive)
  (let ((prev-window my-marked-window))
    (my-mark-window)
    (select-window prev-window)))

(defun my-reset-windows ()
  "Reset windows to a sane configuration.

This is usually desirable after I increase my tiny font size in a number of
different buffers while someone is at my desk."
  (interactive)
  (save-selected-window
    (dolist (window (window-list))
      (select-window window)
      (text-scale-increase 0))))

(defun my-split-window-parent (side)
  (let* ((parent-window (window-parent (selected-window)))
         (orig-window (selected-window))
         (orig-next (window-next-sibling))
         (orig-next-buffer (if orig-next (window-buffer orig-next))))
    (if (eq parent-window (frame-root-window))
        (let ((new-window (split-window orig-window nil side)))
          ;; this is assuming that it's vertical (move the next sibling into
          ;; the window we just split on)
          (when orig-next
            (delete-window orig-next)
            (split-window (selected-window) nil 'left)
            (set-window-buffer nil orig-next-buffer)
            (select-window new-window)))
      (split-window parent-window nil side))))

(defun my-split-window-parent-above ()
  (interactive)
  (my-split-window-parent 'above))

(defun my-split-window-parent-below ()
  (interactive)
  (my-split-window-parent 'below))

(defun my-split-window-vhalf ()
  (interactive)
  (select-window (split-window (frame-root-window) nil 'right))
  (switch-to-buffer "*scratch*")
  (split-window (selected-window) nil 'right))

(eval-after-load 'evil-ex
  '(evil-ex-define-cmd "spa[bove]" 'my-split-parent-window-above))
(eval-after-load 'evil-ex
  '(evil-ex-define-cmd "spb[elow]" 'my-split-parent-window-below))

(setq org-directory "~/gitrepos/gerwitm-lv-notes")
