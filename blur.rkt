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

;; define the dispatcher
(define-values (dispatch blog-url)
  (dispatch-rules
   [("blur" (string-arg)) #:method "post" decode]))

;; unpack the args and call the right function.
(define (decode request kind)
  (define img (bytes->jsexpr (request-post-data/raw request)))
  (define backend
    (match kind
      ["rust" rust-blur]
      ["racket" racket-blur]))
  (match-define (hash-table ('width width) ('height height) ('data data)) img)
  (define start-time (current-inexact-milliseconds))
  (define new-bytes (backend width height data))
  ;; ignoring the possibility of millisecond rollover:
  (define time-taken (/ (- (current-inexact-milliseconds) start-time) 1000.0))
  (define result
    `#hasheq((width . ,width) (height . ,height) (time . ,time-taken) (data . ,new-bytes)))
  (response/full
   200 #"Okay" (current-seconds) #"application/json; charset=utf-8"
   null
   (list (jsexpr->bytes result))))

;; the gaussian filter used in the racket blur.
;; boosted center value by 1/1000 to make sure that whites stay white.
(define filter '[[0.011 0.084 0.011]
                 [0.084 0.620 0.084]
                 [0.011 0.084 0.011]])

;; racket-blur: blur the image using the gaussian filter
;; number number list-of-bytes -> vector-of-bytes
(define (racket-blur width height data)
  (define data-vec (list->vector data))
  ;; ij->offset : compute the offset of the pixel data within the buffer
  (define (ij->offset i j)
    (+ i (* j width)))
  (define bytes-len (* width height))
  (define new-bytes (make-vector bytes-len 0))
  (define filter-x (length (car filter)))
  (define filter-y (length filter))
  (define offset-x (/ (sub1 filter-x) 2))
  (define offset-y (/ (sub1 filter-y) 2))
  ;; compute the filtered byte array
  (for* ([x width]
         [y height])
    (define new-val
      (for*/fold ([sum 0.0])
        ([dx filter-x]
         [dy filter-y])
        (define sample-x (modulo (+ dx (- x offset-x)) width))
        (define sample-y (modulo (+ dy (- y offset-y)) height))
        (define sample-value (vector-ref data-vec (ij->offset sample-x sample-y)))
        (define weight (list-ref (list-ref filter dy) dx))
        (+ sum (* weight sample-value))))
    (vector-set! new-bytes (ij->offset x y) new-val))  
  (vector->list new-bytes))


;; link to the rust library:
(define rust-lib (ffi-lib (build-path here "libblur-68a2c114141ca-0.0")))
(define rust-blur-fun (get-ffi-obj "blur" rust-lib (_fun _uint _uint _cvector -> _void)))

(define (rust-blur width height data)
  (define cvec (list->cvector data _byte))
  (rust-blur-fun width height cvec)
  (cvector->list cvec))

(serve/servlet
 dispatch
 #:extra-files-paths (list (build-path here "htdocs"))
 #:servlet-path "/"
 #:servlet-regexp #rx"")
