%{
#include "parser.tab.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int l_no=1;

#define MAX_TOKENS 4096
typedef struct{
int line;
char type[32];
char lexeme[64];
}TokenLog;

TokenLog token[MAX_TOKENS];
int token_n=0;

void info(int line,const char *type,const char *lexeme){
if(token_n<MAX_TOKENS){
token[token_n].line=line;
strncpy(token[token_n].type,type,31);
strncpy(token[token_n].lexeme,lexeme,63);
token_n++;
}
}

void print_token_log(){
printf("\nPHASE 1: Lexical Analysis is as follows \n");
printf("  %-6s %-16s %s\n\n","Line","Token Type","Lexeme");

for(int i=0;i<token_n;i++)
printf("  %-6d %-16s %s\n",token[i].line,token[i].type,token[i].lexeme);
printf("\n");
}
%}

%%

"int"       {info(l_no,"KEYWORD",yytext);return INT;}
"if"        {info(l_no,"KEYWORD",yytext);return IF;}
"else"      {info(l_no,"KEYWORD",yytext);return ELSE;}
"return"    {info(l_no,"KEYWORD",yytext);return RETURN;}
"while"     {info(l_no,"KEYWORD",yytext);return WHILE;}
"for"       {info(l_no,"KEYWORD",yytext);return FOR;}

[0-9]+      {yylval.ival=atoi(yytext);info(l_no,"NUMBER",yytext);return NUMBER;}

[a-zA-Z_][a-zA-Z0-9_]* {yylval.sval=strdup(yytext);info(l_no,"IDENTIFIER",yytext);return ID;}

"+"   {info(l_no,"OP +",yytext);return PLUS;  }
"-"  {info(l_no,"OP -",yytext);return MINUS;}
"*" {info(l_no,"OP *",yytext);return MUL; }
"/"   {info(l_no,"OP /",yytext);return DIV; }
"==" {info(l_no,"OP ==",yytext);return EQ;}
"!="   {info(l_no,"OP !=",yytext);return NEQ;}
"<=" {info(l_no,"OP <=",yytext);return LE;}
">=" {info(l_no,"OP >=",yytext);return GE;}
"<" {info(l_no,"OP <",yytext);return LT;}
">"    {info(l_no,"OP >",yytext);return GT;}
"&&" {info(l_no,"OP &&",yytext);return AND;}
"||"  {info(l_no,"OP ||",yytext);return OR;}
"!" {info(l_no,"OP !",yytext);return NOT;}
"="  {info(l_no,"OP =",yytext);return ASSIGN;}

"("  {info(l_no,"LPAREN",yytext);return LPAREN;}
")"    {info(l_no,"RPAREN",yytext);return RPAREN;}
"{"  {info(l_no,"LBRACE",yytext);return LBRACE;}
"}" {info(l_no,"RBRACE",yytext);return RBRACE;}
";"   {info(l_no,"SEMICOLON",yytext);return SEMICOLON;}
","   {info(l_no,"COMMA",yytext);return COMMA;}

[ \t\r]+    {}
\n          {l_no++;}

"//".*      {}
"/*"([^*]|\*+[^*/])*\*+"/" {}

.           {fprintf(stderr,"Lexical Error: UnIdentified character is found at'%s' at line %d\n",yytext,l_no);}

%%

int yywrap(){return 1;}