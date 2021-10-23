#lang info

(define drracket-tools '(("tool.rkt")))
(define drracket-tool-names (list "cloud-backup-client"))
(define drracket-tool-icons `("icon.png"))
(define primary-file "tool.rkt")

(define collection "cloud-backup-client")
(define deps '("base" "gui-lib" "data-lib" "drracket-plugin-lib" "net"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define pkg-desc "DrRacket plugin to send code to a web server for backups")
(define version "0.0.1")
(define pkg-authors '(jung.ry@northeastern.edu))

