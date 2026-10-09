/* main.c - Review-1 driver: lexer + parser + parse tree */
#include <stdio.h>
#include <string.h>
#include "ast.h"

extern FILE *yyin;
int yyparse(void);

int main(int argc, char **argv) {
    int quiet = 0; const char *path = NULL;
    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "-q")) quiet = 1;      /* hide the token table */
        else path = argv[i];
    }
    if (path && !(yyin = fopen(path, "r"))) { perror(path); return 2; }

    printf("== Phase 1+2: lexing and parsing (diagnostics) ==\n");
    yyparse();
    if (n_errors == 0) printf("  none\n");

    if (!quiet) { printf("\n== Token stream ==\n"); tok_dump(stdout); }

    printf("\n== Syntax (parse) tree ==\n");
    tree_dump(stdout, program());

    printf("\n== Summary: %d error(s) ==\n", n_errors);
    return n_errors != 0;
}
