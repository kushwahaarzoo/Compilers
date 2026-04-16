%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

extern int l_no;
extern FILE *yyin;
int yylex(void);
void yyerror(const char *s);

/* Lexer token log (defined in lexer.l) */
extern void print_token_log(void);

//  Reduction (Phase 2)


#define MAX_REDUCTIONS 2048
typedef struct { char text[128]; } Reduction;
Reduction reductions[MAX_REDUCTIONS];
int reduction_n = 0;

/* Track which rule names we have already printed (dedup) */

#define MAX_SEEN 64
char seen_rules[MAX_SEEN][64];
int  seen_n = 0;

static int rule_seen(const char *rule) {
    for (int i = 0; i < seen_n; i++)
        if (strcmp(seen_rules[i], rule) == 0) return 1;
    return 0;
}

void log_reduction(const char *rule, const char *rhs) {
    if (reduction_n < MAX_REDUCTIONS) {
        snprintf(reductions[reduction_n].text,
                 sizeof(reductions[reduction_n].text),
                 "%-14s -> %s", rule, rhs);
        reduction_n++;
    }
    /* record for dedup */
    if (!rule_seen(rule) && seen_n < MAX_SEEN)
        strncpy(seen_rules[seen_n++], rule, 63);
}

void print_phase2() {
    printf("\n PHASE 2: SYNTAX ANALYSIS \n");
    printf("  Method : LALR(1) Bottom-Up Parsing\n");
    printf("  Reductions applied during parse:\n");
    // Print each unique rule once 
    for (int i = 0; i < reduction_n; i++) {
        // first occurance
        char rule[64]; char *arrow;
        strncpy(rule, reductions[i].text, 63); rule[63]='\0';
        arrow = strstr(rule, " -> ");
        if (arrow) *arrow = '\0';
        // check it's the first time we see redun
        int dup = 0;
        for (int j = 0; j < i; j++) {
            char prev[64]; strncpy(prev,reductions[j].text,63); prev[63]='\0';
            char *pa = strstr(prev," -> "); if(pa)*pa='\0';
            if (strcmp(rule,prev)==0){dup=1;break;}
        }
        if (!dup)
            printf("    %s\n", reductions[i].text);
    }
    printf("  Result : successful - No errors (syntatical )found\n");
    printf("\n");
}

#define MAX_SYMBOLS 256
typedef struct {
    char name[64];
    int  type;   /* 0 = int */
    int  value;
    int  initialized;
} Symbol;

Symbol symtable[MAX_SYMBOLS];
int sym_count = 0;

int sym_lookup(const char *name) {
    for (int i = 0; i < sym_count; i++)
        if (strcmp(symtable[i].name, name) == 0) return i;
    return -1;
}

int sym_insert(const char *name, int type) {
    if (sym_lookup(name) != -1) {
        fprintf(stderr, "Semantic Error: Variable '%s' already declared\n", name);
        return -1;
    }
    strcpy(symtable[sym_count].name, name);
    symtable[sym_count].type = type;
    symtable[sym_count].value = 0;
    symtable[sym_count].initialized = 0;
    return sym_count++;
}

void sym_set(const char *name, int val, int known) {
    int i = sym_lookup(name);
    if (i == -1) { fprintf(stderr,"Semantic Error: Undeclared variable '%s'\n",name); return; }
    symtable[i].value = val;
    symtable[i].initialized = known;
}

void print_symtable() {
    printf("\n\n");
    printf("  SYMBOL TABLE\n");
    printf("  %-20s %-8s %-10s\n", "Name", "Type", "Init?");
    for (int i = 0; i < sym_count; i++)
        printf("  %-20s %-8s %-10s\n",
               symtable[i].name, "int",
               symtable[i].initialized ? "yes" : "no");
    printf("\n");
}

// Three-Address Code (TAC)


#define MAX_TAC 1024
typedef struct {
    char op[8];
    char arg1[64];
    char arg2[64];
    char result[64];
} TAC;

TAC tac[MAX_TAC];
int tac_count = 0;
int temp_count = 0;
int label_count = 0;

char *new_temp() {
    static char buf[16];
    sprintf(buf, "t%d", temp_count++);
    return strdup(buf);
}

char *new_label() {
    static char buf[16];
    sprintf(buf, "L%d", label_count++);
    return strdup(buf);
}

