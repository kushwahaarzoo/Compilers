README
Compiler Lab – LEX Programs
1. Overview

This repository contains two LEX (FLEX) programs developed as part of the CS321 Compiler Lab:

Java Comment Removal with Documentation Extraction

Removes single-line, multi-line, and documentation comments from a Java source file

Produces:

A cleaned .java file (without comments)

A .txt file containing only documentation comments (/** ... */) in readable form

HTML Tag Extraction and Occurrence Counting

Reads an HTML file

Extracts all HTML tags

Reports the number of occurrences of each tag

Both programs demonstrate lexical analysis using regular expressions and finite automata, which is the first phase of compiler design.

2. System Requirements

Operating System:
UNIX-based system (Ubuntu / WSL / Debian-based Linux)

Tools Required:

FLEX (LEX)

GCC Compiler

Installation
sudo apt update
sudo apt install flex gcc

3. How to Run the Java Comment Removal Program
Files Involved

lab_doc_remove.l → LEX source file

input.java → Java program with comments

output.java → Java program after comment removal

docs.txt → Extracted documentation comments

Compilation
lex lab_doc_remove.l
gcc lex.yy.c -o lab_doc_remove

Execution
./lab_doc_remove input.java output.java docs.txt

Result

output.java contains Java code with all comments removed

docs.txt contains only documentation comments, formatted for readability

4. How to Run the HTML Tag Extraction Program
Files Involved

lab3_q1.l → LEX program

input.html → HTML source file

Compilation
lex lab3_q1.l
gcc lex.yy.c -o lab3_q1

Execution
./lab3_q1 input.html

Result

Terminal displays each HTML tag and its occurrence count

5. Language / DFA of the Regular Expressions
5.1 Java Comment Removal Program

The language recognized by this lexer consists of:

Java comments:

Single-line comments: //.*

Multi-line comments: /* ... */

Documentation comments: /** ... */

Java source characters excluding comments

DFA Concept

The lexer operates using multiple start states:

INITIAL → normal Java code

COMMENT → inside /* ... */

DOC → inside /** ... */

Each start condition corresponds to a different DFA, allowing the lexer to correctly distinguish between:

code

normal comments

documentation comments

This approach is necessary because regular expressions alone are insufficient for reliably handling multi-line constructs.

5.2 HTML Tag Extraction Program

The language recognized includes:

Opening tags: <tagname>

Closing tags: </tagname>

Alphanumeric tag names

Regular expression form:

<[a-zA-Z][a-zA-Z0-9]*

</[a-zA-Z][a-zA-Z0-9]*

DFA Concept

The DFA transitions:

From < to a state expecting a letter

Continues consuming alphanumeric characters

Stops at whitespace or >

Each successful path corresponds to recognizing a valid HTML tag.

6. Logic Behind the Rules
6.1 Java Comment Removal Logic

Documentation comments (/** ... */)

Detected first to avoid confusion with normal multi-line comments

Contents are written to a .txt file

Multi-line comments (/* ... */)

Ignored completely

Single-line comments (// ...)

Ignored until newline

All other characters

Written to the output Java file

Start conditions ensure the lexer knows its context, which is critical in real compiler design.

6.2 HTML Tag Extraction Logic

When a tag is matched:

The tag name is extracted from yytext

A table is searched to check if the tag already exists

Count is incremented or initialized

Both opening and closing tags are counted

At the end of input, a summary report is printed

This demonstrates token recognition and symbol counting, similar to how identifiers are tracked in compilers.

7. Other Important Aspects
7.1 Use of yyin

Allows FLEX to read input from files instead of standard input

Essential for real-world compiler tools

7.2 Why Start Conditions Are Used

Multi-line constructs cannot be safely handled with a single regular expression

Start conditions model context-sensitive scanning, which is common in lexical analyzers

7.3 Relation to Compiler Phases

These programs represent the Lexical Analysis Phase

Tokens such as comments and tags are identified and processed before syntax analysis
