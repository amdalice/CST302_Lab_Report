%{
#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%%

"len"       { return LEN; }
"concat"    { return CONCAT; }
"rev"       { return REV; }
"pal"       { return PAL; }
"find"      { return FIND; }
"substr"    { return SUBSTR; }
"toupper"   { return TOUPPER; }
"tolower"   { return TOLOWER; }
"count"     { return COUNT; }
"replace"   { return REPLACE; }
"strcmp"    { return STRCMP; }

\"([^\\\"])*\"  { yylval.str = strdup(yytext + 1); yylval.str[strlen(yylval.str) - 1] = '\0'; return STRING; }
[0-9]+          { yylval.num = atoi(yytext); return NUMBER; }

[ \t\n]         ;  // Ignore blank space
"("             { return '('; }
")"             { return ')'; }
","             { return ','; }
";"             { return ';'; }

.               {
                  fprintf(stderr, "Illegal character: %s\n", yytext);
                  return 0;
                }

%%