void emit(const char *result, const char *op, const char *a1, const char *a2) {
    if (tac_count >= MAX_TAC) { fprintf(stderr,"TAC overflow\n"); return; }
    strcpy(tac[tac_count].op,     op     ? op     : "");
    strcpy(tac[tac_count].arg1,   a1     ? a1     : "");
    strcpy(tac[tac_count].arg2,   a2     ? a2     : "");
    strcpy(tac[tac_count].result, result ? result : "");
    tac_count++;
}

void print_tac() {
    printf("\n\n");
    printf("  THREE-ADDRESS CODE (TAC)");
    printf("\n");
    for (int i = 0; i < tac_count; i++) {
        TAC *t = &tac[i];
        if (strcmp(t->op,"label")==0)
            printf("  %s:\n", t->result);
        else if (strcmp(t->op,"goto")==0)
            printf("  goto %s\n", t->result);
        else if (strcmp(t->op,"iffalse")==0)
            printf("  iffalse %s goto %s\n", t->arg1, t->result);
        else if (strcmp(t->op,"=")==0 && t->arg2[0]=='\0')
            printf("  %s = %s\n", t->result, t->arg1);
        else if (t->arg2[0]=='\0')
            printf("  %s = %s %s\n", t->result, t->op, t->arg1);  /* unary */
        else
            printf("  %s = %s %s %s\n", t->result, t->arg1, t->op, t->arg2);
    }
    printf("\n");
}

// Optimization of code 

#define MAX_CONST 256
typedef struct { char name[64]; int val; int known; } ConstEntry;
ConstEntry cmap[MAX_CONST];
int cmap_n = 0;

void cmap_set(const char *n, int v, int k) {
    for (int i=0;i<cmap_n;i++) if (strcmp(cmap[i].name,n)==0){cmap[i].val=v;cmap[i].known=k;return;}
    if (cmap_n<MAX_CONST){strcpy(cmap[cmap_n].name,n);cmap[cmap_n].val=v;cmap[cmap_n].known=k;cmap_n++;}
}
int cmap_get(const char *n, int *v) {
    for (int i=0;i<cmap_n;i++) if(strcmp(cmap[i].name,n)==0&&cmap[i].known){*v=cmap[i].val;return 1;}
    return 0;
}
void cmap_invalidate(const char *n) {
    for (int i=0;i<cmap_n;i++) if(strcmp(cmap[i].name,n)==0){cmap[i].known=0;return;}
}


#define MAX_CSE 256
typedef struct { char op[8]; char a1[64]; char a2[64]; char res[64]; } CSEEntry;
CSEEntry cse_map[MAX_CSE];
int cse_n = 0;

char *cse_lookup(const char *op, const char *a1, const char *a2) {
    for (int i=0;i<cse_n;i++)
        if(strcmp(cse_map[i].op,op)==0&&strcmp(cse_map[i].a1,a1)==0&&strcmp(cse_map[i].a2,a2)==0)
            return cse_map[i].res;
    return NULL;
}
void cse_insert(const char *op,const char *a1,const char *a2,const char *res){
    if(cse_n<MAX_CSE){
        strcpy(cse_map[cse_n].op,op);strcpy(cse_map[cse_n].a1,a1);
        strcpy(cse_map[cse_n].a2,a2);strcpy(cse_map[cse_n].res,res);cse_n++;
    }
}
void cse_invalidate(const char *var){
    for(int i=0;i<cse_n;i++)
        if(strcmp(cse_map[i].a1,var)==0||strcmp(cse_map[i].a2,var)==0||strcmp(cse_map[i].res,var)==0){
            /* shift left */
            for(int j=i;j<cse_n-1;j++) cse_map[j]=cse_map[j+1];
            cse_n--; i--;
        }
}

int is_const(const char *s) {
    if (!s||!*s) return 0;
    int i = (*s=='-')?1:0;
    if (!s[i]) return 0;
    for(;s[i];i++) if(s[i]<'0'||s[i]>'9') return 0;
    return 1;
}

TAC opt_tac[MAX_TAC];
int opt_count = 0;

