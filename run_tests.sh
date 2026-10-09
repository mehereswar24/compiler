#!/bin/sh
# Regression tests for the Review-1 scope: tokens, parse tree, syntax error recovery.
cd "$(dirname "$0")"; fail=0
check() { # name, file, flags, expected-substring
  out=$(./arithc.exe $3 "tests/$2" 2>&1 | tr -d '\r')
  if printf '%s' "$out" | grep -qF -- "$4"; then echo "PASS  $1"; else echo "FAIL  $1  (missing: $4)"; fail=1; fi
}
check "keyword token"                t4_demo.ac   ""   "KEYWORD          float"
check "float literal token"          t1_valid.ac  ""   "FLOAT_LITERAL    1.5e1"
check "caret operator token"         t1_valid.ac  ""   "CARET            ^"
check "comments are skipped"         t1_valid.ac  ""   "(98 tokens)"
check "* binds tighter than +"       t4_demo.ac   "-q" "|       |-- BinOp '+'"
check "left-assoc minus"             t4_demo.ac   "-q" "BinOp '-'"
check "unary minus node"             t1_valid.ac  "-q" "Neg"
check "valid file: 0 errors"         t4_demo.ac   "-q" "0 error(s)"
check "illegal character reported"   t3_syntax.ac "-q" "illegal character '\$'"
check "syntax error line 2"          t3_syntax.ac "-q" "line 2: error"
check "recovery reaches line 4"      t3_syntax.ac "-q" "line 4: error"
# 2^3^2 must nest as 2^(3^2): two '^' nodes, the second under the first
out=$(./arithc.exe -q tests/t1_valid.ac | tr -d '\r' | grep -A5 "Decl int p")
n=$(printf '%s\n' "$out" | grep -c "BinOp '^'")
if [ "$n" = 2 ] && printf '%s\n' "$out" | grep -q "^|       \`-- BinOp '^'"; then echo "PASS  ^ nests as 2^(3^2)"; else echo "FAIL  ^ nesting"; fail=1; fi
exit $fail
