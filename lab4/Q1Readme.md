# Q1 Validation of Arithmetic Expressions using LEX and YACC

Implements a program using LEX and YACC to check whether a given arithmetic expression is valid or not. The program supports basic arithmetic operators such as addition (+), subtraction (-), multiplication (*), and division (/). It also supports identifiers, numbers, and parentheses.

The main objective of this program is to perform lexical analysis using LEX and syntax analysis using YACC. LEX is responsible for breaking the input expression into meaningful units called tokens, while YACC is responsible for checking whether these tokens follow the grammatical rules of arithmetic expressions.

The language accepted by this program consists of identifiers, numbers, operators, parentheses, and whitespace. Identifiers are defined using the regular expression:

[a-zA-Z_][a-zA-Z0-9_]*

This means that an identifier must start with a letter or underscore and can be followed by letters, digits, or underscores. Examples of valid identifiers are a, x1, and _temp.

Numbers are defined using the regular expression:

[0-9]+

This matches one or more digits and represents integer values such as 10, 25, and 100.

Operators are defined using the regular expression:

[+\-*/]

This matches the arithmetic operators +, -, *, and /.

Parentheses ( and ) are used for grouping expressions and are recognized directly. Whitespace characters such as spaces, tabs, and newlines are ignored by the program.

The behavior of these regular expressions can be understood using the concept of a Deterministic Finite Automaton (DFA). The DFA starts from an initial state and reads the input characters one by one. When a sequence of characters matches a valid pattern, the DFA moves to an accepting state and generates a corresponding token. If an invalid character is found, the DFA moves to an error state and the input is rejected.

Each type of token such as identifier, number, and operator has its own accepting state in the DFA. Once a token is recognized, it is sent to YACC for further processing.

The grammar used in YACC to validate arithmetic expressions is:

expr → expr + expr  
     | expr - expr  
     | expr * expr  
     | expr / expr  
     | ( expr )  
     | ID  
     | NUMBER  

This grammar defines all valid forms of arithmetic expressions. It ensures that every operator has operands on both sides and that parentheses are balanced properly.

Operator precedence is handled using the following declarations:

%left '+' '-'  
%left '*' '/'  

This means that multiplication and division have higher priority than addition and subtraction. For example, the expression a + b * c is interpreted as a + (b * c), not (a + b) * c. This removes ambiguity and helps YACC parse expressions correctly.

The logic of the LEX program is simple. When the input matches the identifier pattern, it returns the token ID. When digits are found, it returns the token NUMBER. When an operator is found, it returns the corresponding symbol. Parentheses are returned as they are. Whitespace is ignored. If any unknown character is found, it is treated as an error and causes the expression to be marked as invalid.

The logic of the YACC program is based on grammar rules. When tokens are received from LEX, YACC tries to match them with the grammar. If the input follows the grammar rules, parsing succeeds and the expression is considered valid. If the input violates any rule, YACC calls the error function and prints that the expression is invalid.

The execution of the program follows a clear sequence. First, the user enters an arithmetic expression. LEX scans the input and converts it into tokens. These tokens are passed to YACC. YACC applies grammar rules and checks operator precedence. If all rules are satisfied, the program prints that the expression is valid. Otherwise, it prints that the expression is invalid.

For example, the input (a+10)*b/2 is accepted as a valid arithmetic expression, 
while the input a++b is rejected as invalid.

However, the program also has some limitations. It does not evaluate the expression or compute its value. It does not perform semantic checking such as division by zero. It only checks syntactic correctness. To perform full validation and evaluation, additional semantic analysis would be required.