void optimize() {
    printf("  Optimization :");
    printf("\n");

    for (int i=0;i<tac_count;i++) {
        TAC t = tac[i];

        /* Labels / gotos / branches: reset constant-prop, keep as-is */
        if(strcmp(t.op,"label")==0||strcmp(t.op,"goto")==0||strcmp(t.op,"iffalse")==0){
            opt_tac[opt_count++]=t;
            
            cse_n=0;
            continue;
        }

        /* Simple copy  result = arg1 */
        if(strcmp(t.op,"=")==0 && t.arg2[0]=='\0') {
            int v; char buf[64];
            if(is_const(t.arg1)) {
                cmap_set(t.result, atoi(t.arg1), 1);
            } else if(cmap_get(t.arg1,&v)) {
                sprintf(buf,"%d",v);
                strcpy(t.arg1,buf);
                cmap_set(t.result,v,1);
                printf("  [ConstProp] %s = %s  →  %s = %d\n", t.result, tac[i].arg1, t.result, v);
            } else {
                cmap_invalidate(t.result);
            }
            cse_invalidate(t.result);
            opt_tac[opt_count++]=t;
            continue;
        }

        {
            int v1,v2; char b1[64],b2[64];
            int got1=0,got2=0;

            /* constant propagation into operands */
            if(is_const(t.arg1)){got1=1;v1=atoi(t.arg1);}
            else if(cmap_get(t.arg1,&v1)){got1=1;sprintf(b1,"%d",v1);
                printf("  [ConstProp] operand %s → %d\n",t.arg1,v1);
                strcpy(t.arg1,b1);}

            if(t.arg2[0]&&is_const(t.arg2)){got2=1;v2=atoi(t.arg2);}
            else if(t.arg2[0]&&cmap_get(t.arg2,&v2)){got2=1;sprintf(b2,"%d",v2);
                printf("  [ConstProp] operand %s → %d\n",t.arg2,v2);
                strcpy(t.arg2,b2);}

            /* constant folding */
            if(got1 && (t.arg2[0]?got2:1) && t.arg2[0]) {
                int res=0; int fold=1;
                if(strcmp(t.op,"+")==0) res=v1+v2;
                else if(strcmp(t.op,"-")==0) res=v1-v2;
                else if(strcmp(t.op,"*")==0) res=v1*v2;
                else if(strcmp(t.op,"/")==0&&v2!=0) res=v1/v2;
                else fold=0;
                if(fold){
                    char rb[64]; sprintf(rb,"%d",res);
                    printf("  [ConstFold] %s = %s %s %s  →  %s = %d\n",
                           t.result,tac[i].arg1,t.op,tac[i].arg2,t.result,res);
                    strcpy(t.op,"="); strcpy(t.arg1,rb); t.arg2[0]='\0';
                    cmap_set(t.result,res,1);
                    cse_invalidate(t.result);
                    opt_tac[opt_count++]=t;
                    continue;
                }
            }

            /* CSE check (only for binary ops that are free of side effects) */
            if(t.arg2[0] &&
               (strcmp(t.op,"+")==0||strcmp(t.op,"-")==0||
                strcmp(t.op,"*")==0||strcmp(t.op,"/")==0)) {
                char *prev = cse_lookup(t.op, t.arg1, t.arg2);
                if(prev){
                    printf("  [CSE]       %s = %s %s %s  →  %s = %s\n",
                           t.result,t.arg1,t.op,t.arg2,t.result,prev);
                    strcpy(t.op,"="); strcpy(t.arg1,prev); t.arg2[0]='\0';
                    cmap_invalidate(t.result);
                    cse_invalidate(t.result);
                    opt_tac[opt_count++]=t;
                    continue;
                }
                cse_insert(t.op,t.arg1,t.arg2,t.result);
            }

            cmap_invalidate(t.result);
            cse_invalidate(t.result);
            opt_tac[opt_count++]=t;
        }
    }
    printf("  (optimization complete)\n");
    printf("\n");
}

void print_opt_tac() {
    printf("\n\n");
    printf("  OPTIMIZED TAC");
    printf("\n");
    for (int i = 0; i < opt_count; i++) {
        TAC *t = &opt_tac[i];
        if (strcmp(t->op,"label")==0)
            printf("  %s:\n", t->result);
        else if (strcmp(t->op,"goto")==0)
            printf("  goto %s\n", t->result);
        else if (strcmp(t->op,"iffalse")==0)
            printf("  iffalse %s goto %s\n", t->arg1, t->result);
        else if (strcmp(t->op,"=")==0 && t->arg2[0]=='\0')
            printf("  %s = %s\n", t->result, t->arg1);
        else if (t->arg2[0]=='\0')
            printf("  %s = %s %s\n", t->result, t->op, t->arg1);
        else
            printf("  %s = %s %s %s\n", t->result, t->arg1, t->op, t->arg2);
    }
    printf("\n");
}


