;; jerkcity-erc.el --- quote jerkcity comics into ERC

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
;; Some commands to SPURT AND HURR ALL OVER YOUR FUCKING ERC BUFFERS

;; History:

;; 2013-02-14 - Pi <pi+git@pihost.us>
;; - Ripped out of jerkcity.el without change.

(defun erc-cmd-JERKCITY ()
  "Print a random quote to a ERC query buffer"
  (when (jerkcity-check-dialog-exists)
    (erc-send-message (jerkcity-retrieve-quote))))

(defun erc-cmd-JERKCITYALSO ()
  "Print a random quote starting with ALSO to a ERC query buffer"
  (when (jerkcity-check-dialog-exists)
    (erc-send-message (jerkcity-find-random-quote "^ALSO"))))

(defun erc-cmd-JERKCITYQUERY (&optional nick)
  "Print a random character quote to a ERC query buffer, with the
character name replaced with the buffer name or requested nick"
  (when (jerkcity-check-dialog-exists)
    (if nick
        (erc-send-message (jerkcity-character-subst nick))
      (erc-send-message (jerkcity-character-subst (buffer-name (current-buffer)))))))

(provide 'jerkcity-erc)