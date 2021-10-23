#lang racket/base
(require drracket/tool
         racket/class
         racket/contract
         racket/unit
         framework
         net/http-client
         json
         rackunit)

;; The domain name of the webserver to receive editor content
(define HOST "localhost")
(define PORT 5000)
;; The slug of the URI that represents the specific endpoint that recieves requests
(define ENDPOINT "/")

;; The number of "changes" required before backing up the editor content
;; Where a "change" is defined as anything that will cause a visual change to the editor: 
;; docs: https://docs.racket-lang.org/gui/editor___.html#%28meth._%28%28%28lib._mred%2Fmain..rkt%29._editor~3c~25~3e%29._on-change%29%29
(define CHANGES-BEFORE-SAVE-THRESHOLD 250)


;; make-cloud-backup-plugin : [String -> Void] -> Unit
;; produces a DrRacket plugin that invokes `send-content` to send the text stored in the file:
;; - every `CHANGES-BEFORE-SAVE=THRESHOLD` changes since the last save,
;; - on every file save event (including auto-saves and manual saves),
;; - on every close tab/window event.

(define (make-cloud-backup-plugin send-content)
  (make-plugin:extend-definitions-text
   (mixin (text:file<%>) ()
     (super-new)
     (inherit get-text)
     (field (changes-since-last-save 0)) ; Nat
    
     (define/augment (on-change)
       (set! changes-since-last-save (add1 changes-since-last-save))
       (when (>= changes-since-last-save CHANGES-BEFORE-SAVE-THRESHOLD)
           (send-content (get-text))
           (set! changes-since-last-save 0)))
          
     (define/augment (on-save-file _filename _format)
       (send-content (get-text))
       (set! changes-since-last-save 0))

     (define/augment (on-close)
       (send-content (get-text))
       (set! changes-since-last-save 0)))))

;; make-plugin:extend-definitions-text : [Mixin text:file<%>] -> Unit
;; builds a DrRacket plugin (tool) that overrides the behavior of the definitions window text.

(define (make-plugin:extend-definitions-text defs-text-mixin)
  (unit
      (import drracket:tool^)
      (export drracket:tool-exports^)
      (define (phase1) (void))
      (define (phase2) (void))
      (drracket:get/extend:extend-definitions-text defs-text-mixin)))

;; upload-to-cloud : String -> Thread
;; sends an HTTP request containing the editor text content and relevant metadata
;; produces the worker thread that makes the request to the server
;; does nothing if the request is unsuccessful
(define/contract (upload-to-cloud editor-content)
  (-> string? thread?)
  (thread (λ ()
            (let ([json-body (serialize-data editor-content (hash))])
              (with-handlers ([exn:fail? (λ (exn) (void))]) ;; TODO: graceful error handling
                (http-conn-send! 
                 (http-conn-open HOST #:port PORT) 
                 ENDPOINT 
                 #:method #"POST" 
                 #:data json-body))))))


;; serialize-data : String [Hash-of Symbol String] -> String
;; encodes the given data into a JSON object to be sent to the server
#|
Schema:
{
  content: String,
  metadata: {
    ...
  }
}
|#
(define/contract (serialize-data editor-content metadata)
  (-> string? (hash/c symbol? string?) string?)
  (jsexpr->string (hash 'content editor-content
                        'metadata metadata)))

(check-equal? (serialize-data "content from the editor" (hash))
              "{\"content\":\"content from the editor\",\"metadata\":{}}")
(check-equal? (serialize-data "content from the editor" (hash 'name "Ryan"))
              "{\"content\":\"content from the editor\",\"metadata\":{\"name\":\"Ryan\"}}")
(check-equal? (serialize-data "" (hash))
              "{\"content\":\"\",\"metadata\":{}}")



(define CLOUD-BACKUP-PLUGIN (make-cloud-backup-plugin upload-to-cloud))

;; Per the DrRacket plugin system, this must be exported under the name `tool@`
(provide (rename-out [CLOUD-BACKUP-PLUGIN tool@]))
