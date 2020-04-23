;;; sxhkd-mode.el --- A mode for editing sxhkdrc -*- lexical-binding: t; -*-

;; Copyright (C) 2019

;; Author: xFA25E
;; Keywords: extensions

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; A major mode for editing sxhkdrc
;; Set up like this:

;; (add-to-list 'auto-mode-alist `(,(rx "sxhkdrc" string-end) . sxhkd-mode))

;; This mode also can reload your config after save.
;; Customize `sxhkd-mode-reload-config' for this

;;; Code:

(require 'array)

(defgroup sxhkd-mode nil
  "Mode for editing sxhkd configuration files."
  :group 'data)

(defcustom sxhkd-mode-reload-config 'ask
  "Should `sxhkd-mode' reload config after save?
Can be always, ask or never"
  :type '(radio (symbol :tag always)
                (symbol :tag ask)
                (symbol :tag never))
  :group 'sxhkd-mode)

(defvar sxhkd-mode-keywords
  '("super" "hyper" "meta" "alt" "control" "ctrl" "shift" "mode_switch" "lock"
    "mod1" "mod2" "mod3" "mod4" "mod5" "any" "button1" "button2" "button3"
    "button4" "button5" "button6" "button7" "button8" "button9" "button10"
    "button11" "button12" "button13" "button14" "button15" "button16" "button17"
    "button18" "button19" "button20" "button21" "button22" "button23"
    "button24")
  "Sxhkd keywords.")

(defvar sxhkd-mode-font-lock-defaults
  `(;; comments
    (,(rx bol "#" (*? nonl) eol) . font-lock-comment-face)

    ;; synchronous commands
    (,(rx bol (+ space) (group ";")) . (1 font-lock-variable-name-face))

    ;; end backslash
    (,(rx bol (not (in "#")) (*? nonl) (group "\\") eol)
     . (1 font-lock-constant-face))

    ;; brackets
    (,(rx (or "{" "}")) . font-lock-type-face)

    ;; keywords
    (,(regexp-opt sxhkd-mode-keywords) . font-lock-keyword-face)

    ;; disallowed comments
    (,(rx bol (not (in space "#")) (*? nonl) (group "#" (*? nonl)) eol)
     . (1 font-lock-warning-face)))
  "`sxhkd-mode' font lock defaults.")

;; TODO: use emacs built-in way to find sxhkd pid for signal-process
(defun sxhkd-mode-reload-config ()
  "Reload sxhkd config."
  (when (cl-ecase sxhkd-mode-reload-config
          ((always) t)
          ((never) nil)
          ((ask) (yes-or-no-p "Reload config?")))
    (call-process "pkill" nil 0 nil "-USR1" "--exact" "sxhkd")))

(defun sxhkd-mode-completion-at-point ()
  "This is the function used for the hook `completion-at-point-functions'."
  (interactive)
  (let* ((bounds (bounds-of-thing-at-point 'symbol))
         (start (car bounds))
         (end (cdr bounds)))
    (list start end sxhkd-mode-keywords)))

(defun sxhkd-mode-indent-line ()
  "Indentation function for `sxhkd-mode'."
  (indent-line-to (sxhkd-mode-indentation-length)))

(defun sxhkd-mode-indentation-length ()
  "Determine indentation length of current line."
  (save-excursion
    (if (zerop (current-line))
        0
      ;; go up, until end of comment or beginning of buffer
      (beginning-of-line 0)
      (while (and (looking-at-p (rx "#")) (not (bobp)))
        (beginning-of-line 0))
      ;; previous line is comment or empty line
      (if (looking-at-p (rx (or "#" (and bol eol))))
          0
        (end-of-line)
        (forward-char -1)
        (if (looking-at-p (rx "\\")) 0 1)))))

;;;###autoload
(define-derived-mode sxhkd-mode fundamental-mode "Sxhkd"
  "A major mode for editing sxhkdrc."
  (setq-local font-lock-defaults '(sxhkd-mode-font-lock-defaults))
  (setq-local comment-start "# ")
  (setq-local comment-end "")
  (setq-local indent-line-function #'sxhkd-mode-indent-line)
  (add-hook 'after-save-hook #'sxhkd-mode-reload-config nil t)
  (add-hook 'completion-at-point-functions
            #'sxhkd-mode-completion-at-point nil t))

(provide 'sxhkd-mode)

;;; sxhkd-mode.el ends here
