#!/bin/bash

nasm -felf64 -g -F dwarf -Wall $1/$1.s && ld -o $1/$1 -dynamic-linker /lib64/ld-linux-x86-64.so.2 /usr/lib/x86_64-linux-gnu/crt1.o /usr/lib/x86_64-linux-gnu/crti.o -lc $1/$1.o /usr/lib/x86_64-linux-gnu/crtn.o
