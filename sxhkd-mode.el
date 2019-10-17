;;; sxhkd-mode.el --- A mode for editing sxhkdrc, sxhkd configuration file  -*- lexical-binding: t; -*-

;; Copyright (C) 2019

;; Author:  <>
;; Keywords:extensions

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

;; Not yet ready

;;; Code:

;; CONFIGURATION
;;        Each line of the configuration file is interpreted as so:

;;        •   If it is empty or starts with #, it is ignored.

;;        •   If it starts with a space, it is read as a command.

;;        •   Otherwise, it is read as a hotkey.

;;        General syntax:

;;            HOTKEY
;;                [;]COMMAND

;;            HOTKEY      := CHORD_1 ; CHORD_2 ; ... ; CHORD_n
;;            CHORD_i     := [MODIFIERS_i +] [~][@]KEYSYM_i
;;            MODIFIERS_i := MODIFIER_i1 + MODIFIER_i2 + ... + MODIFIER_ik

;;        The valid modifier names are: super, hyper, meta, alt, control, ctrl, shift,
;;        mode_switch, lock, mod1, mod2, mod3, mod4, mod5 and any.

;;        The keysym names are given by the output of xev.

;;        Hotkeys and commands can be spread across multiple lines by ending each partial line
;;        with a backslash character.

;;        When multiple chords are separated by semicolons, the hotkey is a chord chain: the
;;        command will only be executed after receiving each chord of the chain in consecutive
;;        order.

;;        The colon character can be used instead of the semicolon to indicate that the chord
;;        chain shall not be aborted when the chain tail is reached.

;;        If a command starts with a semicolon, it will be executed synchronously, otherwise
;;        asynchronously.

;;        The Escape key can be used to abort a chord chain.

;;        If @ is added at the beginning of the keysym, the command will be run on key release
;;        events, otherwise on key press events.

;;        If ~ is added at the beginning of the keysym, the captured event will be replayed for
;;        the other clients.

;;        Pointer hotkeys can be defined by using one of the following special keysym names:
;;        button1, button2, button3, ..., button24.

;;        The hotkey and the command may contain sequences of the form {STRING_1,...,STRING_N}.

;;        In addition, the sequences can contain ranges of the form A-Z where A and Z are
;;        alphanumeric characters.

;;        The underscore character represents an empty sequence element.

(defvar sxhkd-mode-map
  (let ((map (make-sparse-keymap)))
    ;; (define-key map [foo] 'sample-do-foo)
    map)
  "Keymap for `sxhkd-mode'.")

(defvar sxhkd-font-lock-keywords
  `(;; ("function \\(\\sw+\\)" (1 font-lock-function-name-face))
    (,(regexp-opt '("super" "hyper" "meta" "alt" "control" "ctrl"
                    "shift" "mode_switch" "lock" "mod1" "mod2" "mod3"
                    "mod4" "mod5" "any")
                  'symbols)
     font-lock-keyword-face))
  "Keyword highlighting specification for `sxhkd-mode'.")

(defvar sxhkd-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?# "< 1" st)
    (modify-syntax-entry ?\n "> " st)
    st)
  "Syntax table for `sxhkd-mode'.")

(defun sxhkd-indent-line ()
  "Indent current line as sxhkdrc config."
  (interactive)
  (if (bobp) (indent-line-to 0)))

;; (defun apply-sxhkd-mode-syntax-table (beg end)
;;   (save-excursion
;;     (save-restriction
;;       (widen)
;;       (goto-char beg)
;;       ;; for every line between points BEG and END
;;       (while (and (not (eobp)) (< (point) end))
;;         (beginning-of-line)
;;         (when (looking-at "^#")
;;           ;; remove current syntax-table property
;;           (remove-text-properties (1- (line-beginning-position))
;;                                   (1+ (line-end-position))
;;                                   '(syntax-table))
;;           ;; set syntax-table property to our custom one
;;           ;; for the whole line including the beginning and ending newlines
;;           (add-text-properties (1- (line-beginning-position))
;;                                (1+ (line-end-position))
;;                                (list 'syntax-table sxhkd-mode-syntax-table)))
;;         (forward-line 1)))))

(defun sxhkd-comment-dwim ()
  "Disable creating comments after non comment line.
Create region containing current line if there is no active region."
  (interactive)
  (save-excursion
    (unless (use-region-p)
      (end-of-line)
      (push-mark (line-beginning-position))
      (setq mark-active t))
    (comment-dwim nil)))

(defun sxhkd-reload ()
  "Reload sxhkd."
  ;TODO: maybe use proced functions to send signols
  (shell-command "pkill -USR1 --exact sxhkd"))

;;;###autoload
(define-derived-mode sxhkd-mode fundamental-mode "Sxhkd"
  "A major mode for editing sxhkdrc."
  :syntax-table sxhkd-mode-syntax-table
  ;; :syntax-table (make-syntax-table)
  (setq-local comment-start "#")
  (setq-local comment-end "")
  (setq-local comment-column 0)
  (setq-local comment-style 'multi-line)
  ;; (setq syntax-propertize-function 'apply-sxhkd-mode-syntax-table)
  (setq-local font-lock-defaults
              '(sxhkd-font-lock-keywords))
  (setq-local indent-line-function #'sxhkd-indent-line)
  (local-set-key [remap comment-dwim] #'sxhkd-comment-dwim)
  (add-hook 'after-save-hook #'sxhkd-reload nil t))

(provide 'sxhkd-mode)

;; see ledger-mode for inspiration

;;; sxhkd-mode.el ends here
