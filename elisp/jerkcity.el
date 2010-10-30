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

;; After much talking on #emacs, it was decided between Chapeyev and I
;; (qDot) that there needed to be a modern equivilent to M-x yow. Not
;; that Zippy doesn't age well, but modern humor calls for less CELERY
;; and more DONGS and possibly some HBHBLHGBLHBLHGBLH.

;; In an effort to use someone else's work on this, we parse out the
;; quotes from the XML file available from the jerkcity site. This
;; means that as long as they don't update the schema or do something
;; that breaks our really stupid parsing mechanism, we don't have to
;; upgrade the script.

;; The script also includes an erc /jerkcity command. It will take
;; either a nick, or will read out the query buffer name, which we
;; assume is either the channel or PRIVMSG name. Have fun with that.

;; Much of this code ripped straight out of yow. Hey, it worked for
;; them, why not for us. Code slutting 'swhat emacs is all about.

;; Requires emacs >= 23 because fuck you what year does this look like
;; anyways.

;; Note that by order of http://www.jerkcity.com/jerkcity2341.html, I
;; am now considered to be THE KING (assuming you global-set-key
;; jerkcity to something.)

;; History:

;; 2010-10-28 - Kyle Machulis <kyle@nonpolynomial.com>
;; - Got Food Poisoning
;; - Decided to make myself feel better by doing stupid elisp tricks

(require 'cookie1)

(defgroup jerkcity nil
  "Dongs, Bongs, and Jerkcity Settings. Mostly dongs."
  :group 'games)

(defcustom jerkcity-dialog-compressed-file (concat (expand-file-name user-emacs-directory) "jerkcity-dialog.xml.gz")
  "File containing jerkcity quotes, as fetched from server."
  :type 'file
  :group 'jerkcity)

(defcustom jerkcity-dialog-file (concat (expand-file-name user-emacs-directory) "jerkcity-dialog.txt")
  "File containing jerkcity quotes, as parsed into cookie readable form."
  :type 'file
  :group 'jerkcity)

(defcustom jerkcity-dialog-url "http://www.jerkcity.com/dialog.xml.gz"
  "URL to fetch dialog from if it does not exist locally"
  :type 'url
  :group 'jerkcity)

(defconst jerkcity-character-names (list "DEUCE" "ATANDT" "SPIGOT" "PANTS" "RANDS" "NET") "Names of characters in the quote file, for replacement")
(defconst jerkcity-load-message "Dongsing..." "Message to show when cookie is parsing file (rarely happens on moderns machines.)")
(defconst jerkcity-after-load-message "Dongsing complete. Emacs now donged. HGBHGBLBG at will."  "Message to show when cookie is finished parsing file.")

(defun jerkcity-get-quotes()
  "Retreive the latest quote file from the server, and parse it into cookie form."
  (interactive)
  (jerkcity-fetch-dialog)
  (jerkcity-create-quote-file)
  )

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

(defun jerkcity-insert-quote-into-file (quote)
  "Given a quote string, split out the reference. Quotes in the
  XML files are of the format

NAME: QUOTE

So just search for :  and split there.
"
  (save-excursion
    ;; Always assume we want a quote, so it'll start with :
    (if (string-match ":" quote)
        (progn
          (set-buffer (find-file-noselect jerkcity-dialog-file))
          (insert (cadr (split-string quote ": ")))
          (insert "\n%%\n")))))

(defun jerkcity-create-quote-file ()
  "Create a cookie formatted quote file based on the XML
retrieved from the website. Doesn't actually parse XML 'cause I'm
too stupid to get xml.el to work."
  (save-excursion
    ;; Kill the old dialog file. Hope you weren't editing it.
    (if (find-buffer-visiting jerkcity-dialog-file)
        (progn
          (kill-buffer (find-file-noselect jerkcity-dialog-file))
          (if (file-exists-p jerkcity-dialog-file)
              (delete-file jerkcity-dialog-file))
          ))
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
                            (point-marker)
                            ))
               (quote-strings (split-string (buffer-substring-no-properties quote-start quote-end) "\n")))
            (mapc 'jerkcity-insert-quote-into-file quote-strings)))))
        (set-buffer (find-file-noselect jerkcity-dialog-file))
        (save-buffer)
        (kill-buffer (find-file-noselect jerkcity-dialog-file))))

(defun jerkcity-retrieve-quote ()
  "Get a single random jerkcity quote out of the cookie file"
  (cookie jerkcity-dialog-file jerkcity-load-message jerkcity-after-load-message))

(defun jerkcity ()
  "Display a single random jerkcity quote in the minibuffer"
  (interactive)
  (if (jerkcity-check-dialog-exists)
      (message (jerkcity-retrieve-quote))))

(defun jerkcity-insert ()
  "Insert a single random jerkcity quote in the current buffer"
  (interactive)
  (if (jerkcity-check-dialog-exists)
      (insert (jerkcity-retrieve-quote))))

(defun jerkcity-find-random-quote(match-regexp)
  "Given a regexp, fuck up the cookie vector then kick it until
it spits out something that applies. Yeah. You showed it. You
showed it /good/."
  (let
      ((cookie-vector (cookie-snarf jerkcity-dialog-file jerkcity-load-message jerkcity-after-load-message)))
    (shuffle-vector cookie-vector)
    (let 
        ((jerkcity-matched-quotes (delq nil (mapcar (lambda (x) (and (string-match match-regexp x) x)) cookie-vector))))
      (nth (random (length jerkcity-matched-quotes)) jerkcity-matched-quotes))
    ))

(defun jerkcity-character-subst (nick)
  "Return a random string in which a character reference of the format 

T NAME

is used. Pick NAME at random from the jerkcity-character-names
list. Replace name with uppercased argument."
       (let*
           ((jerkcity-name (nth (random (length jerkcity-character-names)) jerkcity-character-names))
            (jerkcity-t-string (format "T %s" jerkcity-name))
            (jerkcity-character-quote (jerkcity-find-random-quote jerkcity-t-string))
            )
         (replace-regexp-in-string jerkcity-name (upcase nick) jerkcity-character-quote)))

(defun erc-cmd-JERKCITY ()
  "Print a random quote to a ERC query buffer"
  (if (jerkcity-check-dialog-exists)      
        (erc-send-message (jerkcity-retrieve-quote))))

(defun erc-cmd-JERKCITYALSO ()
  "Print a random quote starting with ALSO to a ERC query buffer"
  (if (jerkcity-check-dialog-exists)      
        (erc-send-message (jerkcity-find-random-quote "^ALSO"))))

(defun erc-cmd-JERKCITYQUERY (&optional nick)
  "Print a random character quote to a ERC query buffer, with the
character name replaced with the buffer name or requested nick"
  (if (jerkcity-check-dialog-exists)      
      (if nick
          (erc-send-message (jerkcity-character-subst nick))
        (erc-send-message (jerkcity-character-subst (buffer-name (current-buffer)))))))

(provide 'jerkcity)