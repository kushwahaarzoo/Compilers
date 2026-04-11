# Three Address Code Generator using Lex & Yacc

## 1. Language of the Grammar

The grammar implemented in this project represents a **subset of the C programming language**, specifically focusing on expressions and statements required for generating **Three Address Code (TAC)**.

The grammar supports:

* Variable declarations with initialization
* Assignment statements
* Arithmetic expressions (`+`, `-`, `*`, `/`)
* Relational expressions (`<`, `>`, `==`, `!=`)
* Logical expressions (`&&`, `||`, `!`)
* Increment (`++`) and compound assignment (`+=`)
* Basic `if` statements
* `return` statements

It does not cover the complete C language. Instead, it is a simplified grammar designed to demonstrate **intermediate code generation using Syntax Directed Translation (SDT)**.

---

## 2. Logic Behind the Rules in Each Program

### Lex Program (`2301053_Arzoo.l`)

The Lex program performs **lexical analysis**. It reads the input C file and converts it into tokens that are used by the parser.

The logic of the rules is:

* **Whitespace Handling**
  Spaces, tabs, and newlines are ignored so they do not affect parsing.

* **Preprocessor Directives**
  Lines starting with `#include` are ignored.

* **Keywords Handling**
  Keywords like `if` and `return` are recognized and returned as tokens.
  Data types such as `int`, `float`, etc., are treated as identifiers so that declarations can be parsed easily.

* **Identifiers**
  Variable names are matched using:

  ```
  [a-zA-Z_][a-zA-Z0-9_]*
  ```

  and returned as `ID`.

* **Numbers**
  Integer and floating-point values are matched and returned as `NUM`.

* **Operators**
  Logical, relational, and arithmetic operators (`&&`, `||`, `==`, `!=`, `+=`, `++`, etc.) are identified and returned as tokens.

* **Other Characters**
  Remaining symbols such as `(`, `)`, `{`, `}`, `;` are passed directly to the parser.

---

### Yacc Program (`2301053_Arzoo.y`)

The Yacc program performs **syntax analysis and code generation** using Syntax Directed Translation.

The logic of the grammar rules is:

* **Program Structure**

  ```
  program → elements
  ```

  The program consists of multiple elements, allowing flexible parsing of C code.

* **Elements**

  ```
  elements → elements element | ε
  ```

  This allows the parser to process the entire file sequentially.

* **Statements**

  ```
  stmt → declaration | assignment | if | return
  ```

  Each valid C statement is handled individually.

* **Declaration with Initialization**

  ```
  ID ID = exp ;
  ```

  This rule captures statements like:

  ```
  float balance = 1000.50;
  ```

  and generates TAC:

  ```
  balance = 1000.50
  ```

* **Assignment Statements**

  ```
  ID = exp ;
  ```

  Generates:

  ```
  a = t1
  ```

* **Compound Assignment and Increment**

  ```
  ID += exp ;
  ID ++ ;
  ```

  These are converted into standard TAC using temporary variables:

  ```
  t1 = a + b
  a = t1
  ```

* **Expressions**
  Expressions are handled recursively:

  ```
  exp → exp + exp
       | exp * exp
       | ( exp )
       | ID
       | NUM
  ```

  For each operation, a new temporary variable is created:

  ```
  t1 = b * c
  t2 = a + t1
  ```

* **Logical and Relational Expressions**

  ```
  exp → exp && exp
       | exp || exp
       | exp < exp
       | exp == exp
  ```

  These generate TAC in the form:

  ```
  t1 = a < b
  t2 = t1 && c
  ```

* **If Statement**

  ```
  if (exp) { ... }
  ```

  The condition is evaluated, and the block is processed.
  (Simplified handling without full jump/backpatching logic.)

* **Return Statement**

  ```
  return exp ;
  ```

  Generates:

  ```
  return
  ```
# Future Improvements
* Implement backpatching
* Add support for
  : else, while, for
* Function calls
* Generate optimized TAC
* Improve logical expression handling
