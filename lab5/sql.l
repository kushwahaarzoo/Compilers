%{
#include "y.tab.h"
#include <string.h>
%}

%%

","        { return COMMA; }
";"        { return SEMICOLON; }
"*"        { return STAR; }
"="        { return EQ; }
"("        { return LPAREN; }
")"        { return RPAREN; }
\'[^\']*\' {
    yylval.str = strdup(yytext);
    return STRING;
}

[0-9]+ {
    yylval.str = strdup(yytext);
    return NUM;
}
[Cc][Rr][Ee][Aa][Tt][Ee]  { return CREATE; }
[Tt][Aa][Bb][Ll][Ee]  { return TABLE; }
[Ii][Nn][Tt]    { return INT; }
[Ss][Ee][Ll][Ee][Cc][Tt]      { return SELECT; }
[Ff][Rr][Oo][Mm]   { return FROM; }
[Ww][Hh][Ee][Rr][Ee]     { return WHERE; }
[Ii][Nn][Ss][Ee][Rr][Tt]      { return INSERT; }
[Ii][Nn][Tt][Oo]   { return INTO; }
[Vv][Aa][Ll][Uu][Ee][Ss]      { return VALUES; }
[Uu][Pp][Dd][Aa][Tt][Ee]      { return UPDATE; }
[Ss][Ee][Tt]   { return SET; }
[Dd][Ee][Ll][Ee][Tt][Ee]      { return DELETE; }
[Vv][Aa][Rr][Cc][Hh][Aa][Rr]  { return VARCHAR; }
[Aa][Nn][Dd]  { return AND; }

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str = strdup(yytext);
    return ID;
}

[ \t\n]+     ;

.            ;

%%

int yywrap()
{
    return 1;
}