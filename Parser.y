%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

int yywrap() {
    return 1;
}

void yyerror(const char *s);
int yylex(void);
%}

%union {
    char* str;
    int num;
}

%token <str> STRING
%token <num> NUMBER

%token LEN CONCAT REV PAL FIND TOUPPER TOLOWER SUBSTR COUNT REPLACE STRCMP

%type <str> expr

%%

input:
      | input stmt
      ;

stmt:
      expr ';'       { printf("Output: %s\n", $1); free($1); }
    | error ';'      { yyerror("Syntax error: skipping this line."); yyerrok; }
    ;

expr:
      LEN '(' STRING ')' {
            char buf[20];
            sprintf(buf, "%lu", strlen($3));
            $$ = strdup(buf);
            free($3);
        }
    | CONCAT '(' STRING ',' STRING ')' {
            char* res = malloc(strlen($3) + strlen($5) + 1);
            strcpy(res, $3);
            strcat(res, $5);
            $$ = res;
            free($3); free($5);
        }
    | SUBSTR '(' STRING ',' NUMBER ',' NUMBER ')' {
            int start = $5, len = $7, s_len = strlen($3);
            if (start < 0 || start + len > s_len || len < 0) {
                $$ = strdup("substring out of bounds");
            } else {
                char* res = (char*)malloc(len + 1);
                strncpy(res, $3 + start, len);
                res[len] = '\0';
                $$ = res;
            }
            free($3);
        }
    | REV '(' STRING ')' {
            int len = strlen($3);
            char* res = malloc(len + 1);
            for (int i = 0; i < len; i++) res[i] = $3[len - i - 1];
            res[len] = '\0';
            $$ = res;
            free($3);
        }
    | PAL '(' STRING ')' {
            int len = strlen($3), ok = 1;
            for (int i = 0; i < len / 2; i++) {
                if ($3[i] != $3[len - i - 1]) { ok = 0; break; }
            }
            $$ = strdup(ok ? "true" : "false");
            free($3);
        }
    | FIND '(' STRING ',' STRING ')' {
            $$ = strstr($5, $3) ? strdup("true") : strdup("false");
            free($3); free($5);
        }
    | TOUPPER '(' STRING ')' {
            char* res = strdup($3);
            for (int i = 0; res[i]; i++) res[i] = toupper(res[i]);
            $$ = res;
            free($3);
        }
    | TOLOWER '(' STRING ')' {
            char* res = strdup($3);
            for (int i = 0; res[i]; i++) res[i] = tolower(res[i]);
            $$ = res;
            free($3);
        }
    | COUNT '(' STRING ',' STRING ')' {
            if (strlen($5) != 1) {
                $$ = strdup("count(): the second parameter must be a character");
            } else {
                int count = 0;
                for (int i = 0; $3[i]; i++) {
                    if ($3[i] == $5[0]) count++;
                }
                char buf[20];
                sprintf(buf, "%d", count);
                $$ = strdup(buf);
            }
            free($3); free($5);
        }
    | REPLACE '(' STRING ',' STRING ',' STRING ')' {
            char* pos = strstr($3, $5);
            if (!pos) {
                $$ = strdup($3); // if old is not found, return the original string
            } else {
                int prefix_len = pos - $3;
                int new_len = strlen($3) - strlen($5) + strlen($7);
                char* res = malloc(new_len + 1);
                strncpy(res, $3, prefix_len);
                res[prefix_len] = '\0';
                strcat(res, $7);
                strcat(res, pos + strlen($5));
                $$ = res;
            }
            free($3); free($5); free($7);
        }
    | STRCMP '(' STRING ',' STRING ')' {
            int cmp = strcmp($3, $5);
            char buf[5];
            sprintf(buf, "%d", (cmp == 0 ? 0 : (cmp < 0 ? -1 : 1)));
            $$ = strdup(buf);
            free($3); free($5);
        }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    printf("String processor started. Please enter expressions, press Ctrl+C to exit.\n");
    yyparse();
    return 0;
}

