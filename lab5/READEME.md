# Check SQL Query Validation using Lex and Yacc

## 1. Language of the Grammar

The parser supports the following SQL statements:

* **SELECT** – Used to retrieve data from a table.
* **INSERT** – Used to insert new records into a table.
* **UPDATE** – Used to modify existing records in a table.
* **DELETE** – Used to remove records from a table.
* **CREATE TABLE** – Used to create a new table with specified columns.

The grammar recognizes simplified forms of these statements rather than the complete SQL standard. The purpose of the grammar is to demonstrate how a parser validates the structure of queries.

Examples of queries supported by the grammar:

```
SELECT * FROM students;
SELECT name,age FROM students WHERE id = 10;
```

The grammar is defined using **context-free grammar (CFG)** rules in Yacc. Each SQL statement is represented as a production rule that describes the correct arrangement of keywords, identifiers, and symbols.

---

## 2. Logic Behind the Rules in the Programs

The project uses two programs:

* **Lex (sql.l)** – Performs lexical analysis.
* **Yacc (sql.y)** – Performs syntax analysis using grammar rules.

### Lex Program Logic

The Lex program acts as a **tokenizer**. It reads the input SQL queries character by character and converts them into tokens that the parser can understand.

The main logic of the Lex rules is as follows:

1. **Keyword Recognition**

   Specific SQL keywords such as SELECT, INSERT, UPDATE, DELETE, CREATE, FROM, WHERE, VALUES, and TABLE are identified and returned as tokens. Case-insensitive patterns are used so that keywords can be written in uppercase or lowercase.

2. **Symbol Recognition**

   Symbols used in SQL statements are recognized and returned as tokens. Examples include:

   * `(` and `)` for parentheses
   * `,` for separating values or columns
   * `;` to terminate a query
   * `*` for selecting all columns
   * `=` for comparisons in conditions

3. **Identifiers**

   Identifiers represent names of tables or columns. They follow the pattern:

   ```
   [a-zA-Z_][a-zA-Z0-9_]*
   ```

   This allows identifiers to start with a letter or underscore and contain letters, digits, or underscores.

4. **Numbers**

   Numeric constants are matched using the pattern:

   ```
   [0-9]+
   ```

   These values are returned as numeric tokens.

5. **String Values**

   String literals enclosed in single quotes are matched using:

   ```
   '[^']*'
   ```

   This allows insertion or comparison of textual values.

6. **Whitespace Handling**

   Spaces, tabs, and newline characters are ignored so they do not affect the parsing process.

---

### Yacc Program Logic

The Yacc program defines the **grammar rules** used to validate SQL queries. The parser checks whether the sequence of tokens produced by Lex follows the defined grammar.

The main logic behind the grammar rules is described below.

#### Statement List

```
stmt_list : stmt SEMICOLON
          | stmt_list stmt SEMICOLON
```

This rule allows multiple SQL queries in a file. Each query must end with a semicolon.

---

#### Statement Types

```
stmt : select_stmt
     | insert_stmt
     | update_stmt
     | delete_stmt
     | create_stmt
```

This rule specifies the different SQL statements supported by the parser.

---

#### SELECT Statement

```
select_stmt : SELECT select_list FROM ID where_clause
```

This rule validates a SELECT query. The query must contain:

* the SELECT keyword
* either a column list or `*`
* the FROM keyword
* a table name
* an optional WHERE clause

---

#### Column Selection

```
select_list : STAR
            | column_list
```

This allows either selecting all columns (`*`) or specifying particular columns.

```
column_list : ID
            | ID COMMA column_list
```

This rule allows multiple column names separated by commas.

---

#### WHERE Clause

```
where_clause : WHERE condition
             |
```

The WHERE clause is optional. If present, it must contain a valid condition.

---

#### Conditions

```
condition : condition AND condition
          | ID EQ value
```

This rule allows comparisons between a column and a value. Multiple conditions can be connected using the AND operator.

---

#### Values

```
value : NUM
      | ID
      | STRING
```

Values used in queries can be numeric values, identifiers, or string literals.

---

#### INSERT Statement

```
insert_stmt : INSERT INTO ID VALUES LPAREN value_list RPAREN
```

This rule validates the syntax of an INSERT statement where values are inserted into a table.

```
value_list : value
           | value COMMA value_list
```

This allows inserting multiple values separated by commas.

---

#### UPDATE Statement

```
update_stmt : UPDATE ID SET ID EQ value where_clause
```

This rule updates a column value in a table. A WHERE clause may optionally restrict which rows are updated.

---

#### DELETE Statement

```
delete_stmt : DELETE FROM ID where_clause
```

This rule deletes records from a table, optionally based on a condition.

---

#### CREATE TABLE Statement

```
create_stmt : CREATE TABLE ID LPAREN col_list RPAREN
```

This rule validates table creation with column definitions.

```
col_list : col_def
         | col_def COMMA col_list
```

Multiple columns can be defined.

```
col_def : ID type
```

Each column must have a name and a datatype.

```
type : INT
     | VARCHAR LPAREN NUM RPAREN
```

The supported datatypes are INT and VARCHAR with a specified size.

---

## Conclusion
 The Lex program performs lexical analysis by identifying tokens, while the Yacc program verifies the syntax using grammar rules. By defining a subset of SQL grammar, the system can determine whether queries in a file follow the correct structure.

