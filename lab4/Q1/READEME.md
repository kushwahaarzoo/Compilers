# LL(1) Parser Report

## Introduction

This project implements an LL(1) parser in C. The program takes a grammar as input from the user, calculates the FIRST and FOLLOW sets for all non-terminals, builds an LL(1) parsing table, and then uses this table to check whether a given input string is valid or not.

The grammar used is a basic arithmetic expression grammar containing operators, identifiers, and parentheses.

---

## Language and DFA
 
Example grammar rules are:

E → TA  
A → +TA | #  
T → FB  
B → *FB | #  
F → (E) | i  

Here, `#` represents epsilon (empty string).

The tokens such as `i`, `+`, `*`, `(`, and `)` can be recognized using simple regular expressions and DFAs. For example:

- `i` represents identifiers
- `+` represents addition
- `*` represents multiplication

A DFA can be used to scan and recognize these symbols before parsing.

---

## Meaning of LL(1)

LL(1) stands for:

- L: Input is read from Left to Right  
- L: Leftmost derivation is used  
- 1: Only one input symbol is checked at a time  

This means the parser decides which rule to apply by looking at only one symbol ahead.

---

## Logic of the Program

The program follows these main steps:

1. The grammar is entered by the user.
2. Non-terminals and terminals are identified.
3. FIRST sets are calculated.
4. FOLLOW sets are calculated.
5. The LL(1) parsing table is created.
6. FIRST and FOLLOW sets are displayed.
7. The input string is parsed using the table.
8. The program prints whether the string is accepted or rejected.

---

## FIRST Set

The FIRST set of a non-terminal contains the terminal symbols that can appear at the beginning of strings derived from it.

Rules for FIRST:

- If a rule starts with a terminal, it is added to FIRST.
- If it starts with a non-terminal, its FIRST set is added.
- If epsilon occurs, the next symbol is checked.

The program uses the `findFirst()` function to calculate FIRST sets.

---

## FOLLOW Set

The FOLLOW set of a non-terminal contains the terminal symbols that can appear after it in any valid string.

Rules for FOLLOW:

- `$` is added to the start symbol.
- If a non-terminal is followed by a terminal, it is added to FOLLOW.
- If it is followed by another non-terminal, FIRST of that is added.
- If epsilon occurs, FOLLOW of the left side is added.

The program uses the `findFollow()` function to calculate FOLLOW sets.

---

## Construction of Parsing Table

After FIRST and FOLLOW are calculated, the parsing table is built.

- Rows contain non-terminals.
- Columns contain terminals.
- Rules are filled using FIRST and FOLLOW.

Steps:

- If a terminal is in FIRST of a rule, that rule is placed in the table.
- If epsilon is in FIRST, the rule is placed under FOLLOW.

The `buildTable()` function performs this work.

---

## Parsing Process

The parser uses a stack to check the input string.

Steps:

1. `$` and start symbol are pushed onto the stack.
2. Input is read from left to right.
3. If stack top matches input, both are removed.
4. If stack top is a non-terminal, the parsing table gives the rule.
5. The rule is applied by pushing symbols onto the stack.
6. If both stack and input reach `$`, the string is accepted.

Otherwise, it is rejected.

---

## Example

Grammar:

E=TA  
A=+TA  
A=#  
T=FB  
B=*FB  
B=#  
F=(E)  
F=i  

Input:

i+i*i$

Output:

accepted string

---


## Limitations

- Does not support left recursion
- Requires grammar to be LL(1)
- Grammer should be unambigious
- Grammer should be free from left prefix or should not be left factored 

---
