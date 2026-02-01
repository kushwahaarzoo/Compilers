%{
#include <stdio.h>

FILE *java_out;
FILE *doc_out;
%}

%x COMMENT
%x DOC

%%
"/**"                { BEGIN(DOC); }
<DOC>"*/"            { fputs("\n\n", doc_out); BEGIN(INITIAL); }
<DOC>.|\n            { fputc(yytext[0], doc_out); }

"/*"                 { BEGIN(COMMENT); }
<COMMENT>"*/"        { BEGIN(INITIAL); }
<COMMENT>.|\n        ;

"//".*               ;

[ \t\n]+             { fputs(yytext, java_out); }
.                    { fputc(yytext[0], java_out); }
%%

int yywrap()
{
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc != 4)
        return 1;

    FILE *in = fopen(argv[1], "r");
    if (!in)
        return 1;

    java_out = fopen(argv[2], "w");
    if (!java_out)
        return 1;

    doc_out = fopen(argv[3], "w");
    if (!doc_out)
        return 1;

    yyin = in;
    yylex();

    fclose(in);
    fclose(java_out);
    fclose(doc_out);

    return 0;
}

