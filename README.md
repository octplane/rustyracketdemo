A demo of embedding Rust in Racket.

PORTED FROM BRSON'S RUBYRUSTDEMO.

```
rustc blur.rs -O
LD_LIBRARY_PATH=. ruby blur.rb
```

Then browse to localhost:4567
