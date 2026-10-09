# compiler

Compiler for an arithmetic expression language using Flex and Bison (Review 1 scope: lexer, parser, token stream, parse tree).

## Build and run
    sh build.sh                  # bison + flex + gcc -> arithc.exe
    ./arithc.exe tests/t4_demo.ac
    ./arithc.exe -q prog.ac      # hide the token table
    sh run_tests.sh              # regression tests
    python ui/server.py          # web UI at http://127.0.0.1:8765

Requires flex, bison, gcc. `docs/make_docs.py` regenerates the report and slides (needs python-docx, python-pptx).

## Status
Done: lexer, parser (precedence, right-assoc `^`, error recovery), parse tree, UI.
Planned: semantic validation, Three Address Code.
