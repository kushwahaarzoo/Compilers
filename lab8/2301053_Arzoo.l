%{
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%%

[ \t\r\n]+                  ;
"#include".*                ;

"int"[ \t]+"main"[ \t]*"()"[ \t]*"{"   ;

"if"                { return IF; }
"else"              { return ELSE; }
"return"            { return RETURN; }

"int"|"float"|"char"|"void" {
    yylval.str = strdup(yytext);
    return TYPE;
}

[0-9]+(\.[0-9]+)? {
    yylval.str = strdup(yytext);
    return NUM;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str = strdup(yytext);
    return ID;
}

"&&"                { return AND; }
"||"                { return OR; }
"=="                { return EQ; }
"!="                { return NE; }
"<="                { return LE; }
">="                { return GE; }
"+="                { return ADDEQ; }
"-="                { return SUBEQ; }
"++"                { return INC; }

"}"                 { return RBRACE; }

.                   { return yytext[0]; }

%%

int yywrap() { return 1; }
