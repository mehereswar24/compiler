#!/bin/sh
# Build the Review-1 compiler (lexer + parser + parse tree): flex + bison + gcc
set -e
cd "$(dirname "$0")/src"
bison -d -Wall -o parser.tab.c parser.y
flex -o lex.yy.c lexer.l
gcc -Wall -Wextra -Wno-unused-function -o ../arithc.exe main.c ast.c parser.tab.c lex.yy.c
echo "built arithc.exe"
