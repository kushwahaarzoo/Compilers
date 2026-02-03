# LEX Programs Report (lab 3) (03-02-2026)

## Question 1: Date Validation

### 1.1  DFA of Regular Expressions

The date validation program recognizes strings that belong to the language of **valid date formats**.

The accepted formats include:
- `dd-mm-yyyy`
- `dd/mm/yyyy`
- `dd.mm.yyyy`
- `dd-mmm-yyyy` (month in text form like Jan, Feb, etc.)

#### Language Description
- **Day**: `01` to `31`
- **Month (numeric)**: `01` to `12`
- **Month (text)**: `Jan` to `Dec` (2nd type)
- **Year**: Any 4-digit positive number
- **Separators**: `-`, `/`, `.`

The DFA idea is:
1. Start by reading two digits → day
2. Read a separator
3. Read either:
   - two digits (numeric month), or
   - three letters (text month)
4. Read a separator
5. Read four digits → year
6. Accept if the full pattern matches

Any deviation leads to rejection.

### 1.2 Logic Behind the Rules

- Regular expressions are used to **recognize valid date patterns**
- `sscanf()` is used to **extract day, month, and year**
- A helper function checks:
  - Valid day range
  - Valid month range
  - Leap year condition
- If all checks pass → date is valid
- Otherwise → invalid date message is printed

---
## Question 2: SQL Query Counter (DDL vs DML)

### 2.1 DFA of Regular Expressions

This program recognizes **SQL keywords** belonging to two categories:

#### DDL Language
- `CREATE`
- `DROP`
- `ALTER`
- `TRUNCATE`
- `RENAME`

#### DML Language
- `SELECT`
- `INSERT`
- `UPDATE`
- `DELETE`

The DFA idea:
1. Scan input character by character
2. Whenever a keyword is matched (case-insensitive), transition to:
   - DDL accepting state, or
   - DML accepting state
3. Increment the respective counter
4. Continue scanning until end of file

### 2.2 Logic Behind the Rules

- Each SQL keyword is matched using **case-insensitive regular expressions**
- When a DDL keyword is found → `ddl_count++`
- When a DML keyword is found → `dml_count++`
- All other characters are ignored
- Final counts are printed after scanning completes

---
## 3. Arithmetic Expression Recognition Program

### 3.1 DFA of Regular Expressions

The arithmetic expression language consists of:

#### Identifiers
- Start with a letter or underscore
- Followed by letters, digits, or underscores  
Example: `a`, `x1`, `_temp`

#### Operators
- `+`, `-`, `*`, `/`, `%`, `=`

#### Other Valid Tokens
- Numbers
- Parentheses `( )`
- Whitespace

The DFA idea:
1. Read characters sequentially
2. Identify whether the token is:
   - Identifier
   - Operator
   - Number
   - Parenthesis
3. If any unknown character appears → reject
### 3.2 Logic Behind the Rules

- Identifiers are stored uniquely using an array
- Operators are stored as they appear
- Numbers and parentheses are accepted but not stored
- If an invalid character is found → expression is marked invalid
- At the end:
  - If valid → identifiers and operators are printed
  - If invalid → error message is shown
---
