%{
#include <stdio.h>
#include <string.h>
void yyerror(char *s);
int yylex();
%}

%union {
    int   val;
    char *str;
}

%token PLEASE GET ALL STUDENTS ROLL NAME CPI AND WHERE GT LT EQ NO
%token UPDATE SET TO
%token INSERT NEW_STUDENT WITH VALUES
%token DELETE
%token ORDERBY ASC DESC
%token COUNT
%token BETWEEN
%token END

%token <val> NUM
%token <str> ID

%type <str> column_list

%%

program:
    program stmt      {printf("\n");}
    | stmt        {printf("\n");}
    ;

stmt:
    PLEASE GET request END    { printf(";\n"); }
    | GET request END         { printf(";\n"); }
    | update_stmt END         { printf(";\n"); }
    | insert_stmt END         { printf(";\n"); }
    | delete_stmt END         { printf(";\n"); }
    ;

request:
    ALL STUDENTS
        { printf("Output: select * from Student"); }

    | column_list STUDENTS
        { printf("Output: select %s from Student", $1); }

    | column_list STUDENTS WHERE CPI GT NUM
        { printf("Output: select %s from Student where cpi > %d", $1, $6); }

    | column_list STUDENTS WHERE CPI LT NUM
        { printf("Output: select %s from Student where cpi < %d", $1, $6); }

    | column_list STUDENTS WHERE CPI EQ NUM
        { printf("Output: select %s from Student where cpi = %d", $1, $6); }

    | column_list STUDENTS WHERE ROLL EQ NUM
        { printf("Output: select %s from Student where roll = %d", $1, $6); }

    | column_list STUDENTS WHERE ROLL GT NUM
        { printf("Output: select %s from Student where roll > %d", $1, $6); }

    | ALL STUDENTS ORDERBY NAME ASC
        { printf("Output: select * from Student order by name asc"); }

    | ALL STUDENTS ORDERBY NAME DESC
        { printf("Output: select * from Student order by name desc"); }

    | ALL STUDENTS ORDERBY ROLL ASC
        { printf("Output: select * from Student order by roll asc"); }

    | ALL STUDENTS ORDERBY ROLL DESC
        { printf("Output: select * from Student order by roll desc"); }

    | ALL STUDENTS ORDERBY CPI ASC
        { printf("Output: select * from Student order by cpi asc"); }

    | ALL STUDENTS ORDERBY CPI DESC
        { printf("Output: select * from Student order by cpi desc"); }

    | column_list STUDENTS ORDERBY CPI DESC
        { printf("Output: select %s from Student order by cpi desc", $1); }

    | column_list STUDENTS ORDERBY CPI ASC
        { printf("Output: select %s from Student order by cpi asc", $1); }

    | column_list STUDENTS ORDERBY ROLL ASC
        { printf("Output: select %s from Student order by roll asc", $1); }

    | column_list STUDENTS ORDERBY ROLL DESC
        { printf("Output: select %s from Student order by roll desc", $1); }

    | column_list STUDENTS WHERE CPI GT NUM ORDERBY CPI DESC
        { printf("Output: select %s from Student where cpi > %d order by cpi desc", $1, $6); }

    | column_list STUDENTS WHERE CPI GT NUM ORDERBY CPI ASC
        { printf("Output: select %s from Student where cpi > %d order by cpi asc", $1, $6); }

    | COUNT STUDENTS
        { printf("Output: select count(*) from Student"); }

    | COUNT STUDENTS WHERE CPI GT NUM
        { printf("Output: select count(*) from Student where cpi > %d", $6); }

    | COUNT STUDENTS WHERE CPI LT NUM
        { printf("Output: select count(*) from Student where cpi < %d", $6); }

    | ALL STUDENTS WHERE CPI BETWEEN NUM AND NUM
        { printf("Output: select * from Student where cpi between %d and %d", $6, $8); }

    | column_list STUDENTS WHERE CPI BETWEEN NUM AND NUM
        { printf("Output: select %s from Student where cpi between %d and %d", $1, $6, $8); }
    ;

