#lang racket/base
(require racket/list
	 web-server/http
         web-server/servlet-env
         web-server/dispatch
	 json)

#|
Run the web server and save this file (cmd/ctrl + S). If the plugin is working correctly you should
see the contents of the file sent by the client.
|#

(define-values (route _)
  (dispatch-rules
   [("") #:method "post" (λ (req)
                           (displayln "---- Server successfully received data! ----")
                           (displayln req)
                           (displayln "--------------------------------------------")
                           (response
                            201 #"Created"
                            (current-seconds) #f
                            empty
                            void))]))

(module+ main
  (serve/servlet
   route
   #:port 5000
   #:command-line? #t
   #:servlet-regexp #rx""))