#define NUM_REGS 8
char reg_var[NUM_REGS][64];   
int  reg_dirty[NUM_REGS];   
int  asm_count = 0;

void asm_init() {
    for(int i=0;i<NUM_REGS;i++){reg_var[i][0]='\0';reg_dirty[i]=0;}
}

/* simple sequential register allocator (LRU-like: evict lowest-numbered free reg) */
int get_reg(const char *var) {
    /* already in a register? */
    for(int i=1;i<NUM_REGS;i++) if(strcmp(reg_var[i],var)==0) return i;
    /* find free */
    for(int i=1;i<NUM_REGS;i++) if(reg_var[i][0]=='\0'){
        strcpy(reg_var[i],var); return i;
    }
    /* spill R1 (naive) */
    if(reg_dirty[1]) printf("    STORE R1, %s\n", reg_var[1]);
    strcpy(reg_var[1],var); reg_dirty[1]=0;
    return 1;
}

void gen_asm_instr(const char *fmt, ...) {
    va_list ap; va_start(ap,fmt);
    printf("    "); vprintf(fmt,ap); printf("\n");
    va_end(ap);
    asm_count++;
}

void load_operand(int reg, const char *op) {
    if(is_const(op))
        gen_asm_instr("LOADI R%d, %s", reg, op);
    else {
        int r = get_reg(op);
        if(r != reg) {
            /* check if already loaded */
            int found=0;
            for(int i=1;i<NUM_REGS;i++) if(i!=reg&&strcmp(reg_var[i],op)==0){found=1;break;}
            if(!found) gen_asm_instr("LOAD  R%d, %s", reg, op);
            else gen_asm_instr("MOV   R%d, R%d", reg, r);
        }
    }
}

void codegen() {
    printf("\n\n");
    printf("  TARGET CODE  (Hypothetical RISC)");
    printf("  ISA: 8 registers R0-R7 (R0 = 0)\n");
    printf("  Operation Possible: LOAD/LOADI/STORE/MOV/ADD/SUB/MUL/DIV/SEQ/SNE/SLT/SGT/SLE/SGE/BEZ/JUMP/HALT\n");
    asm_init();

    for(int i=0;i<opt_count;i++){
        TAC *t = &opt_tac[i];

        if(strcmp(t->op,"label")==0){
            printf("  %s:\n", t->result);
            asm_init(); /* conservative: flush reg state at labels */
            continue;
        }
        if(strcmp(t->op,"goto")==0){
            gen_asm_instr("JUMP  %s", t->result);
            asm_init();
            continue;
        }
        if(strcmp(t->op,"iffalse")==0){
            int r1 = get_reg(t->arg1);
            gen_asm_instr("LOAD  R%d, %s", r1, t->arg1);
            gen_asm_instr("BEZ   R%d, %s", r1, t->result);
            asm_init();
            continue;
        }

        /* copy  result = arg1 */
        if(strcmp(t->op,"=")==0 && t->arg2[0]=='\0'){
            int rd = get_reg(t->result);
            if(is_const(t->arg1))
                gen_asm_instr("LOADI R%d, %s", rd, t->arg1);
            else {
                gen_asm_instr("LOAD  R%d, %s", rd, t->arg1);
            }
            reg_dirty[rd]=1;
            gen_asm_instr("STORE R%d, %s", rd, t->result);
            reg_dirty[rd]=0;
            continue;
        }

        /* binary */
        {
            int r1=2, r2=3, rd;
            load_operand(r1, t->arg1);
            if(t->arg2[0]) load_operand(r2, t->arg2);

            rd = get_reg(t->result);
            const char *instr="ADD";
            if(strcmp(t->op,"+")==0)       instr="ADD";
            else if(strcmp(t->op,"-")==0)  instr="SUB";
            else if(strcmp(t->op,"*")==0)  instr="MUL";
            else if(strcmp(t->op,"/")==0)  instr="DIV";
            else if(strcmp(t->op,"==")==0) instr="SEQ";
            else if(strcmp(t->op,"!=")==0) instr="SNE";
            else if(strcmp(t->op,"<")==0)  instr="SLT";
            else if(strcmp(t->op,">")==0)  instr="SGT";
            else if(strcmp(t->op,"<=")==0) instr="SLE";
            else if(strcmp(t->op,">=")==0) instr="SGE";

            if(t->arg2[0])
                gen_asm_instr("%-5s R%d, R%d, R%d", instr, rd, r1, r2);
            else
                gen_asm_instr("SUB   R%d, R0, R%d", rd, r1); /* unary minus */

            gen_asm_instr("STORE R%d, %s", rd, t->result);
            strcpy(reg_var[rd], t->result);
            reg_dirty[rd]=0;
        }
    }
    gen_asm_instr("HALT");
    printf("\n");
}

