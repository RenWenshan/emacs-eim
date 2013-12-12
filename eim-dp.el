;; -*- coding: utf-8 -*-
;;; eim-dp.el --- Emacs Chinese Double Pinyin input method (双拼输入法) for eim

;; Copyright 2013 任文山 （Ren Wenshan）
;;
;; Author: renws1990@gmail.com
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Features:
;;; - 提供双拼－微软方案

;;; Commentary:

;;;_* Code:

(eval-when-compile
  (require 'cl))

(require 'eim-table)

(defgroup eim-dp nil
  "eim wubi input method"
  :group 'eim)

(defcustom eim-dp-history-file "~/.emacs.d/dp-history"
  "保存选择的历史记录"
  :type 'file
  :group 'eim-dp)

(defcustom eim-dp-user-file "mydp.txt"
  "保存用户自造词"
  :type 'file
  :group 'eim-dp)

(defcustom eim-dp-save-always nil
  "是否每次加入新词都要保存。
当然设置为 nil，也会在退出 emacs 里保存一下的。"
  :type 'boolean
  :group 'eim-dp)

(defcustom eim-dp-add-all-completion-limit 1
  "在超过输入字符串超过这个长度时会添加所有补全。"
  :type 'integer
  :group 'eim-dp)

(defvar eim-dp-load-hook nil)
(defvar eim-dp-package nil)
(defvar eim-dp-char-table (make-vector 1511 0))
(defvar eim-dp-punctuation-list nil
  "标点符号转换表，见 dp.txt 中 [Punctuation] 一节")
(defvar eim-dp-initialized nil)

(defun eim-dp-create-word (word)
  "Insert word to database and write into user file"
  (let ((len (length word))
        code)
    (setq code
     (cond
      ((= len 2)
       (concat (substring (eim-table-get-char-code (aref word 0)) 0 2)
               (substring (eim-table-get-char-code (aref word 1)) 0 2)))
      ((= len 3)
       (concat (substring (eim-table-get-char-code (aref word 0)) 0 1)
               (substring (eim-table-get-char-code (aref word 1)) 0 1)
               (substring (eim-table-get-char-code (aref word 2)) 0 2)))
      (t
       (concat (substring (eim-table-get-char-code (aref word 0)) 0 1)
               (substring (eim-table-get-char-code (aref word 1)) 0 1)
               (substring (eim-table-get-char-code (aref word 2)) 0 1)
               (substring (eim-table-get-char-code (aref word (1- (length word)))) 0 1)))))))

;;;_. load it
(unless eim-dp-initialized
  (setq eim-dp-package eim-current-package)
  (setq eim-dp-punctuation-list
        (eim-read-punctuation eim-dp-package))
  (let ((map (eim-mode-map)))
    (define-key map "\t" 'eim-table-show-completion)
  (let ((path (file-name-directory load-file-name)))
    (load (concat path "eim-dp-chars")))

  (eim-table-add-user-file eim-dp-user-file)
  (eim-table-load-history eim-dp-history-file)
  (run-hooks 'eim-dp-load-hook)
  (eim-set-option 'table-create-word-function 'eim-dp-create-word)
  (eim-set-option 'punctuation-list 'eim-dp-punctuation-list)
  (eim-set-option 'max-length 9)
  (eim-set-option 'all-completion-limit eim-dp-add-all-completion-limit)
  (eim-set-option 'char-table eim-dp-char-table)
  (eim-set-active-function 'eim-table-active-function)
  (setq eim-dp-initialized t)))
(provide 'eim-dp)
;;; eim-dp.el ends here
