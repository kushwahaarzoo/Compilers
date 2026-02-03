%{
#include <stdio.h>
#include <string.h>

#define MAX 100

char id[MAX][20];
char op[MAX];
int idC = 0;
int opC = 0;
int valid = 1;

void add_identifier(char *idf)
{
    for (int i = 0; i < idC; i++)
        if (strcmp(id[i], idf) == 0)
            return;

    strcpy(id[idC++], idf);
}

void add_operator(char ops)
{
    op[opC++] = ops;
}
%}

%%
[a-zA-Z_][a-zA-Z0-9_]*   { add_identifier(yytext); }
[0-9]+                  ;
[+\-*/%=]               { add_operator(yytext[0]); }
[()]                    ;
[ \t\n]+                ;
.                       { valid = 0; }
%%

int yywrap()
{
    return 1;
}

int main()
{	
    printf("Hello");
    printf("Enter arithmetic expression:\n");
    yylex();

    if (!valid)
    {
        printf("Invalid expression\n");
        return 0;
    }

    printf("Valid expression\n");

    printf("Identifiers are :");
    for (int i = 0; i < idC; i++)
        printf("%s,\t", id[i]);

    printf("Operators are \n");
    for (int i = 0; i < opC; i++)
        printf("%c,\t", op[i]);

    return 0;
}
