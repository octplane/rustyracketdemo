#lang racket/base

;; Each library function is prefixed by the module it came from.

(require web-server/dispatch)
(define-values (dispatch blog-url)
  (dispatch-rules
   [("go") go]))

;; dispatch-rules patterns cover the entire URL, not just the prefix,
;; so your serve-static only matches "/" not anything with that as a
;; prefix. Also, (next-dispatcher) is the default 'else' rule, so it's
;; not necessary.

(require web-server/http)
(define (go req)
  (response/xexpr
   `(html (body (p "Dynamically")))))

;; No real comments here :P

(require racket/runtime-path)
(define-runtime-path here ".")

;; (current-directory) is the directory that you start the server
;; from, not the directory where the server's source file is
;; located. The best way to get that is with define-runtime-path

(require web-server/servlet-env)
(serve/servlet dispatch
               #:extra-files-paths (list (build-path here "htdocs"))
               #:servlet-path "/"
               #:servlet-regexp #rx"")

;; #:launch-browser? #t is not necessary because its the default.

;; #:servlet-regexp #rx"" is the key because it means that the server
;; covers all URLs, not just the servlet's path.

