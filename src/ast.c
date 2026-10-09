/* ast.c - token log, parse-tree construction and printing */
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "ast.h"

int n_errors = 0;

void report(const char *kind, int line, const char *fmt, ...) {
    va_list ap;
    printf("  line %d: %s: ", line, kind);
    va_start(ap, fmt); vprintf(fmt, ap); va_end(ap);
    printf("\n");
    n_errors++;
}

const char *type_name(Type t) { return t == TY_INT ? "int" : "float"; }

/* ------------------------------------------------------------ token log */
typedef struct { const char *cls; char *lex; int line; } TokRec;
static TokRec *toks; static int ntok, captok;

void tok_record(const char *cls, const char *lexeme, int line) {
    if (ntok == captok) { captok = captok ? captok * 2 : 64; toks = realloc(toks, captok * sizeof *toks); }
    toks[ntok].cls = cls; toks[ntok].lex = strdup(lexeme); toks[ntok].line = line; ntok++;
}
void tok_dump(FILE *f) {
    fprintf(f, "  %-5s %-16s %s\n", "LINE", "TOKEN", "LEXEME");
    for (int i = 0; i < ntok; i++) fprintf(f, "  %-5d %-16s %s\n", toks[i].line, toks[i].cls, toks[i].lex);
    fprintf(f, "  (%d tokens)\n", ntok);
}

/* -------------------------------------------------------- construction */
static Node *mk(Kind k, int line) { Node *n = calloc(1, sizeof *n); n->kind = k; n->line = line; return n; }
Node *mk_int(long long v, int line)   { Node *n = mk(N_INT, line);   n->ival = v; return n; }
Node *mk_float(double v, int line)    { Node *n = mk(N_FLOAT, line); n->fval = v; return n; }
Node *mk_var(char *s, int line)       { Node *n = mk(N_VAR, line);   n->name = s; return n; }
Node *mk_bin(char op, Node *l, Node *r, int line) { Node *n = mk(N_BIN, line); n->op = op; n->l = l; n->r = r; return n; }
Node *mk_neg(Node *e, int line)       { Node *n = mk(N_NEG, line);   n->l = e; return n; }
Node *mk_decl(Type t, char *s, Node *i, int line) { Node *n = mk(N_DECL, line); n->type = t; n->name = s; n->l = i; return n; }
Node *mk_assign(char *s, Node *e, int line) { Node *n = mk(N_ASSIGN, line); n->name = s; n->l = e; return n; }
Node *mk_print(Node *e, int line)     { Node *n = mk(N_PRINT, line); n->l = e; return n; }

static Node *head, *tail;
void add_stmt(Node *s) { if (tail) tail->next = s; else head = s; tail = s; }
Node *program(void) { return head; }

/* ------------------------------------------------------------ tree dump */
static void label(FILE *f, Node *n) {
    switch (n->kind) {
    case N_DECL:   fprintf(f, "Decl %s %s", type_name(n->type), n->name); break;
    case N_ASSIGN: fprintf(f, "Assign %s", n->name); break;
    case N_PRINT:  fprintf(f, "Print"); break;
    case N_BIN:    fprintf(f, "BinOp '%c'", n->op); break;
    case N_NEG:    fprintf(f, "Neg"); break;
    case N_INT:    fprintf(f, "Int %lld", n->ival); break;
    case N_FLOAT:  fprintf(f, "Float %g", n->fval); break;
    case N_VAR:    fprintf(f, "Var %s", n->name); break;
    }
}
static void dump(FILE *f, Node *n, const char *prefix, int last) {
    fprintf(f, "%s%s", prefix, last ? "`-- " : "|-- ");
    label(f, n); fprintf(f, "\n");
    char np[512]; snprintf(np, sizeof np, "%s%s", prefix, last ? "    " : "|   ");
    if (n->l && n->r) { dump(f, n->l, np, 0); dump(f, n->r, np, 1); }
    else if (n->l)    dump(f, n->l, np, 1);
}
void tree_dump(FILE *f, Node *prog) {
    fprintf(f, "Program\n");
    for (Node *s = prog; s; s = s->next) dump(f, s, "", s->next == NULL);
}