%}

%union {
    int   ival;
    char *sval;
}

%token <ival> NUMBER
%token <sval> ID
%token INT IF ELSE WHILE FOR RETURN
%token PLUS MINUS MUL DIV
%token ASSIGN EQ NEQ LT GT LE GE AND OR NOT
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA

%type <sval> expr term factor rel_expr cond_expr
%type <sval> decl_list

%right ASSIGN
%left  OR
%left  AND
%left  EQ NEQ
%left  LT GT LE GE
%left  PLUS MINUS
%left  MUL DIV
%right NOT UMINUS

%start program

%%

program
    : stmt_list { log_reduction("program",   "stmt_list"); }
    ;

stmt_list
    : stmt_list stmt { log_reduction("stmt_list", "stmt_list stmt"); }
    |
    ;

stmt
    : decl_stmt   { log_reduction("stmt", "declaration"); }
    | assign_stmt { log_reduction("stmt", "assignment");  }
    | if_stmt     { log_reduction("stmt", "if_stmt");     }
    | while_stmt  { log_reduction("stmt", "while_stmt");  }
    | for_stmt    { log_reduction("stmt", "for_stmt");    }
    | LBRACE stmt_list RBRACE { log_reduction("stmt", "{ stmt_list }"); }
    ;

decl_stmt
    : INT decl_list SEMICOLON { log_reduction("declaration", "int id_list ;"); }
    ;

decl_list
    : decl_list COMMA ID {
        sym_insert($3, 0); free($3);
        log_reduction("id_list", "id_list , ID");
    }
    | ID {
        sym_insert($1, 0); free($1);
        log_reduction("id_list", "ID");
    }
    ;

assign_stmt
    : ID ASSIGN expr SEMICOLON {
        int idx = sym_lookup($1);
        if(idx == -1)
            fprintf(stderr, "Semantic Error line %d: Undeclared variable '%s'\n", l_no, $1);
        else {
            emit($1, "=", $3, NULL);
            sym_set($1, 0, 0);
        }
        log_reduction("assignment", "ID = expr ;");
        free($1); free($3);
    }
    ;

if_stmt
    : IF LPAREN cond_expr RPAREN LBRACE stmt_list RBRACE ELSE LBRACE stmt_list RBRACE {
        log_reduction("if_stmt", "if ( cond ) { stmt_list } else { stmt_list }");
        free($3);
    }
    | IF LPAREN cond_expr RPAREN LBRACE stmt_list RBRACE {
        log_reduction("if_stmt", "if ( cond ) { stmt_list }");
        free($3);
    }
    ;

while_stmt
    : WHILE LPAREN {
        char *ls = new_label();
        emit(ls, "label", NULL, NULL);
        free(ls);
    }
    cond_expr RPAREN LBRACE stmt_list RBRACE {
        log_reduction("while_stmt", "while ( cond ) { stmt_list }");
        free($4);
    }
    ;

for_stmt
    : FOR LPAREN assign_init SEMICOLON cond_expr SEMICOLON assign_update RPAREN
      LBRACE stmt_list RBRACE {
        log_reduction("for_stmt", "for ( init ; cond ; update ) { stmt_list }");
        free($5);
    }
    ;

assign_init
    : ID ASSIGN expr {
        int idx = sym_lookup($1);
        if(idx==-1) fprintf(stderr,"Semantic Error: Undeclared '%s'\n",$1);
        else { emit($1,"=",$3,NULL); sym_set($1,0,0); }
        free($1); free($3);
    }
    |
    ;

