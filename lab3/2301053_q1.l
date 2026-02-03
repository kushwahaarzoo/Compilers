%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>

int day, month, year;

int getMonth(char *m) {
    char *months[] = { "jan","feb","mar","apr","may","jun", "jul","aug","sep","oct","nov","dec" };
    for (int i = 0; i < 12; i++)
        if (strcmp(months[i], m) == 0) return i + 1;
    return -1;
}

int isValidDate(int d, int m, int y) {
    int daysInMonth[] = { 31,28,31,30,31,30, 31,31,30,31,30,31 };
    if ((y % 400 == 0) || (y % 4 == 0 && y % 100 != 0))
        daysInMonth[1] = 29;
    if (y < 1 || m < 1 || m > 12 || d < 1) return 0;
    if (d > daysInMonth[m - 1]) return 0;
    return 1;
}
%}

%%
([0-2][0-9]|3[01])[-/.]([0][1-9]|1[0-2])[-/.][0-9]{4} {
    sscanf(yytext, "%d%*[-/.]%d%*[-/.]%d", &day, &month, &year);
    if (isValidDate(day, month, year)) {
        printf("Valid Date\nDay : %d\nMonth : %d\nYear : %d\n", day, month, year);
    } else {
        printf("Invalid Date\n");
    }
}
([0-2][0-9]|3[01])-[A-Za-z]{3}-[0-9]{4} {
    char mon[4];
    sscanf(yytext, "%d-%3s-%d", &day, mon, &year);
    for (int i = 0; mon[i]; i++) mon[i] = tolower(mon[i]);
    month = getMonth(mon);
    if (month != -1 && isValidDate(day, month, year)) {
        printf("Valid Date\nDay : %d\nMonth : %d\nYear : %d\n", day, month, year);
    } else {
        printf("Invalid Date\n");
    }
}
.* { printf("Invalid Date Format\n"); }
%%

int yywrap() { return 1; }

int main() {
    printf("Enter date: ");
    yylex();
    return 0;
}
