%{
#include <stdio.h>

FILE *out;
%}

%%
"//".*                          ;   /* remove single-line comments */

"/*"([^*]|\*+[^*/])*\*+"/"   ;   /* remove multi-line comments */

[ \t\n]+                        { fputs(yytext, out); }

.                               { fputc(yytext[0], out); }
%%

int yywrap(void)
{
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        printf("Usage: %s <input.java> <output.java>\n", argv[0]);
        return 1;
    }

    FILE *in = fopen(argv[1], "r");
    if (!in)
    {
        perror("Input file error");
        return 1;
    }

    out = fopen(argv[2], "w");
    if (!out)
    {
        perror("Output file error");
        return 1;
    }

    yyin = in;     /* FLEX reads from input file */
    yylex();       /* start scanning */

    fclose(in);
    fclose(out);

    printf("Comments removed successfully.\n");
    return 0;
}

