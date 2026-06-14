;;; config.el -*- lexical-binding: t; -*-

(setq doom-theme 'doom-badger
      doom-themes-enable-italic nil    ; disable italics
      display-line-numbers-type 'relative)

;; current line accent: B3FF00 number; line + number bg = B3FF00 @ ~8% (0x15)
;; (face bg has no alpha, so pre-blended over doom-badger bg #171717 -> #242A15)
(custom-set-faces!
  '(hl-line :background "#242A15")
  '(line-number-current-line :foreground "#B3FF00" :background "#242A15" :weight bold))

;;; options (nvim opt.* parity)
(setq scroll-margin 12
      scroll-conservatively 101
      maximum-scroll-margin 0.5
      mouse-wheel-scroll-amount '(2 ((shift) . 1))
      mouse-wheel-progressive-speed nil)
(setq-default tab-width 2
              evil-shift-width 2
              indent-tabs-mode nil
              truncate-lines nil)
(setq evil-split-window-below t      ; splitbelow
      evil-vsplit-window-right t)    ; splitright

;; mouse in terminal (foot / dm -nw); GUI has it already
(xterm-mouse-mode 1)

;; wrap=true + breakindent
(+global-word-wrap-mode +1)

;; show trailing whitespace in editable buffers (listchars trail)
(add-hook! '(prog-mode-hook text-mode-hook conf-mode-hook)
  (setq show-trailing-whitespace t))

;; colorizer (nvim-colorizer parity) — show hex/rgb colors inline
(add-hook! '(prog-mode-hook conf-mode-hook) #'rainbow-mode)

;; clipboard=unnamedplus — GUI works natively; bridge Wayland clip in TTY
(when (and (not (display-graphic-p)) (executable-find "wl-copy"))
  (setq interprogram-cut-function
        (lambda (text &optional _)
          (let ((p (make-process :name "wl-copy" :buffer nil
                                 :command '("wl-copy") :connection-type 'pipe)))
            (process-send-string p text)
            (process-send-eof p))))
  (setq interprogram-paste-function
        (lambda ()
          (let ((s (shell-command-to-string "wl-paste -n")))
            (unless (string-empty-p s) s)))))

;;; treemacs on the right (nvim-tree parity)
(after! treemacs
  (setq treemacs-position 'right
        treemacs-width 30))

;;; vterm apps (lazygit / scooter), project root, auto-close on quit
(defun my/vterm-app (name cmd)
  "Run CMD as a one-shot fullscreen vterm named NAME at project root."
  (require 'vterm)
  (let* ((default-directory (or (doom-project-root) default-directory))
         (vterm-shell (concat cmd "; exit"))
         (vterm-kill-buffer-on-exit t)
         (buf (generate-new-buffer (format "*%s*" name))))
    (with-current-buffer buf (vterm-mode))
    (switch-to-buffer buf)))

(defun my/lazygit () (interactive) (my/vterm-app "lazygit" "lazygit"))
(defun my/scooter () (interactive) (my/vterm-app "scooter" "scooter"))

;;; auto-center after search (n / N)
(dolist (cmd '(evil-ex-search-next evil-ex-search-previous
               evil-search-next evil-search-previous))
  (advice-add cmd :after (lambda (&rest _) (ignore-errors (recenter)))))

;;; keymaps (nvim parity)
(map! ;; window nav
      :n "C-h" #'evil-window-left
      :n "C-j" #'evil-window-down
      :n "C-k" #'evil-window-up
      :n "C-l" #'evil-window-right
      ;; window resize
      :n "C-<up>"    #'evil-window-increase-height
      :n "C-<down>"  #'evil-window-decrease-height
      :n "C-<left>"  #'evil-window-decrease-width
      :n "C-<right>" #'evil-window-increase-width
      ;; scroll + center
      :n "C-d" (cmd! (evil-scroll-down 0) (recenter))
      :n "C-u" (cmd! (evil-scroll-up 0) (recenter))
      ;; clear search highlight
      :n [escape] #'evil-ex-nohighlight
      ;; visual: move text + indent reselect
      :v "J" #'drag-stuff-down
      :v "K" #'drag-stuff-up
      :v "<" (cmd! (evil-shift-left (region-beginning) (region-end))
                   (evil-normal-state) (evil-visual-restore))
      :v ">" (cmd! (evil-shift-right (region-beginning) (region-end))
                   (evil-normal-state) (evil-visual-restore)))

;;; avy (hop parity) — let-bind avy-all-windows so it jumps across ALL windows
;; (Doom defaults avy-all-windows to nil; wrappers force it on per-call)
(defun my/avy-word () (interactive) (let ((avy-all-windows t)) (avy-goto-word-1)))
(defun my/avy-line () (interactive) (let ((avy-all-windows t)) (avy-goto-line)))
(defun my/avy-char () (interactive) (let ((avy-all-windows t)) (avy-goto-char)))
(map! :leader
      :desc "Hop word" "h w" #'my/avy-word
      :desc "Hop line" "h l" #'my/avy-line
      :desc "Hop char" "h c" #'my/avy-char)

(map! :leader
      :desc "Explorer"      "e"   #'+treemacs/toggle
      :desc "Undo tree"     "u"   #'vundo
      :desc "Format/indent" "f m" (cmd! (indent-region (point-min) (point-max)))
      :desc "Lazygit"       "o g" #'my/lazygit
      :desc "Scooter"       "o s" #'my/scooter)

(map! :v :leader
      :desc "Indent region" "f m" (cmd! (indent-region (region-beginning) (region-end))))
