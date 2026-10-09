%{
/* parser.y - Phase 2: syntax analysis, builds the syntax (parse) tree */
#include <stdio.h>
#include "ast.h"
int yylex(void);
void yyerror(const char *msg);
extern int yylineno;
%}

%define parse.error verbose

%union {
    long long ival;
    double fval;
    char *str;
    struct Node *node;
}

%token KW_INT KW_FLOAT KW_PRINT
%token <ival> INUM
%token <fval> FNUM
%token <str>  ID
%type  <node> expr stmt
%type  <ival> type

/* lowest to highest precedence; '^' is right-assoc and binds tighter than unary minus */
%left  '+' '-'
%left  '*' '/' '%'
%precedence UMINUS
%right '^'

%%
program : stmts ;

stmts   : %empty
        | stmts stmt        { if ($2) add_stmt($2); }
        ;

stmt    : type ID ';'              { $$ = mk_decl((Type)$1, $2, NULL, yylineno); }
        | type ID '=' expr ';'     { $$ = mk_decl((Type)$1, $2, $4, yylineno); }
        | ID '=' expr ';'          { $$ = mk_assign($1, $3, yylineno); }
        | KW_PRINT expr ';'        { $$ = mk_print($2, yylineno); }
        | error ';'                { $$ = NULL; yyerrok; }     /* panic-mode recovery */
        ;

type    : KW_INT                   { $$ = TY_INT; }
        | KW_FLOAT                 { $$ = TY_FLOAT; }
        ;

expr    : expr '+' expr            { $$ = mk_bin('+', $1, $3, yylineno); }
        | expr '-' expr            { $$ = mk_bin('-', $1, $3, yylineno); }
        | expr '*' expr            { $$ = mk_bin('*', $1, $3, yylineno); }
        | expr '/' expr            { $$ = mk_bin('/', $1, $3, yylineno); }
        | expr '%' expr            { $$ = mk_bin('%', $1, $3, yylineno); }
        | expr '^' expr            { $$ = mk_bin('^', $1, $3, yylineno); }
        | '-' expr %prec UMINUS    { $$ = mk_neg($2, yylineno); }
        | '+' expr %prec UMINUS    { $$ = $2; }
        | '(' expr ')'             { $$ = $2; }
        | INUM                     { $$ = mk_int($1, yylineno); }
        | FNUM                     { $$ = mk_float($1, yylineno); }
        | ID                       { $$ = mk_var($1, yylineno); }
        ;
%%

void yyerror(const char *msg) {
    report("error", yylineno, "%s", msg);
}
