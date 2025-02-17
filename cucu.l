%{
#include "cucu.tab.h" // Include the token definitions from the yacc file
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void yyerror(char *);
FILE *lex_yyout;
FILE *yacc_yyout;
%}
 
%%

[ \t\n]+     // Ignore whitespace

"int"|"char \*"|"char*"   { fprintf(lex_yyout, "TYPE : %s\n", yytext); return TYPE; }
"return" { fprintf(lex_yyout, "RETURN\n"); return RETURN; }
"if"     { fprintf(lex_yyout, "IF\n"); return IF; }
"else"   { fprintf(lex_yyout, "ELSE\n"); return ELSE; }
"while"  { fprintf(lex_yyout, "WHILE\n"); return WHILE; }
("=="|"!="|">"|"<"|">="|"<="|"&"|"\|")      {yylval.str=strdup(yytext);fprintf(lex_yyout,"COMPARATOR OP: %s\n",yytext); return COMPARATOROP;}
"="      { fprintf(lex_yyout, "ASSIGN : %s\n", yytext); return ASSIGN; }
"("      { fprintf(lex_yyout, "LPAREN : %s\n", yytext); return LPAREN; }
")"      { fprintf(lex_yyout, "RPAREN : %s\n", yytext); return RPAREN; }
"{"      { fprintf(lex_yyout, "LBRACE : %s\n", yytext); return LBRACE; }
"}"      { fprintf(lex_yyout, "RBRACE : %s\n", yytext); return RBRACE; }
";"      { fprintf(lex_yyout, "SEMI : %s\n", yytext); return SEMI; }
","      { fprintf(lex_yyout, "COMMA : %s\n", yytext); return COMMA; }
"+"      { yylval.str=strdup(yytext); fprintf(lex_yyout, "PLUS : %s\n", yytext); return PLUS; }
"-"      { yylval.str=strdup(yytext); fprintf(lex_yyout, "SUB : %s\n", yytext); return SUB; }
"/"      { yylval.str=strdup(yytext); fprintf(lex_yyout, "DIV : %s\n", yytext); return DIV; }
"*"      { yylval.str=strdup(yytext); fprintf(lex_yyout, "MUL : %s\n", yytext); return MUL; }
[A-Za-z][a-zA-Z0-9_]*  { yylval.str = strdup(yytext); fprintf(lex_yyout, "ID : %s\n", yytext); return ID; }
[0-9]+         { yylval.str = strdup(yytext); fprintf(lex_yyout, "NUM : %s\n", yytext); return NUM; }

\/\*[^*]*\*+([^/*][^*]*\*+)*\/   ; // Ignore comments

.        

%%

int yywrap() {
    return 1;
}
void yyerror(char *s){
	fprintf(lex_yyout,"ERROR!!");
	fprintf(yacc_yyout,"ERROR!!");
	printf("error!!\n");
}