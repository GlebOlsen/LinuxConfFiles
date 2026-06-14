;;; init.el -*- lexical-binding: t; -*-

(doom! :completion
       (vertico +icons)
       (corfu +icons)

       :ui
       doom
       hl-todo
       modeline
       ophints
       (popup +defaults)
       treemacs
       indent-guides
       vc-gutter

       :editor
       (evil +everywhere)
       fold
       snippets
       word-wrap

       :emacs
       (dired +icons)
       electric
       undo
       vc

       :term
       vterm

       :checkers
       syntax

       :tools
       lookup
       magit

       :lang
       emacs-lisp
       nix
       sh
       markdown

       :config
       (default +bindings +smartparens))
