# Basic Compiler like C
## Overview

This project implements a **mini compiler** using **Lex (Flex)** and **Yacc (Bison)**. It performs multiple phases of compilation including:

* Lexical Analysis
* Syntax Analysis
* Semantic Analysis
* Intermediate Code Generation (Three-Address Code)
* Code Optimization
* Target machine code Generation

The compiler supports a subset of a C-like language with control structures, expressions, and variable handling.

---

##  Compiler Architecture

The compiler follows the classical pipeline:

```
Source Code
     ↓
Lexical Analyzer (Lexer)
     ↓
Syntax Analyzer (Parser)
     ↓
Semantic Analysis (Symbol Table)
     ↓
Intermediate Code Generation (TAC)
     ↓
Optimization Phase
     ↓
Output (Target machine code generation)
```

### Components:

* **Lexer (`.l file`)** → Tokenizes input
* **Parser (`.y file`)** → Validates syntax & builds structure
* **Symbol Table** → Stores variables and metadata
* **TAC Generator** → Produces intermediate code
* **Optimizer** → Improves generated code

---

## Lexical Analysis Phase

The lexer identifies tokens such as:

### Keywords

* `int`, `if`, `else`, `while`, `for`, `return`

### Identifiers & Constants

* Identifiers: `[a-zA-Z_][a-zA-Z0-9_]*`
* Numbers: `[0-9]+`

### Operators

* Arithmetic: `+ - * /`
* Relational: `< > <= >= == !=`
* Logical: `&& || !`
* Assignment: `=`

### Delimiters

* `() { } ; ,`

### Additional Features

* Skips whitespace and comments
* Tracks line numbers
* Reports lexical errors for unknown characters

---

##  Syntax Analysis Phase

The parser:

* Uses **Yacc/Bison grammar rules**
* Ensures correct structure of programs
* Handles:

  * Expressions
  * Conditional statements (`if-else`)
  * Loops (`while`, `for`)
  * Assignments
  * Blocks `{}`

### Parser Type

* **LALR(1) Bottom-Up Parser**

---

## Semantic Analysis Phase

Semantic checks implemented:

* Variable declaration before use
* Duplicate declaration detection
* Symbol table management
* Initialization tracking

### Symbol Table Structure

Each entry contains:

* Variable name
* Type (`int`)
* Value
* Initialization status

---

##  Intermediate Code Generation

The compiler generates **Three-Address Code (TAC)**.

### TAC Format

```
t1 = a + b
t2 = t1 * c
x = t2
```

### Supported Instructions

* Assignment: `x = y`
* Unary: `x = -y`
* Binary: `x = y op z`
* Conditional jump: `if false x goto L1`
* Unconditional jump: `goto L1`
* Labels: `L1:`

---

##  Optimization Phase

Two main optimizations are implemented(will add more feature later):

### 1. Constant Propagation

* Replaces variables with constant values where possible
* Example:

  ```
  a = 5
  b = a
  → b = 5
  ```

### 2. Common Subexpression Elimination (CSE)

* Avoids recomputation of identical expressions
* Example:

  ```
  t1 = a + b
  t2 = a + b
  → reuse t1
  ```

### Additional Behavior

* Invalidates expressions when variables change
* Clears optimization state at control flow boundaries

---

## Core Grammar (Conceptual)

The grammar supports:

### Program Structure

```
program → statements
```

### Statements

```
statement →
      declaration
    | assignment
    | if_statement
    | while_loop
    | for_loop
    | return_statement
```

### Expressions

```
expr →
      expr + expr
    | expr - expr
    | expr * expr
    | expr / expr
    | (expr)
    | id
    | number
```

---

## Supported Instruction Subset

The compiler handles a subset of C-like codes:

### Data Types

* `int` 

### Statements

* Variable declaration
* Assignment
* `if-else`
* `while`
* `for`
* `return`

### Expressions

* Arithmetic expressions
* Logical expressions
* Relational expressions

---

## Compilation Phases Summary

| Phase                            | Description                         |
| -------------------------------- | ----------------------------------- |
| **Lexical Analysis**             | Converts source code into tokens    |
| **Syntax Analysis**              | Validates grammar using parser      |
| **Semantic Analysis**            | Checks meaning & symbol correctness |
| **Intermediate Code Generation** | Produces TAC                        |
| **Optimization**                 | Improves TAC efficiency             |

---

##  Output

The compiler produces:

1. **Lexical Analysis**
2. **Syntax Analysis**
3. **Semantics Analysis**
4.  **Intermediate Code Generation**
5. **Optimized TAC**
6. **Target Code Generation**

---

## How to Run

```bash
lex 2301053_Arzoo.l
yacc -d 2301053_Arzoo.y
gcc lex.yy.c y.tab.c -o out
./out input.c
```

---

## Conclusion

This project contains a complete **mini compiler pipeline**, integrating:

* Frontend (Lex + Yacc)
* Semantic processing
* Intermediate representation
* Optimization techniques
---
