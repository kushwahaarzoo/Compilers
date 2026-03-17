#include <stdio.h>

#define MAX 100

char stack[MAX];
int top = -1;

void push(char c) {
    top++;
    stack[top] = c;
}

char pop() {
    char c = stack[top];
    top--;
    return c;
}

int isEmpty() {
    if (top == -1)
        return 1;
    return 0;
}

int isOpen(char c) {
    if (c == '(' || c == '{' || c == '[')
        return 1;
    return 0;
}

int isClose(char c) {
    if (c == ')' || c == '}' || c == ']')
        return 1;
    return 0;
}

int isMatch(char open, char close) {
    if (open == '(' && close == ')')
        return 1;
    if (open == '{' && close == '}')
        return 1;
    if (open == '[' && close == ']')
        return 1;
    return 0;
}

int isLetter(char c) {
    if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z'))
        return 1;
    return 0;
}

int isDigit(char c) {
    if (c >= '0' && c <= '9')
        return 1;
    return 0;
}

int isOperator(char c) {
    if (c == '+' || c == '-' || c == '*' || c == '/' ||
        c == '=' || c == '<' || c == '>' || c == '%')
        return 1;
    return 0;
}

int isValid(char c) {
    if (isLetter(c) || isDigit(c) || isOperator(c) || isOpen(c) || isClose(c))
        return 1;
    return 0;
}

int isCompound(char a, char b) {
    if ((a == '+' || a == '-' || a == '*' || a == '/') && b == '=')
        return 1;
    return 0;
}

int length(char expr[]) {
    int i = 0;
    while (expr[i] != '\0')
        i++;
    return i;
}

int checkExpression(char expr[]) {
    int i = 0;
    int len = length(expr);

    while (expr[i] != '\0') {
        char c = expr[i];

        if (!isValid(c)) {
            printf("Invalid character found\n");
            return 0;
        }

        if (isOperator(c)) {
            if (i == 0 || i == len - 1) {
                printf(" Operator at start or end\n");
                return 0;
            }
        }

        if (isOperator(c) && isOperator(expr[i + 1])) {
            if (!isCompound(c, expr[i + 1])) {
                printf("Two operators together \n");
                return 0;
            }
        }

        if (isOpen(c) && isOperator(expr[i + 1])) {
            printf("Operator after opening bracket\n");
            return 0;
        }

        if (isOperator(c) && isClose(expr[i + 1])) {
            printf("There is Operator before closing bracket\n");
            return 0;
        }

        if ((isLetter(c) || isDigit(c)) && (isLetter(expr[i + 1]) || isDigit(expr[i + 1]))) {
            printf("Two operands side by side \n");
            return 0;
        }

        i++;
    }
    return 1;
}

int checkBrackets(char expr[]) {
    int i = 0;
    while (expr[i] != '\0') {
        char c = expr[i];
        if (isOpen(c)) {
            push(c);
        }
        else if (isClose(c)) {
            if (isEmpty())
                return 0;
            char open = pop();
            if (!isMatch(open, c))
                return 0;
        }
        i++;
    }
    if (isEmpty())
        return 1;
    return 0;
}

int main() {
    char expr[MAX];

    printf("Enter expression: ");
    scanf("%s", expr);
    if (!checkExpression(expr)) {
        printf("Not Well-formed\n");
        return 0;
    }
    if (!checkBrackets(expr)) {
        printf("Not Well-formed bracket mismatch\n");
        return 0;
    }
    printf("Well-formed\n");
    return 0;
}