%{
#include "y.tab.h"
#include <string.h>
void yyerror(char *s);
%}

%option noyywrap
%option case-insensitive

%%

[ \t\n]+        { ; }
[,;.?!]+        { return END; }

"please"        { return PLEASE; }
"give"          { return GET; }
"show"          { return GET; }
"display"       { return GET; }
"me"            { ; }
"all"           { return ALL; }
"information"   { ; }
"details"       { ; }
"of"            { ; }
"the"           { ; }
"a"             { ; }
"an"            { ; }
"students"      { return STUDENTS; }
"student"       { return STUDENTS; }
"roll"          { return ROLL; }
"number"        { ; }
"numbers"       { ; }
"name"          { return NAME; }
"cpi"           { return CPI; }
"and"           { return AND; }
"whose"         { return WHERE; }
"having"        { return WHERE; }
"where"         { return WHERE; }
"with"          { return WITH; }
"is"            { ; }
"more"          { return GT; }
"greater"       { return GT; }
"less"          { return LT; }
"than"          { ; }
"equal"         { return EQ; }
"equals"        { return EQ; }
"no"            { return NO; }
"update"        { return UPDATE; }
"set"           { ;}
"to"            { return TO; }
"insert"        { return INSERT; }
"add"           { return INSERT; }
"new_student"   { return NEW_STUDENT; }
"delete"        { return DELETE; }
"remove"        { return DELETE; }
"order"         { ; }
"sort"          { return ORDERBY; }
"sorted"        { return ORDERBY; }
"by"            { ; }
"ascending"     { return ASC; }
"asc"           { return ASC; }
"descending"    { return DESC; }
"desc"          { return DESC; }
"count"         { return COUNT; }
"how"           { return COUNT; }
"many"          { ; }
"total"         { return COUNT; }
"between"       { return BETWEEN; }
"values"        { ; }
"value"         { ; }

[0-9]+          { yylval.val = atoi(yytext); return NUM; }
[a-zA-Z]+       { yylval.str = strdup(yytext); return ID; }

%%