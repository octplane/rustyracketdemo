## A demo of embedding Rust in Racket.

This demo is ported from Brian Anderson's Ruby+Rust demo. Indeed, it's a fork of his github repo.
Here's [my github repo](http://www.github.com/jbclements/rustyracketdemo/).

To run it locally, compile the library and run the server, using these two commands:

```
rustc blur.rs -O
racket blur.rkt
```

