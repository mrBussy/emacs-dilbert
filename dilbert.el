;;; dilbert.el --- Display a Dilbert                 -*- lexical-binding: t; -*-

;; Copyright (C) 2022  R. Middel

;; Author: R. Middel <r.middel@mrbussy.eu>
;; Keywords: lisp, multimedia
;; Version: 1.0.0

;; MIT License

;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:

;;;; TODO:
;;;; - Add key bindings for next, previous and quit
;;;; - get the title from the ALT text and add as title
;;;; - make a package ou tof this

;; Loosly based on https://github.com/vibhavp/emacs-xkcd/blob/master/xkcd.el

(require 'org)
(require 'image)

;;;; CODE:

;;;###autoload
(define-derived-mode dilbert-mode special-mode "dilbert"
  "Major mode for viewing dilbert (https://dilbert.com/)."
  :group 'dilbert)

(define-key dilbert-mode-map (kbd "q") 'dilbert-kill-buffer)
(define-key dilbert-mode-map (kbd "s") 'dilbert-get-for-date)

(defvar dilbert-site "https://dilbert.com")

(defgroup dilbert nil
  "A dilbert reader for Emacs."
  :group 'multimedia)

(defcustom dilbert-cache-dir (let ((dir (concat user-emacs-directory "dilbert/")))
                               (make-directory dir :parents)
                               dir)
  "Directory to cache images to."
  :group 'dilbert
  :type 'directory)


(defcustom dilbert-cache-latest (concat dilbert-cache-dir "latest.gif")
  "File to store the latest cached dilbert in.
Should preferably be located in `dilbert-cache-dir'."
  :group 'dilbert
  :type 'file)


(defun dilbert-get-latest ()
  "Open the latest dilbert."
  (interactive)
  (let ((dilbert-asset-url (dilbert--retrieve-asset-url dilbert-site)))
    (dilbert--download-and-show dilbert-asset-url dilbert-cache-latest)
    ))

(defun dilbert-get-for-date (dilbert-date-p)
  "Open a dilbert for date 'YYYY-mm-dd' represented by DILBERT-DATE-P."
  (interactive "sEnter a date (YYYY-mm-dd):")

  (let ((dilbert-strip-url (format "%s/strip/%s" dilbert-site dilbert-date-p))
	(dilbert-asset-file  (format "%s/%s.gif" dilbert-cache-dir dilbert-date-p)))

    (message "for date: %s (%s; %s)" dilbert-date-p dilbert-strip-url dilbert-asset-file)
    (let ((dilbert-asset-url (dilbert--retrieve-asset-url dilbert-strip-url)))
      (dilbert--download-and-show dilbert-asset-url dilbert-asset-file)
      )
    )
  )

(defun dilbert--retrieve-asset-url (url-p)
  "Internal function to retrieve the dilbert page URL-P."
  (message "Downloading date: %s" url-p)
  (with-temp-buffer
    (url-insert-file-contents url-p)
    ;; get the url to the actual image
    (re-search-forward "\\(https://assets.amuniversal.com/[a-f0-9]+\\)" )
    (match-string 1)
    )
  )

(defun dilbert--download-and-show (url-p filename-p)
  "Internal function to download the image and show it on screen.

   The image will be downloaded from URL-P and stored as FILENAME-P.
   After downloading the image will be put into the buffer *dilbert*"

  (url-copy-file url-p filename-p t)

  (get-buffer-create "*dilbert*")
  (switch-to-buffer "*dilbert*")
  (dilbert-mode)
  (let ((buffer-read-only)
	(title filename-p))
    (erase-buffer)
    (insert (propertize title
			'face '(:weight bold :size 110)))
    (center-line)
    (insert "\n")
    (insert-image (create-image filename-p))
    )
)

(defun dilbert-kill-buffer ()
  "Kill the dilbert buffer with ARG."
  (interactive)
  (kill-buffer "*dilbert*"))

(provide 'dilbert)
;;; dilbert.el ends here