assign_update
    : ID ASSIGN expr {
        int idx = sym_lookup($1);
        if(idx==-1) fprintf(stderr,"Semantic Error: Undeclared '%s'\n",$1);
        else { emit($1,"=",$3,NULL); sym_set($1,0,0); }
        free($1); free($3);
    }
    |
    ;
cond_expr
    : rel_expr {
        char *lf = new_label();
        emit(lf, "iffalse", $1, NULL);
        log_reduction("cond_expr", "rel_expr");
        $$ = lf;
    }
    ;

/* ── Relational / Boolean ── */
rel_expr
    : expr LT  expr { char *t=new_temp(); emit(t,"<",$1,$3);  free($1);free($3);
                      log_reduction("rel_expr","expr < expr");  $$=t; }
    | expr GT  expr { char *t=new_temp(); emit(t,">",$1,$3);  free($1);free($3);
                      log_reduction("rel_expr","expr > expr");  $$=t; }
    | expr LE  expr { char *t=new_temp(); emit(t,"<=",$1,$3); free($1);free($3);
                      log_reduction("rel_expr","expr <= expr"); $$=t; }
    | expr GE  expr { char *t=new_temp(); emit(t,">=",$1,$3); free($1);free($3);
                      log_reduction("rel_expr","expr >= expr"); $$=t; }
    | expr EQ  expr { char *t=new_temp(); emit(t,"==",$1,$3); free($1);free($3);
                      log_reduction("rel_expr","expr == expr"); $$=t; }
    | expr NEQ expr { char *t=new_temp(); emit(t,"!=",$1,$3); free($1);free($3);
                      log_reduction("rel_expr","expr != expr"); $$=t; }
    | expr          { log_reduction("rel_expr","expr"); $$ = $1; }
    ;


expr
    : expr PLUS  term { char *t=new_temp(); emit(t,"+",$1,$3); free($1);free($3);
                        log_reduction("expr","expr + term"); $$=t; }
    | expr MINUS term { char *t=new_temp(); emit(t,"-",$1,$3); free($1);free($3);
                        log_reduction("expr","expr - term"); $$=t; }
    | term            { log_reduction("expr","term"); $$ = $1; }
    ;

term
    : term MUL factor { char *t=new_temp(); emit(t,"*",$1,$3); free($1);free($3);
                        log_reduction("term","term * factor"); $$=t; }
    | term DIV factor { char *t=new_temp(); emit(t,"/",$1,$3); free($1);free($3);
                        log_reduction("term","term / factor"); $$=t; }
    | factor          { log_reduction("term","factor"); $$ = $1; }
    ;

factor
    : LPAREN expr RPAREN {
        log_reduction("factor","( expr )");
        $$ = $2;
    }
    | MINUS factor %prec UMINUS {
        char *t = new_temp();
        emit(t, "uminus", $2, NULL);
        log_reduction("factor","- factor");
        free($2); $$ = t;
    }
    | NUMBER {
        char *s = malloc(32);
        sprintf(s, "%d", $1);
        log_reduction("factor","NUMBER");
        $$ = s;
    }
    | ID {
        if(sym_lookup($1)==-1)
            fprintf(stderr,"Semantic Error line %d: Undeclared variable '%s'\n", l_no, $1);
        log_reduction("factor","ID");
        $$ = $1;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntax Error at line %d: %s\n", l_no, s);
}

int main(int argc, char **argv) {
    if(argc > 1) {
        yyin = fopen(argv[1], "r");
        if(!yyin){ perror(argv[1]); return 1; }
    }
    printf("Phasesof this compiler are as follows : Lex → Parse → Semantic → TAC → Optimize → RISC ASM\n\n");

    int r = yyparse();

    print_token_log();

    if(r != 0){ fprintf(stderr,"Compilation failed.\n"); return 1; }

    print_phase2();

    printf("\nPhase 3: Semantic Analysis");
    print_symtable();

    printf("\nPhase 4: Intermediate Code Generation");
    print_tac();

    printf("\nPhase 5: Optimization");
    optimize();
    print_opt_tac();

    printf("\nPhase 6 Target Code Generation");
    codegen();

    return 0;
}
