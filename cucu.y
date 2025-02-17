%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
void yyerror(const char *s);

FILE* yyin;
FILE* lex_yyout;
FILE* yacc_yyout;

%}

%union {
    char *str;
    struct {
        int num_args;
        char **args;
    } arg_list;
}

%type <arg_list> args_list

%token <str> NUM
%token <str> ID
%token TYPE RETURN IF ELSE WHILE LPAREN RPAREN LBRACE RBRACE SEMI COMMA PLUS SUB MUL DIV <str> COMPARATOROP
%left ASSIGN
%left PLUS SUB
%left MUL DIV

%start program

%%

program : declarations function_def {fprintf(yacc_yyout,"....Program Ended....\n");}
        | function_def              {fprintf(yacc_yyout,"....Program Ended....\n");}
        ;

declarations : declarations declaration
             | declaration
             ;

declaration : var_decl SEMI
            | func_decl SEMI 
            ;

var_decl : TYPE ID 
          {
            fprintf(yacc_yyout,"variable declaration of identifier %s\n", $2);
          }
         ;

func_decl : TYPE ID LPAREN args_list RPAREN 
           {
            fprintf(yacc_yyout,"identifier: %s\n", $2);
            int i;
            for (i = 0; i < $4.num_args; i++) {
                    fprintf(yacc_yyout, "function argument: %s\n", $4.args[i]);
                }
           }
           | TYPE ID LPAREN RPAREN 
           {
            fprintf(yacc_yyout,"identifier: %s\n", $2);
           }
          ;

args_list : args_list COMMA TYPE ID
            {
              $$.num_args = $1.num_args + 1;
              $$.args = (char **)malloc($$.num_args * sizeof(char *));
              int i;
              for (i = 0; i < $1.num_args; i++) {
                  $$.args[i] = $1.args[i];
              }
              $$.args[$1.num_args] = $4;
          }
          | TYPE ID 
          {
              $$.num_args = 1;
              $$.args = (char **)malloc(sizeof(char *));
              $$.args[0] = $2;
          }
          ;

function_def : func_decl {fprintf(yacc_yyout,"function body\n");} LBRACE statements RBRACE
             |
             ;

statements : statement statements
           | statement
           ;

statement : TYPE ID {fprintf(yacc_yyout,"local variable: %s\n",$2);} ASSIGN assigned {fprintf(yacc_yyout,"=\n");} SEMI
          | TYPE ID {fprintf(yacc_yyout,"local variable: %s\n",$2);} SEMI
          | assignment SEMI
          | function_call SEMI{fprintf(yacc_yyout,"FUNC-CALL\n");}
          | RETURN control_expression SEMI {fprintf(yacc_yyout,"RET\n");}
          | if_statement
          | while_statement
          | LBRACE statements RBRACE 
          ;

assigned : expression
         | function_call {fprintf(yacc_yyout,"FUNC-CALL\n");}
         ;

assignment : ID {fprintf(yacc_yyout,"var-%s\t ",$1);} ASSIGN assigned {fprintf(yacc_yyout,"=\n");}

expression  : ID  {fprintf(yacc_yyout,"var-%s \t",$1);}
            | NUM  {fprintf(yacc_yyout,"const-%s \t",$1);}
            | expression PLUS expression  {fprintf(yacc_yyout,"+ \t");}
            | expression SUB expression   {fprintf(yacc_yyout,"- \t");}
            | expression MUL expression   {fprintf(yacc_yyout,"* \t");}
            | expression DIV expression   {fprintf(yacc_yyout,"/ \t");}
            | LPAREN expression RPAREN
            ;

function_call : ID {fprintf(yacc_yyout,"var-%s \t",$1);} LPAREN expression_list RPAREN
              ;

if_statement : IF {fprintf(yacc_yyout,"If-else statement\n");} LPAREN {fprintf(yacc_yyout,"If condition\n");}control_expression RPAREN LBRACE {fprintf(yacc_yyout,"\nIf body\n");}statements RBRACE ELSE {fprintf(yacc_yyout,"Else body\n");}LBRACE statements RBRACE {fprintf(yacc_yyout,"If-else statement ended\n");}
             ;

while_statement : WHILE{fprintf(yacc_yyout,"While statement\n");} LPAREN {fprintf(yacc_yyout,"while condition\n");} control_expression {fprintf(yacc_yyout,"\n");} RPAREN LBRACE statements RBRACE {fprintf(yacc_yyout,"Whilw statement ended\n");}
                ;

expression_list : expression_list COMMA control_expression {fprintf(yacc_yyout,"FUNC-ARG\n");}
                | control_expression {fprintf(yacc_yyout,"FUNC-ARG\n");}
                ;

control_expression : ID {fprintf(yacc_yyout,"var-%s \t",$1);} boolean_exp
                   | expression 
                   ;

boolean_exp : COMPARATOROP expression {fprintf(yacc_yyout,"%s \t",$1);} 
            ;

%%

int main(int argc, char* argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Error: Unable to open input file %s\n", argv[1]);
        return 1;
    }
    lex_yyout =  fopen("Lexer.txt", "w");
    yacc_yyout = fopen("Parser.txt", "w");
    yyparse();
    fclose(yyin);
    fclose(lex_yyout);
    fclose(yacc_yyout);
    return 0;
}