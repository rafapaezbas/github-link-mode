;;; github-pointer-mode.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2024 rafapaezbas
;;
;; Author: rafapaezbas
;; Maintainer: rafapaezbas
;; Created: septiembre 02, 2024
;; Modified: septiembre 02, 2024
;; Version: 0.0.1
;; Homepage: https://github.com/rafapaezbas/github-pointer-mode
;; Package-Requires: ((emacs "24.4"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Github-pointer-mode provides keybinding to copy a github url to clipboard
;;
;; C-c g l: `github-pointer-line': Copy region/line github url to clipboard
;;
;; C-c g f: `github-pointer-file': Copy file github file url to clipboard
;;
;;  Description
;;
;;  Copy github url to clipboard from highlighted region of buffer
;;
;;; Code:

(require 'projectile)

(defun github-pointer-trim-shell-command (cmd)
  (string-trim (shell-command-to-string cmd)))

(defun github-pointer-line ()
  "copy remote repository line url to clipboard"
  (interactive)
  (let* ((path (file-relative-name (buffer-file-name) (projectile-project-root)))
         (url (github-pointer-trim-shell-command "git config --get remote.origin.url"))
         (branch (github-pointer-trim-shell-command "git branch --show-current"))
         (start-line (count-lines 1 (if mark-active (region-beginning) (point))))
         (end-line (count-lines 1 (region-end)))
         (needs-offset (or (eql (char-before (region-beginning)) 10) (eql (region-beginning) 1))) ; if prev char is new line or nothing
         (offset (if needs-offset 1 0))
         (location (concat url "/blob/" branch "/" path))
         (multi-line (concat location "#L" (number-to-string (+ start-line offset)) "-L" (number-to-string end-line)))
         (single-line (concat location  "#L" (number-to-string (+ start-line offset))))
         (result (if mark-active multi-line single-line)))
    (message (concat "Copied to clipboard: " (kill-new result))))) ; kill-new copies value to clipboard and returns it, message prints in buffer

(defun github-pointer-file ()
  "copy remote repository file url to clipboard"
  (interactive)
  (let* ((path (file-relative-name (buffer-file-name) (projectile-project-root)))
         (url (github-pointer-trim-shell-command "git config --get remote.origin.url"))
         (branch (github-pointer-trim-shell-command "git branch --show-current"))
         (result (concat url "/blob/" branch "/" path)))
    (message (concat "Copied to clipboard: " (kill-new result)))))

(defvar github-pointer-mode-map
  (make-sparse-keymap)
  "Keymap for github-pointer-mode.")

(define-minor-mode github-pointer-mode
  "Minor mode for translating highlighted region to github url."
  :lighter " Github Pointer Mode"
  :keymap github-pointer-mode-map)

(define-key github-pointer-mode-map (kbd "C-c g l") #'github-pointer-line)
(define-key github-pointer-mode-map (kbd "C-k") #'github-pointer-file)

(provide 'github-pointer-mode)
;;; github-pointer-mode.el ends here
