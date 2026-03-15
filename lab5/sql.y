%{
#include <stdio.h>
#include <stdlib.h>
extern FILE *yyin;
extern int yylex();
void yyerror(char *s);
%}

%union {
    char *str;
}

%token SELECT FROM WHERE INSERT INTO VALUES UPDATE SET DELETE CREATE TABLE INT VARCHAR AND DROP
%token <str> ID NUM STRING
%token STAR EQ COMMA LPAREN RPAREN SEMICOLON

%%

stmt_list
    : stmt SEMICOLON { printf("Valid SQL Query\n"); }
    | stmt_list stmt SEMICOLON { printf("Valid SQL Query\n"); }
    ;

stmt
    : select_stmt
    | insert_stmt
    | update_stmt
    | delete_stmt
    | create_stmt
    ;

select_stmt
    : SELECT select_list FROM ID where_clause
    ;

select_list
    : STAR
    | ID
    ;

where_clause
    : WHERE condition
    | 
    ;

condition
    : ID EQ value
    ;

value
    : NUM
    | ID
    ;

insert_stmt
    : INSERT INTO ID VALUES LPAREN value_list RPAREN
    ;

value_list
    : value
    | value COMMA value_list
    ;

update_stmt
    : UPDATE ID SET ID EQ value where_clause
    ;

delete_stmt
    : DELETE FROM ID where_clause
    ;

create_stmt
    : CREATE TABLE ID LPAREN col_list RPAREN
    ;

col_list
    : col_def
    | col_def COMMA col_list
    ;

col_def
    : ID type
    ;

type
    : INT
    | VARCHAR LPAREN NUM RPAREN
    ;

%%

void yyerror(char *s)
{
    fprintf(stderr, "Invalid Query: %s\n", s);
}
int main(int argc, char *argv[])
{
    FILE *inputFile;
    if(argc < 2)
    {
        printf("Usage: %s <sql_file>\n", argv[0]);
        return 1;
    }
    inputFile = fopen(argv[1], "r");
    if(!inputFile)
    {
        printf("Unable to open file\n");
        return 1;
    }
    yyin = inputFile;
    yyparse();
    fclose(inputFile);
    return 0;
}