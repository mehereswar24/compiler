/* ast.h - shared definitions: token log, syntax tree, diagnostics */
#ifndef AST_H
#define AST_H
#include <stdio.h>

typedef enum { TY_INT, TY_FLOAT } Type;
typedef enum { N_DECL, N_ASSIGN, N_PRINT, N_BIN, N_NEG, N_INT, N_FLOAT, N_VAR } Kind;

typedef struct Node {
    Kind kind;
    int line;
    char op;              /* '+','-','*','/','%','^' for N_BIN */
    char *name;           /* variable name (DECL/ASSIGN/VAR) */
    long long ival;       /* N_INT */
    double fval;          /* N_FLOAT */
    Type type;            /* declared type (N_DECL) */
    struct Node *l, *r;   /* children; DECL/ASSIGN use l for init expr, PRINT uses l */
    struct Node *next;    /* statement list */
} Node;

extern int n_errors;
void report(const char *kind, int line, const char *fmt, ...);

/* token log (filled by the lexer) */
void tok_record(const char *cls, const char *lexeme, int line);
void tok_dump(FILE *f);

/* tree construction (called from Bison actions) */
Node *mk_int(long long v, int line);
Node *mk_float(double v, int line);
Node *mk_var(char *name, int line);
Node *mk_bin(char op, Node *l, Node *r, int line);
Node *mk_neg(Node *e, int line);
Node *mk_decl(Type t, char *name, Node *init, int line);
Node *mk_assign(char *name, Node *e, int line);
Node *mk_print(Node *e, int line);
void  add_stmt(Node *s);
Node *program(void);

void tree_dump(FILE *f, Node *prog);
const char *type_name(Type t);
#endif
