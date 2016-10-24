
main: main.o ./target/debug/deps/libreplace.dylib
	gcc -v main.o ./target/debug/deps/libreplace.dylib -o main

main.o: main.c
	gcc -c main.c

./target/debug/deps/libreplace.dylib: src/replace.rs
	cargo build
