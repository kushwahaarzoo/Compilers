#include <stdio.h>
#include <string.h>

#define MAX_RULES 10
#define MAX_STACK 50
#define MAX_INPUT 20

struct Rule {
    char lhs[10];
    char rhs[10];
};

void readRules(struct Rule rules[], int *n);
void readInput(char input[]);
void printState(char stack[], int pos, char input[], const char *action);
void shift(char stack[], char c, int pos, char input[]);
int  reduce(char stack[], struct Rule rules[], int n, int pos, char input[]);

int main() {
    char stack[MAX_STACK] = "";
    char input[MAX_INPUT];
    struct Rule rules[MAX_RULES];
    int n = 0, i = 0;

    readRules(rules, &n);
    readInput(input);

    int len = strlen(input);

    while (1) {
        if (i < len)
            shift(stack, input[i++], i, input);

        while (reduce(stack, rules, n, i, input));

        if (strcmp(stack, rules[0].lhs) == 0 && i == len) {
            printf("\nAccepted\n");
            break;
        }
        if (i == len) {
            printf("\nNot Accepted\n");
            break;
        }
    }
    return 0;
}

void readRules(struct Rule rules[], int *n) {
    char buf[50];
    printf("Enter number of rules: ");
    scanf("%d", n);
    printf("\n");
    printf("Enter rules (lhs->rhs):\n");
    for (int i = 0; i < *n; i++) {
        scanf("%s", buf);
        strcpy(rules[i].lhs, strtok(buf, "->"));
        strcpy(rules[i].rhs, strtok(NULL, "->"));
    }
}

void readInput(char input[]) {
    printf("\n");
    printf("Enter input string: ");
    scanf("%s", input);
    printf("\n");
}

void printState(char stack[], int pos, char input[], const char *action) {
    printf("%-20s", stack);
    for (int k = pos; k < (int)strlen(input); k++)
        printf("%c", input[k]);
    printf("\t\t%s\n", action);
}

void shift(char stack[], char c, int pos, char input[]) {
    int len = strlen(stack);
    stack[len] = c;
    stack[len + 1] = '\0';
    char label[20];
    sprintf(label, "Shift %c", c);
    printState(stack, pos, input, label);
}

int reduce(char stack[], struct Rule rules[], int n, int pos, char input[]) {
    for (int i = 0; i < n; i++) {
        char *match = strstr(stack, rules[i].rhs);
        if (match) {
            char tmp[MAX_STACK] = "";
            strncat(tmp, stack, match - stack);
            strcat(tmp, rules[i].lhs);
            strcat(tmp, match + strlen(rules[i].rhs));
            strcpy(stack, tmp);
            char label[30];
            sprintf(label, "Reduce %s->%s", rules[i].lhs, rules[i].rhs);
            printState(stack, pos, input, label);
            return 1;
        }
    }
    return 0;
}