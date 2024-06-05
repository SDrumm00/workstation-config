;; Default Theme Settings

; Misc UI Settings
(setq inhibit-startup-message t)	;Disable welcome screen

(scroll-bar-mode -1)			; Disable visible scrollbar
(tool-bar-mode -1)			; Disable toolbar on top
(tooltip-mode -1)			; Disable tooltips
(set-fringe-mode 10)			; Give some breathing room

(menu-bar-mode -1)			; Disable the menu bar

(setq visible-bell t)			; Set up the visible bell

; FONTS: Set fonts to Fira Code for easy reading
(set-face-attribute 'default nil :font "Fira Code Retina" :height 120)

; COLOR THEMES: Default theme enabled initially
(load-theme 'wombat)

; KEYBINDINGS:
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Initialize Package Repos for add-ons and extending functionality of Emacs
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
   (package-refresh-contents))

; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Installed Packages and their relative configurations
(use-package command-log-mode)

(use-package counsel)

(use-package swiper)

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
	 :map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done)
	 ("C-l" . ivy-alt-done)
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 :map ivy-switch-buffer-map
	 ("C-k" . ivy-previous-line)
	 ("C-l" . ivy-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-k" . ivy-previous-line)
	 ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

;; Add Line Numbering except in some instances
(column-number-mode)
(global-display-line-numbers-mode t)

; Disable line numbers for some modes like terminals
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

; Treat delimiters the same across all programming languages while in Emacs
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

; See functions made available after the initial keybinding was struck
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))


