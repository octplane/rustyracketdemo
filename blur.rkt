#lang racket/base

(require json
         web-server/servlet-env
         web-server/servlet/web
         web-server/http/xexpr
         racket/runtime-path
         web-server/dispatch
         web-server/http/request-structs
         web-server/http/response-structs
         racket/match
         )

(define-runtime-path here ".")

(define (pre-dispatch request)
  (printf "received request\n")
  (dispatch request))

(define-values (dispatch blog-url)
  (dispatch-rules
   [("blur" (string-arg)) #:method "post" foo]))

(define (foo request kind)
  (printf "got a request!\n")
  (define post-bytes (request-post-data/raw request))
  (printf "post data is of length ~s.\n" (bytes-length post-bytes))
  (printf "first 100 bytes: ~s\n" (subbytes post-bytes 0 100))
  (define img-json (bytes->jsexpr post-bytes))
  (printf "image: ~e\n" img-json)
  (define result (blur img-json racket-blur))
  (response/full
   200 #"Okay" (current-seconds) #"application/json; charset=utf-8"
   null
   (list (jsexpr->bytes result))))

;; jsexpr->jsexpr : do the monochromatic blur in racket
(define (blur img fun)
  (match-define (hash-table ('width width) ('height height) ('data data)) img)
  (define start-time (current-inexact-milliseconds))
  (define newdata (fun width height data))
  (define time-taken (- (current-inexact-milliseconds) start-time))
  '#hasheq((data . newdata) (time . time-taken)))

(define (racket-blur width height data)
  (jsexpr->bytes #'((width . 200) (height . 200) (data . "oops"))))


(serve/servlet
 pre-dispatch
 #:extra-files-paths (list (build-path here "htdocs"))
 #:servlet-path "/"
 #:servlet-regexp #rx"")

#|
def blur
  msg = request.body.read
  msg = JSON.parse msg

  width = msg['width']
  height = msg['height']
  data = msg['data']

  if (data.length != width * height)
    return
  end

  start_time = Time.now()
  newdata = yield(width, height, data)
  end_time = Time.now() - start_time
  logger.info end_time

  response = { :data => newdata, :time => end_time }
  JSON.generate(response)
end

def blur_ruby(width, height, data)

  filter = [[0.011, 0.084, 0.011],
            [0.084, 0.619, 0.084],
            [0.011, 0.084, 0.011]]

  newdata = []             

  # Iterate through the pixels of the image
  (0...height).each do |y|
    (0...width).each do |x|
      new_value = 0
      # Iterate through the values in the filter
      (0...filter.length).each do |yy|
        (0...filter.length).each do |xx|
          x_sample = x - (filter.length - 1) / 2 + xx
          y_sample = y - (filter.length - 1) / 2 + yy
          sample_value = data[width * (y_sample % height) + (x_sample % width)]
          weight = filter[yy][xx]
          new_value += sample_value * weight
        end
      end
      newdata[width * y + x] = new_value
    end
  end

  newdata
end

def blur_rust(width, height, data)
  packed_data = data.pack("C*")
  raw_data = FFI::MemoryPointer.from_string(packed_data)
  RustBlur.blur(width, height, raw_data)
  
  raw_data.get_bytes(0, width * height).unpack("C*")
end

module RustBlur
  extend FFI::Library
  ffi_lib 'libblur-68a2c114141ca-0.0'

  attach_function :blur, :blur, [ :uint, :uint, :pointer ], :void
end
|#