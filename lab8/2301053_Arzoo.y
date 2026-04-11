%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int temp_count = 1;
int label_count = 1;
int line_no = 100;

char* new_temp() {
    char* t = malloc(10);
    sprintf(t, "t%d", temp_count++);
    return t;
}

void yyerror(const char *s);
int yylex();
extern FILE *yyin;
%}

%union {
    char* str;
}

%token <str> ID NUM TYPE
%token IF ELSE RETURN RBRACE
%token AND OR EQ NE LE GE ADDEQ SUBEQ INC

%left OR
%left AND
%left EQ NE LE GE '<' '>'
%left '+' '-'
%left '*' '/'
%right '!'

%type <str> exp
%type <str> if_header

%%

program:
    stmtlist RBRACE
    ;

stmtlist:
    stmtlist stmt
    | /* empty */
    ;

if_header:
    IF '(' exp ')'
        {
            char *lbl = malloc(10);
            sprintf(lbl, "END%d", label_count);
            printf("%d: if %s goto %d\n", line_no, $3, line_no + 2);
            printf("%d: goto %s\n", line_no + 1, lbl);
            line_no += 2;
            $$ = lbl;
        }
    ;

stmt:
      TYPE ID '=' exp ';'
        { printf("%d: %s = %s\n", line_no++, $2, $4); }

    | ID '=' exp ';'
        { printf("%d: %s = %s\n", line_no++, $1, $3); }

    | ID ADDEQ exp ';'
        {
            char *t = new_temp();
            printf("%d: %s = %s + %s\n", line_no++, t, $1, $3);
            printf("%d: %s = %s\n", line_no++, $1, t);
        }

    | ID SUBEQ exp ';'
        {
            char *t = new_temp();
            printf("%d: %s = %s - %s\n", line_no++, t, $1, $3);
            printf("%d: %s = %s\n", line_no++, $1, t);
        }

    | ID INC ';'
        {
            char *t = new_temp();
            printf("%d: %s = %s + 1\n", line_no++, t, $1);
            printf("%d: %s = %s\n", line_no++, $1, t);
        }

    | if_header '{' stmtlist RBRACE
        {
            printf("%s:\n", $1);
            label_count++;
            free($1);
        }

    | RETURN exp ';'
        { printf("%d: return %s\n", line_no++, $2); }
    ;

exp:
      exp '+' exp
        { char *t = new_temp(); printf("%d: %s = %s + %s\n", line_no++, t, $1, $3); $$ = t; }
    | exp '-' exp
        { char *t = new_temp(); printf("%d: %s = %s - %s\n", line_no++, t, $1, $3); $$ = t; }
    | exp '*' exp
        { char *t = new_temp(); printf("%d: %s = %s * %s\n", line_no++, t, $1, $3); $$ = t; }
    | exp '/' exp
        { char *t = new_temp(); printf("%d: %s = %s / %s\n", line_no++, t, $1, $3); $$ = t; }
    | exp AND exp
        { char *t = new_temp(); printf("%d: %s = %s && %s\n", line_no++, t, $1, $3); $$ = t; }
    | exp OR exp
        { char *t = new_temp(); printf("%d: %s = %s || %s\n", line_no++, t, $1, $3); $$ = t; }
    | exp EQ exp
        { char *t = new_temp(); printf("%d: %s = %s == %s\n", line_no++, t, $1, $3); $$ = t; }
    | exp NE exp
        { char *t = new_temp(); printf("%d: %s = %s != %s\n", line_no++, t, $1, $3); $$ = t; }
    | exp '<' exp
        { char *t = new_temp(); printf("%d: %s = %s < %s\n", line_no++, t, $1, $3); $$ = t; }
    | exp '>' exp
        { char *t = new_temp(); printf("%d: %s = %s > %s\n", line_no++, t, $1, $3); $$ = t; }
    | exp LE exp
        { char *t = new_temp(); printf("%d: %s = %s <= %s\n", line_no++, t, $1, $3); $$ = t; }
    | exp GE exp
        { char *t = new_temp(); printf("%d: %s = %s >= %s\n", line_no++, t, $1, $3); $$ = t; }
    | '!' exp
        { char *t = new_temp(); printf("%d: %s = ! %s\n", line_no++, t, $2); $$ = t; }
    | '(' exp ')'
        { $$ = $2; }
    | ID   { $$ = $1; }
    | NUM  { $$ = $1; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s input.c\n", argv[0]);
        return 1;
    }
    FILE *fp = fopen(argv[1], "r");
    if (!fp) {
        printf("File not found: %s\n", argv[1]);
        return 1;
    }
    yyin = fp;
    printf("Three Address Code of the given c file is:\n");
    yyparse();
    fclose(fp);
    return 0;
}
