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
;; 2013-02-16 - Pi <pi+git@pihost.us>
;; - Split into pieces
;; 2010-10-28 - Kyle Machulis <kyle@nonpolynomial.com>
;; - Got Food Poisoning
;; - Decided to make myself feel better by doing stupid elisp tricks

(require 'cookie1)

(defgroup jerkcity nil
  "Dongs, Bongs, and Jerkcity Settings. Mostly dongs."
  :group 'games)

(defcustom jerkcity-dialog-file
  (concat (expand-file-name user-emacs-directory) "jerkcity.lines")
  "File containing jerkcity quotes, as parsed into cookie readable form."
  :type 'file
  :group 'jerkcity)

(defcustom jerkcity-character-names
  (list "DEUCE" "ATANDT" "SPIGOT" "PANTS" "RANDS" "NET")
  "Names of characters in the quote file, for replacement"
  :type '(repeat string)
  :group 'jerkcity)

(defconst jerkcity-load-message "Dongsing..."
  "Message to show when cookie is parsing file.")
(defconst jerkcity-after-load-message "complete. HGBHGBLBG at will."
  "Message to show when cookie is finished parsing file.")

(defun jerkcity-retrieve-quote ()
  "Get a single random jerkcity quote out of the cookie file"
  (cookie jerkcity-dialog-file
          jerkcity-load-message jerkcity-after-load-message))

(defun jerkcity ()
  "Display a single random jerkcity quote in the minibuffer"
  (interactive)
  (when (jerkcity-check-dialog-exists)
    (message (jerkcity-retrieve-quote))))

(defun jerkcity-insert ()
  "Insert a single random jerkcity quote in the current buffer"
  (interactive)
  (when (jerkcity-check-dialog-exists)
    (insert (jerkcity-retrieve-quote))))

(defun jerkcity-find-random-quote (match-regexp)
  "Given a regexp, fuck up the cookie vector then kick it until
it spits out something that applies. Yeah. You showed it. You
showed it /good/."
  (let
      ((cookie-vector
        (cookie-snarf jerkcity-dialog-file
                      jerkcity-load-message jerkcity-after-load-message)))
    (shuffle-vector cookie-vector)
    (let
        ((jerkcity-matched-quotes
          (delq nil (mapcar (lambda (x) (and (string-match match-regexp x) x))
                            cookie-vector))))
      (nth (random (length jerkcity-matched-quotes))
           jerkcity-matched-quotes))))

(defun jerkcity-character-subst (nick)
  "Return a random string in which a character reference of the format

T NAME

is used. Pick NAME at random from the jerkcity-character-names
list. Replace name with uppercased argument."
  (let*
      ((jerkcity-name (nth (random (length jerkcity-character-names))
                           jerkcity-character-names))
       (jerkcity-t-string (format "T %s" jerkcity-name))
       (jerkcity-character-quote
        (jerkcity-find-random-quote jerkcity-t-string)))
    (replace-regexp-in-string jerkcity-name (upcase nick)
                              jerkcity-character-quote)))

(defun psychoanalyze-jerkcity ()
  "T FREUD MY TRAIN SPURTED INTO THE TUNNEL DOES THIS MEAN I'M GAY"
  (interactive)
  (doctor)
  (message "")
  (switch-to-buffer "*doctor*")
  (sit-for 0)
  (while (not (input-pending-p))
    (jerkcity-insert)
    (sit-for 0)
    (doctor-ret-or-read 1)
    (doctor-ret-or-read 1)))

(provide 'jerkcity)
