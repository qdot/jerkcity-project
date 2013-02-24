;; jerkcity-circe.el --- quote jerkcity comics into Circe
;; (the loveliest of all IRC clients)

;; Copyright (C) 2013 Pi

;; Author: Pi
;; Maintainer: pi+jerkcity@pihost.us
;; Keywords: irc, dongs, games, also-cocks

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
;; Some commands to SPURT AND HURR ALL OVER YOUR FUCKING CIRCE BUFFERS

;; History:

;; 2013-02-23 - Pi
;; - Made Green Dragon, decided to work on Jerkcity stuff.

(defun circe-command-JERK (&optional ignored)
  "Send a random quote to Circe's current target"
  (circe-command-SAY (jerkcity-retrieve-quote)))

(defun circe-command-JERKALSO (&optional ignored)
  "Send a random quote starting with ALSO to Circe's current target"
  (circe-command-SAY (jerkcity-find-random-quote "^ALSO")))

(defun circe-command-JERKNAME (&optional nick)
  "Send a random Jerkcity character's quote to a Circe query buffer,
with their name replaced with the target, or requested nick"
  (if (not circe-chat-target)
      (circe-server-message "No target for current buffer")
    (if nick
        (circe-command-SAY (jerkcity-character-subst nick))
      (circe-command-SAY (jerkcity-character-subst circe-chat-target)))))

(provide 'jerkcity-circe)
