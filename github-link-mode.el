;;; github-link-mode.el --- Github-link minor mode

;; Copyright (C) 2024 rafapaezbas

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;;; Commentary:

;; Github-link-mode provides keybindings to generate a github url from
;; the current region and copies the link to the clipboard

;; Usage:

;; C-c g l: `github-link-line': Copy region/line github url to clipboard
;; C-c g f: `github-link-file': Copy file github file url to clipboard

;;; Code:

(require 'projectile)

(defun github-link-trim-shell-command (cmd)
  "Trim command CMD output."
  (string-trim (shell-command-to-string cmd)))

(defun github-link-line ()
  "Copy remote repository line url to clipboard."
  (interactive)
  (let* ((path (file-relative-name (buffer-file-name) (projectile-project-root)))
         (url (github-link-trim-shell-command "git config --get remote.origin.url"))
         (branch (github-link-trim-shell-command "git branch --show-current"))
         (start-line (count-lines 1 (if mark-active (region-beginning) (point))))
         (end-line (count-lines 1 (region-end)))
         (needs-offset (or (eql (char-before (region-beginning)) 10) (eql (region-beginning) 1))) ; if prev char is new line or nothing
         (offset (if needs-offset 1 0))
         (location (concat url "/blob/" branch "/" path))
         (multi-line (concat location "#L" (number-to-string (+ start-line offset)) "-L" (number-to-string end-line)))
         (single-line (concat location  "#L" (number-to-string (+ start-line offset))))
         (result (if mark-active multi-line single-line)))
    (message (concat "Copied to clipboard: " (kill-new result))))) ; kill-new copies value to clipboard and returns it, message prints in buffer

(defun github-link-file ()
  "Copy remote repository file url to clipboard."
  (interactive)
  (let* ((path (file-relative-name (buffer-file-name) (projectile-project-root)))
         (url (github-link-trim-shell-command "git config --get remote.origin.url"))
         (branch (github-link-trim-shell-command "git branch --show-current"))
         (result (concat url "/blob/" branch "/" path)))
    (message (concat "Copied to clipboard: " (kill-new result)))))

(defvar github-link-mode-map
  (make-sparse-keymap)
  "Keymap for github-link-mode.")

(define-minor-mode github-link-mode
  "Minor mode for translating highlighted region to github url."
  :lighter " Github link Mode"
  :keymap github-link-mode-map)

(define-key github-link-mode-map (kbd "C-c g l") #'github-link-line)
(define-key github-link-mode-map (kbd "C-k") #'github-link-file)

(add-hook 'projectile-after-switch-project-hook #'(lambda ()
                                                    "Enable mode if project root/.github exists or disable."
                                                    (let* ((github-folder (expand-file-name ".github" (projectile-project-root)))
                                                           (is-github-project (file-directory-p github-folder)))
                                                      (if is-github-project (github-link-mode t) (github-link-mode 0)))))


(provide 'github-link-mode)
;;; github-link-mode.el ends here
