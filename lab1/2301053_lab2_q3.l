%{
#include <stdio.h>
#include <string.h>

#define MAX 100

struct tag {
    char name[50];
    int count;
} tags[MAX];

int tag_count = 0;

/* function to update tag count */
void add_tag(char *t)
{
    for (int i = 0; i < tag_count; i++)
    {
        if (strcmp(tags[i].name, t) == 0)
        {
            tags[i].count++;
            return;
        }
    }
    strcpy(tags[tag_count].name, t);
    tags[tag_count].count = 1;
    tag_count++;
}
%}

%%
"<"[a-zA-Z][a-zA-Z0-9]*   {
                            char tag[50];
                            sscanf(yytext, "<%[^ >]", tag);
                            add_tag(tag);
                          }

"</"[a-zA-Z][a-zA-Z0-9]*  {
                            char tag[50];
                            sscanf(yytext, "</%[^ >]", tag);
                            add_tag(tag);
                          }

.|\n                     ;
%%

int yywrap(void)
{
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        printf("Usage: %s <input.html>\n", argv[0]);
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

    printf("\nHTML Tag Occurred\n");
    for (int i = 0; i < tag_count; i++)
        printf("<%s> : %d\n", tags[i].name, tags[i].count);

    fclose(in);
    return 0;
}

