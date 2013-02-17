;; jerkcity.el --- quote jerkcity comics

;; Copyright (C) 2010 Kyle Machulis/Nonpolynomial Labs

;; Author:  2010 Kyle Machulis
;; Maintainer: kyle@nonpolynomial.com
;; Keywords: dongs, games, also-dongs

;; Released under the WTF license.

;;            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
;;                  (http://sam.zoy.org/wtfpl/)
;;                    Version 2, December 2004

;; Everyone is permitted to copy and distribute verbatim or modified
;; copies of this license document, and changing it is allowed as long
;; as the name is changed.

;;            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
;;   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

;;  0. You just DO WHAT THE FUCK YOU WANT TO.

;; Commentary:

;; FUCKING SHUT UP


;; History:
;; 2013-02-16 - Pi <pi+git@pihost.us>
;; - Split out from jerkcity.el


(require 'jerkcity)
(defvar jerkcity-dialog-compressed-file
  (concat (expand-file-name temporary-file-directory) "jerkcity-dialog.xml.gz")
  "File containing jerkcity quotes, as fetched from server.")
(defvar jerkcity-dialog-url "http://www.jerkcity.com/dialog.xml.gz"
  "URL to fetch dialog from if it does not exist locally")

(defun jerkcity-insert-quote-into-file (quote)
  "Given a quote string, split out the reference. Quotes in the
  XML files are of the format

NAME: QUOTE

So just search for :  and split there.
"
  (save-excursion
    ;; Always assume we want a quote, so it'll start with :
    (when (string-match ":" quote)
      (progn
        (set-buffer (find-file-noselect jerkcity-dialog-file))
        (insert (cadr (split-string quote ": ")))
        (insert "\n%%\n")))))

(defun jerkcity-get-quotes ()
  "Retreive the latest quote file from the server, and parse it into cookie form."
  (interactive)
  (jerkcity-fetch-dialog)
  (jerkcity-create-quote-file))

(defun jerkcity-check-dialog-exists ()
  "See if the parsed cookie file exists. If not, prompt user for download."
  (if (not (file-exists-p jerkcity-dialog-file))
    (if (yes-or-no-p "Jerkcity dialog file not found. Download from server and parse (may block a smidge)?")
        (jerkcity-get-quotes)
      nil)
    t))

(defun jerkcity-fetch-dialog ()
  "Download file from website, save to intermediate file in local user-emacs-directory."
  (save-excursion
    (set-buffer (url-retrieve-synchronously jerkcity-dialog-url))
    ;; Remove HTTP headers. Thanks install-elisp.el!
    (goto-char (point-min))
    (re-search-forward "^$" nil 'move)
    (delete-region (point-min) (1+ (point)))
    (write-file jerkcity-dialog-compressed-file)
    (kill-buffer)
    (message "Jerkcity file retreived successfully")))

(defun jerkcity-create-quote-file ()
  "Create a cookie formatted quote file based on the XML
retrieved from the website. Doesn't actually parse XML 'cause I'm
too stupid to get xml.el to work."
  (save-excursion
    ;; Kill the old dialog file. Hope you weren't editing it.
    (when (find-buffer-visiting jerkcity-dialog-file)
      (progn
        (kill-buffer (find-file-noselect jerkcity-dialog-file))
        (if (file-exists-p jerkcity-dialog-file)
            (delete-file jerkcity-dialog-file))))
    (set-buffer (find-file-noselect jerkcity-dialog-file t))
    (with-auto-compression-mode
      (progn
        (set-buffer (find-file-noselect jerkcity-dialog-compressed-file))
        ;; Screw XML parsing, and I don't like dealing with elisp
        ;; regexps. We know where the dialog is. Get it stupidly.
        (goto-char (point-min))
        (while (search-forward "<dialog>\n" nil t)
          (let*
              ;; Find a dialog tag
              ((quote-start (point-marker))
               ;; Find the last tag, then back up
               (quote-end (progn
                            (search-forward "\n</dialog>")
                            (search-backward "\n</dialog>")
                            (point-marker)))
               (quote-strings (split-string (buffer-substring-no-properties quote-start quote-end) "\n")))
            (mapc 'jerkcity-insert-quote-into-file quote-strings)))))
    (set-buffer (find-file-noselect jerkcity-dialog-file))
    (save-buffer)
    (kill-buffer (find-file-noselect jerkcity-dialog-file))))
