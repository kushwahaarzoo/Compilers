%{
#include <stdio.h>
#include <string.h>

int ddlC = 0;
int dmlC = 0;
%}

%%
[Cc][Rr][Ee][Aa][Tt][Ee]     |
[Dd][Rr][Oo][Pp]             |
[Aa][Ll][Tt][Ee][Rr]         |
[Tt][Rr][Uu][Nn][Cc][Aa][Tt][Ee] |
[Rr][Ee][Nn][Aa][Mm][Ee]     {
                                ddlC++;
                             }

[Ss][Ee][Ll][Ee][Cc][Tt]     |
[Ii][Nn][Ss][Ee][Rr][Tt]     |
[Uu][Pp][Dd][Aa][Tt][Ee]     |
[Dd][Ee][Ll][Ee][Tt][Ee]     {
                                dmlC++;
                             }

.|\n                         ;
%%

int yywrap()
{
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        printf("Error file");
        return 1;
    }

    FILE *in = fopen(argv[1], "r");
    if (!in)
    {
        perror("File error");
        return 1;
    }

    yyin = in;
    yylex();
    printf("DDL: %d\n", ddlC);
    printf("DML: %d\n", dmlC);

    fclose(in);
    return 0;
}
