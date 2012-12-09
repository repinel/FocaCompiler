/***************************************************************************************
 *	Projeto: Compilador - Linguagem FOCA                                               *
 *	Autores: Bernardo de Araujo Mesquita Chaves                                        *
 *           Claudio Sergio Forain Junior                                              *
 *	         Roque Elias Assumpcao Pinel                                               *
 *	Periodo: 2007-01                                                                   *
 ***************************************************************************************/

%{
#include <string>

int nLinhas = 1;

void contarLinha (void)
{
	for (int i = 0; yytext[i] != '\0'; i++)
		if (yytext[i] == '\n')
			nLinhas++;
}

%}

NL      [\n]
DELIM   [\t ]
NUMERO  [0-9]
LETRA   [a-z_A-Z]
INTEIRO {NUMERO}+
REAL    {NUMERO}+("."{NUMERO}*)?
ID      {LETRA}({LETRA}|{NUMERO})*
CHAR    \'(\\.|.)\'
STRING  \"([^\"\n]|\\\")*\"

%%

"/*"([^*]|("*"+[^/]))*"*/" { contarLinha(); }
"//"(.*|^\n)  { }

"main"     { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_MAIN; }
"<GLOBALS>"   { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_GLOBALS; }
"<FUNCTIONS>" { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_FUNCTIONS; }
"int"      { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_INT; }
"char"     { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_CHAR; }
"double"   { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_DOUBLE; }
"string"   { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_STRING; }
"bool"     { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_BOOL; }
"void"     { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_VOID; }
"break"    { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_BREAK; }
"continue" { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_CONT; }
"return"   { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_RET; }
"if"       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_IF; }
"else"     { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_ELSE; }
"for"      { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_FOR; }
"while"    { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_WHILE; }
"switch"   { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_SWITCH; }
"case"     { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_CASE; }
"default"  { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_DEFAULT; }
"print"    { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_PRINT; }
"println"  { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_PRINTLN; }
"scan"     { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_SCAN; }
"swap"     { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_SWAP; }
"debug"    { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_DEBUG; }
"--"       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_SUB; }
"++"       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_ADD; }
"="        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_ATRIBUICAO; }
"+="       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_ATRI_MAIS; }
"-="       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_ATRI_MENOS; }
"*="       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_ATRI_VEZES; }
"/="       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_ATRI_DIV; }
"%="       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_ATRI_MOD; }
".="       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_ATRI_CONC; }
"+"        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_MAIS; }
"-"        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_MENOS; }
"*"        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_VEZES; }
"/"        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_DIVISAO; }
"%"        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_MOD; }
"."        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_CONC; }
"=="       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_IGUAL; }
"<"        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_MENOR; }
">"        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_MAIOR; }
"<="       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_MAI; }
">="       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_MEI; }
"!="       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_DIF; }
"&&"       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_AND; }
"||"       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_OR; }
"!"        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_NOT; }
","        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_VIR; }
";"        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_PONVIR; }
":"        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_DOISPON; }
"("        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_APAR; }
")"        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_FPAR; }
"["        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_ACON; }
"]"        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_FCON; }
"{"        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_ACHA; }
"}"        { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_FCHA; }

"true"     {yylval.v = "1"; yylval.c = ""; yylval.t = "bool"; return TK_TRUE; }
"false"    {yylval.v = "0"; yylval.c = ""; yylval.t = "bool"; return TK_FALSE; }

{ID}       { yylval.v = yytext; yylval.c = ""; yylval.t = ""; return TK_ID; }
{CHAR}     { yylval.v = yytext; yylval.c = ""; yylval.t = "char"; return TK_CHARE; }
{INTEIRO}  { yylval.v = yytext; yylval.c = ""; yylval.t = "int"; return TK_INTEIRO; }
{REAL}     { yylval.v = yytext; yylval.c = ""; yylval.t = "double"; return TK_REAL; }
{STRING}   { yylval.v = yytext; yylval.c = ""; yylval.t = "string"; return TK_STR; }

{NL}       { nLinhas++; }
{DELIM}    { }
.          { return *yytext; }

%%

/* FIM */
