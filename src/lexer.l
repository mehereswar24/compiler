%{
/* lexer.l - Phase 1: lexical analysis */
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "parser.tab.h"

static int tok(const char *cls, int code) {
    tok_record(cls, yytext, yylineno);
    return code;
}
%}

%option noyywrap yylineno nounput noinput

DIGIT   [0-9]
ID      [A-Za-z][A-Za-z0-9_]*
EXP     [eE][+-]?{DIGIT}+

%x BLOCK

%%
[ \t\r]+                 ;
\n                       ;
"//".*                   ;
"/*"                     { BEGIN(BLOCK); }
<BLOCK>"*/"              { BEGIN(INITIAL); }
<BLOCK>.|\n              ;
<BLOCK><<EOF>>           { report("error", yylineno, "unterminated comment"); BEGIN(INITIAL); }

"int"                    { return tok("KEYWORD", KW_INT); }
"float"                  { return tok("KEYWORD", KW_FLOAT); }
"print"                  { return tok("KEYWORD", KW_PRINT); }

{DIGIT}+"."{DIGIT}*({EXP})?  |
"."{DIGIT}+({EXP})?          |
{DIGIT}+{EXP}                { yylval.fval = atof(yytext); return tok("FLOAT_LITERAL", FNUM); }
{DIGIT}+                     { yylval.ival = atoll(yytext); return tok("INT_LITERAL", INUM); }

{ID}                     { yylval.str = strdup(yytext); return tok("IDENTIFIER", ID); }

"+"                      { return tok("PLUS", '+'); }
"-"                      { return tok("MINUS", '-'); }
"*"                      { return tok("STAR", '*'); }
"/"                      { return tok("SLASH", '/'); }
"%"                      { return tok("PERCENT", '%'); }
"^"                      { return tok("CARET", '^'); }
"="                      { return tok("ASSIGN", '='); }
"("                      { return tok("LPAREN", '('); }
")"                      { return tok("RPAREN", ')'); }
";"                      { return tok("SEMICOLON", ';'); }

.                        { report("error", yylineno, "lexical error: illegal character '%s'", yytext); }
%%
