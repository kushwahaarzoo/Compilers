# Question 1: Comment Removal using LEX from java code

This LEX program removes:
- Single-line comments (`// ...`)
- Multi-line comments (`/* ... */`)

and prints only the **actual program code**.

## 1. Language / DFA of the Regular Expressions

---

### 1.1 Single-Line Comment

**Regex:** `"//".*`

**Language:**
- All strings that start with `//`
- Followed by any characters until the end of the line
- Represents a single-line comment in Java

**DFA Diagram:**

(q0) -- '/' --> (q1) -- '/' --> (q2)  
(q2) -- any character except '\n' --> (q2)

**Action:**
- Entire comment line is ignored (removed)

---

### 1.2 Start of Multi-Line Comment

**Regex:** `"/*"`

**Language:**
- The exact string `/*`
- Represents the beginning of a multi-line comment

**DFA Diagram:**

(q0) -- '/' --> (q1) -- '*' --> (COMMENT)

**Action:**
- Switch to COMMENT state using `BEGIN(COMMENT)`

---

### 1.3 End of Multi-Line Comment

**Regex:** `"*/"`

**Language:**
- The exact string `*/`
- Represents the end of a multi-line comment

**DFA Diagram (COMMENT state):**

(COMMENT) -- '*' --> (q1) -- '/' --> (INITIAL)

**Action:**
- Exit COMMENT state
- Return to INITIAL state

---

### 1.4 Content Inside Multi-Line Comment

**Regex:** `.|\n`

**Language:**
- All characters including newline
- Occurring inside a multi-line comment

**DFA Diagram:**

(COMMENT) -- any character or '\n' --> (COMMENT)

**Action:**
- Ignore all characters inside multi-line comments

---

### 1.5 Normal Program Code

**Regex:** `.|\n`

**Language:**
- Any character or newline
- Outside comment regions

**DFA Diagram:**

(INITIAL) -- any character or '\n' --> (INITIAL)

**Action:**
- Print the character using `printf`
- This preserves valid program code

---

## 2. Logic Behind the Rules

- Single-line comments (`// ...`) are matched and removed immediately.
- When `/*` is detected, the lexer enters the COMMENT state.
- All characters inside COMMENT state are ignored.
- When `*/` is found, the lexer exits COMMENT state.
- Any character outside comments is printed as valid code.
- The program effectively strips all comments from source code.



# Question 2: Counting HTML Tags using LEX

## 1. Language / DFA of the Regular Expressions

---

### 1.1 HTML Tag

**Regex:** `"<html>" | "</html>"`

**Language:**
- The language consists of the strings `<html>` and `</html>`.
- These represent the opening and closing HTML tags.

**DFA Diagram:**

(q0) -- '<' --> (q1) -- 'h' --> (q2) -- 't' --> (q3) -- 'm' --> (q4) -- 'l' --> (q5) -- '>' --> (ACCEPT)

