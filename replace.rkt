#lang racket/base

(require json
         web-server/servlet-env
         racket/runtime-path
         web-server/dispatch
         web-server/http/request-structs
         web-server/http/response-structs
         racket/match
         ffi/unsafe
         ffi/cvector)

(define-runtime-path here ".")

;; link to the rust library:
(define rust-lib (ffi-lib (build-path here "target/debug/libreplace")))
(define rust-replace-fun (get-ffi-obj "replace" rust-lib
                                      (_fun _string _string _string -> _string)))

(rust-replace-fun "i" "hihihih" "a")