column_list:
    NAME                     { $$ = "name"; }
    | ROLL                   { $$ = "roll"; }
    | CPI                    { $$ = "cpi";  }
    | NAME AND ROLL          { $$ = "name, roll"; }
    | ROLL AND NAME          { $$ = "roll, name"; }
    | NAME AND CPI           { $$ = "name, cpi";  }
    | CPI  AND NAME          { $$ = "cpi, name";  }
    | ROLL AND CPI           { $$ = "roll, cpi";  }
    | CPI  AND ROLL          { $$ = "cpi, roll";  }
    | NAME AND ROLL AND CPI  { $$ = "name, roll, cpi"; }
    | ROLL AND NAME AND CPI  { $$ = "roll, name, cpi"; }
    ;

update_stmt:
    PLEASE UPDATE CPI STUDENTS WHERE ROLL NO NUM TO NUM
        { printf("Output: update Student set cpi = %d where roll = %d", $10, $8); }

    | PLEASE UPDATE CPI STUDENTS WHERE ROLL EQ NUM TO NUM
        { printf("Output: update Student set cpi = %d where roll = %d", $10, $8); }

    | PLEASE UPDATE NAME STUDENTS WHERE ROLL EQ NUM TO ID
        { printf("Output: update Student set name = '%s' where roll = %d", $10, $8); }

    | PLEASE UPDATE ROLL STUDENTS WHERE ROLL EQ NUM TO NUM
        { printf("Output: update Student set roll = %d where roll = %d", $10, $8); }
    ;

insert_stmt:
    PLEASE INSERT NEW_STUDENT WITH ROLL NUM NAME ID CPI NUM
        { printf("Output: insert into Student (roll, name, cpi) values (%d, '%s', %d)", $6, $8, $10); }

    | PLEASE INSERT NEW_STUDENT WITH NAME ID ROLL NUM CPI NUM
        { printf("Output: insert into Student (name, roll, cpi) values ('%s', %d, %d)", $6, $8, $10); }

    | PLEASE INSERT NEW_STUDENT WITH ROLL NUM AND CPI NUM
        { printf("Output: insert into Student (roll, cpi) values (%d, %d)", $6, $9); }
    ;

delete_stmt:
    PLEASE DELETE STUDENTS WHERE ROLL NO NUM
        { printf("Output: delete from Student where roll = %d", $7); }

    | PLEASE DELETE STUDENTS WHERE ROLL EQ NUM
        { printf("Output: delete from Student where roll = %d", $7); }

    | PLEASE DELETE STUDENTS WHERE CPI LT NUM
        { printf("Output: delete from Student where cpi < %d", $7); }

    | PLEASE DELETE STUDENTS WHERE CPI GT NUM
        { printf("Output: delete from Student where cpi > %d", $7); }

    | PLEASE DELETE ALL STUDENTS
        { printf("Output: delete from Student"); }
    ;

%%

void yyerror(char *s) {
    fprintf(stderr, "\nGrammatical Error: %s\n", s);
    fprintf(stderr, "Please rephrase and try again.\n\n");
}

int main() {
    printf("   Table: Student    Columns: name, roll, cpi       \n");
    printf("Supported query patterns:\n\n");
    printf("  SELECT:\n");
    printf("  Please give/show/display me the roll/cpi/name numbers of the students.\n");
    printf("  Please give me all the information of the students.\n");
    printf("  Please show the name and roll of the students whose cpi is more than 7.\n");
    printf("  Please show all the students sorted by cpi descending.\n");
    printf("  Please give the count of the students whose cpi is more than 7.\n");
    printf("  Please show all the students whose cpi is between 6 and 9.\n\n");
    printf("  UPDATE:\n");
    printf("  Please update the cpi of the student having roll no 201 to 9.\n\n");
    printf("  INSERT:\n");
    printf("  Please add a new_student with roll 105 name Alice cpi 8.\n\n");
    printf("  DELETE:\n");
    printf("  Please delete the student having roll no 105.\n");
    printf("  Please delete the students whose cpi is less than 5.\n\n");
    printf("Enter your query (end with a dot): \n");

    yyparse();
    return 0;
}