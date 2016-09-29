#lang racket/base

(require
         racket/runtime-path
         ffi/unsafe
         ffi/cvector)

(define-runtime-path here ".")

;; link to the rust library:
(define rust-lib (ffi-lib (build-path here "target/debug/libreplace")))
(define rust-replace-fun (get-ffi-obj "replace_all" rust-lib
                                      (_fun _cvector _cvector _size _string -> _string)))

(rust-replace-fun (list->cvector (list "a" "z") _string) (list->cvector (list "s" "x") _string) 2 "azaz za za")
