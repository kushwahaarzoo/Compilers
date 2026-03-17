## Program 1: Well-Formed Expression Checker
 
### 1. Language of the Grammar
 
This program checks expressions written in a simplified grammar of **algebraic and assignment expressions**. The language it accepts includes:
 
- **Operands**: single letters (`a`–`z`, `A`–`Z`) and digits (`0`–`9`)
- **Operators**: `+`, `-`, `*`, `/`, `=`, `<`, `>`, `%`
- **Compound Operators**: `+=`, `-=`, `*=`, `/=`
- **Brackets**: `(`, `)`, `{`, `}`, `[`, `]`
 
Valid example expressions:
 
```
(a+b)*c
{[(a=b+c)]}
a+={b+c}
{}[]({})
```
 
This grammar is a subset of expressions found in **C-like programming languages**, covering arithmetic, relational, and assignment expressions.
 
### 2. Logic Behind the Rules
 
The program uses a **stack-based bracket matching** approach combined with **sequential expression validation**. Each function enforces a specific grammar rule.
 
#### Rule: Valid Characters Only — `isValid()`
 
Only letters, digits, operators, and brackets are permitted. Any other character (like `#`, `@`, `!`) is immediately rejected.
 
**Reason:** A well-formed expression can only contain meaningful tokens. Unknown characters indicate a syntax error.
 
#### Rule: Operator Position — `checkExpression()`
 
An operator cannot appear at the very start or end of an expression.
 
```
+a+b   → rejected (operator at start)
a+b+   → rejected (operator at end)
```
 
**Why:** An operator must always have an operand on both its left and right sides. Without this, the expression is incomplete.
 
#### Rule: No Two Operators Together — `isCompound()`
 
Two operators side by side are invalid unless they form a compound operator (`+=`, `-=`, `*=`, `/=`).
 
```
a++b   → rejected (two plain operators)
a+=b   → accepted (compound operator)
```
 
**Why:** Back-to-back operators with no operand between them is a syntax error in standard expressions. Compound operators are a special exception because they are single meaningful tokens in C-like languages.
 
#### Rule: No Operator After Opening Bracket
 
An operator cannot immediately follow an opening bracket.
 
```
(+a+b)  → rejected
```
 
**Why:** The first thing inside a bracket must be an operand or another opening bracket, not an operator.
 
#### Rule: No Operator Before Closing Bracket
 
An operator cannot immediately precede a closing bracket.
 
```
(a+b+)  → rejected
```
 
**Why:** The last item before a closing bracket must be an operand or another closing bracket, ensuring the sub-expression inside is complete.
 
#### Rule: No Two Operands Together
 
Two letters or digits cannot appear side by side without an operator between them.
 
```
ab+c   → rejected
12+c   → rejected
```
 
**Why:** Every pair of operands must be separated by an operator. Adjacent operands have no defined meaning in standard expression grammar.
 
#### Rule: Bracket Matching — `checkBrackets()`
 
Every opening bracket must have a corresponding closing bracket of the same type, in the correct order.

## Program 1: Shift-Reduce Parser
 
### 1. Language of the Grammar
 
The shift-reduce parser accepts any **Context-Free Grammar (CFG)** provided by the user at runtime. The language recognized depends entirely on the production rules entered. For example, with the rules:
 
```
E -> E+T
E -> T
T -> id
```
 
The language recognized is **arithmetic expressions** made of `id` tokens connected by `+` operators, such as:
 
```
id+id
id+id+id
```
 
This is a subset of **arithmetic expression grammar**, a classic example used in compiler design to demonstrate bottom-up parsing.
 
### 2. Logic Behind the Rules
 
The parser uses the **Shift-Reduce parsing** technique, which is a bottom-up parsing strategy. It reads input left to right and tries to build the parse tree from leaves to root.
 
#### Core Rules of Operation
 
**Shift Rule:**
- Read the next character from input and push it onto the stack.
- This happens when no reduction is currently possible.
- Example: input `id+id`, read `i`, push to stack → stack becomes `i`.
 
**Reduce Rule:**
- Scan the stack for any substring that matches the right-hand side (RHS) of a production rule.
- Replace that substring with the left-hand side (LHS) of the matching rule.
- Example: stack has `id`, rule `T->id` matches → replace `id` with `T`.
 
**Repeat Rule:**
- After every reduction, immediately check again for more reductions before shifting.
- This ensures that newly formed non-terminals are reduced as soon as possible.
 
**Accept Rule:**
- If the stack contains only the start symbol (LHS of the first rule) AND all input has been consumed, the string is **Accepted**.
 
**Reject Rule:**
- If all input is consumed but the stack does not reduce to the start symbol, the string is **Not Accepted**.
 