(q0) -- '<' --> (q1) -- '/' --> (q2') -- 'h' --> (q3') -- 't' --> (q4') -- 'm' --> (q5') -- 'l' --> (q6') -- '>' --> (ACCEPT)

---

### 1.2 HEAD Tag

**Regex:** `"<head>" | "</head>"`

**Language:**
- Contains the strings `<head>` and `</head>`.
- Represents opening and closing HEAD tags.

**DFA Diagram:**

(q0) -- '<' --> (q1) -- 'h' --> (q2) -- 'e' --> (q3) -- 'a' --> (q4) -- 'd' --> (q5) -- '>' --> (ACCEPT)

(q0) -- '<' --> (q1) -- '/' --> (q2') -- 'h' --> (q3') -- 'e' --> (q4') -- 'a' --> (q5') -- 'd' --> (q6') -- '>' --> (ACCEPT)

---

### 1.3 TITLE Tag

**Regex:** `"<title>" | "</title>"`

**Language:**
- Contains `<title>` and `</title>`.
- Represents TITLE tags in an HTML document.

**DFA Diagram:**

(q0) -- '<' --> (q1) -- 't' --> (q2) -- 'i' --> (q3) -- 't' --> (q4) -- 'l' --> (q5) -- 'e' --> (q6) -- '>' --> (ACCEPT)

(q0) -- '<' --> (q1) -- '/' --> (q2') -- 't' --> (q3') -- 'i' --> (q4') -- 't' --> (q5') -- 'l' --> (q6') -- 'e' --> (q7') -- '>' --> (ACCEPT)

---

### 1.4 BODY Tag

**Regex:** `"<body>" | "</body>"`

**Language:**
- Contains `<body>` and `</body>`.
- Represents BODY tags in HTML.

**DFA Diagram:**

(q0) -- '<' --> (q1) -- 'b' --> (q2) -- 'o' --> (q3) -- 'd' --> (q4) -- 'y' --> (q5) -- '>' --> (ACCEPT)

(q0) -- '<' --> (q1) -- '/' --> (q2') -- 'b' --> (q3') -- 'o' --> (q4') -- 'd' --> (q5') -- 'y' --> (q6') -- '>' --> (ACCEPT)

---

### 1.5 Paragraph Tag

**Regex:** `"<p>" | "</p>"`

**Language:**
- Contains `<p>` and `</p>`.
- Represents paragraph tags in HTML.

**DFA Diagram:**

(q0) -- '<' --> (q1) -- 'p' --> (q2) -- '>' --> (ACCEPT)

(q0) -- '<' --> (q1) -- '/' --> (q2') -- 'p' --> (q3') -- '>' --> (ACCEPT)

---

### 1.6 Other Characters

**Regex:** `.|\n`

**Language:**
- Contains all characters and newline symbols that are not part of the specified HTML tags.

**DFA Diagram:**

(q0) -- any character or '\n' --> (q0)

---

## 2. Logic Behind the Rules

- Each HTML opening and closing tag is matched using regular expressions.
- When a specific tag is matched, its corresponding counter is incremented.
- Both opening and closing tags are counted.
- Characters that are not relevant HTML tags are ignored.
- After lexical analysis, the total count of each HTML tag is displayed.


# Question 3 : Documentation Comment Extraction using LEX from java code
## 1. Language / DFA of the Regular Expressions
### 1.1 Documentation Comment Start

**Regex:** `"/**"`

**Language:**
- The language contains the exact string `/**`.
- This marks the beginning of a documentation comment in Java.

**DFA Diagram:**

(q0) -- '/' --> (q1) -- '*' --> (q2) -- '*' --> (DOC)

---

### 1.2 Normal Multi-Line Comment Start

**Regex:** `"/*"`

**Language:**
- The language contains the exact string `/*`.
- Represents the start of a normal multi-line comment.

**DFA Diagram:**

(q0) -- '/' --> (q1) -- '*' --> (COMMENT)

---

### 1.3 Single-Line Comment

**Regex:** `"//".*`

**Language:**
- All strings starting with `//` followed by any characters till the end of the line.

**DFA Diagram:**

(q0) -- '/' --> (q1) -- '/' --> (q2)
(q2) -- any char except '\n' --> (q2)

---

### 1.4 Documentation Comment End

**Regex:** `"*/"`

**Language:**
- The exact string `*/`.
- Marks the end of a documentation comment.

**DFA Diagram (in DOC state):**

(DOC) -- '*' --> (q1) -- '/' --> (INITIAL)

---

### 1.5 Content Inside Documentation Comment

**Regex:** `.|\n`

**Language:**
- All characters and newline symbols inside documentation comments.

**DFA Diagram:**

(DOC) -- any character or '\n' --> (DOC)

---

### 1.6 End of Normal Multi-Line Comment

**Regex:** `"*/"`

**Language:**
- The exact string `*/`.
- Ends a normal multi-line comment.

**DFA Diagram (in COMMENT state):**

(COMMENT) -- '*' --> (q1) -- '/' --> (INITIAL)

---

### 1.7 Content Inside Normal Multi-Line Comment

**Regex:** `.|\n`

**Language:**
- All characters and newlines inside normal multi-line comments.

**DFA Diagram:**

(COMMENT) -- any character or '\n' --> (COMMENT)

---

### 1.8 Normal Program Code

**Regex:** `.|\n`

**Language:**
- All characters and newline symbols outside comments.

**DFA Diagram:**

(INITIAL) -- any character or '\n' --> (INITIAL)

---

## 2. Logic Behind the Rules

- Documentation comments (`/** ... */`) are detected and extracted into a separate file.
- Normal multi-line comments (`/* ... */`) are completely ignored.
- Single-line comments (`// ...`) are removed.
- The `DOC` state ensures only documentation comments are processed.
- The `COMMENT` state ensures normal comments are skipped.
- All valid Java code outside comments is printed normally.
