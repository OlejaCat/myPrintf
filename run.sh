#!/bin/bash

nasm -f elf64 source/myPrintf.s -o myPrintf.o
gcc -Iinclude -no-pie source/main.c myPrintf.o -o exec
