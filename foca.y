/***************************************************************************************
 *	Projeto: Compilador - Linguagem FOCA                                               *
 *	Autores: Bernardo de Araujo Mesquita Chaves                                        *
 *           Claudio Sergio Forain Junior                                              *
 *	         Roque Elias Assumpcao Pinel                                               *
 *	Periodo: 2007-01                                                                   *
 ***************************************************************************************/

%{
#include <cstdlib>
#include <string>
#include <iostream>

#include "tabela.h"
#include "codigos.h"

using namespace std;

typedef struct _ATRIBUTOS
{
	string v, t, c;
} ATRIBUTOS;

#define LIBS "#include<iostream>\n#include<cstdlib>\n#include<string>\n\nusing namespace std;\n\n"

#define YYSTYPE ATRIBUTOS

#ifdef __cplusplus
	extern "C" { int yylex(void);
}
#endif

void yyerror(const char*);
void ts_comparacao(ATRIBUTOS *, ATRIBUTOS *, ATRIBUTOS *, string);
void ts_operacoes(ATRIBUTOS *, ATRIBUTOS *, ATRIBUTOS *, string);

%}

%token TK_MAIN TK_INT TK_CHAR TK_DOUBLE TK_STR TK_BOOL TK_VOID TK_BREAK
%token TK_CONT TK_RET TK_IF TK_ELSE TK_FOR TK_WHILE TK_SWITCH TK_CASE
%token TK_DEFAULT TK_SCAN TK_PRINT TK_PRINTLN TK_ADD TK_SUB TK_ATRIBUICAO
%token TK_ATRI_MAIS TK_ATRI_MENOS TK_ATRI_VEZES TK_ATRI_DIV TK_ATRI_MOD
%token TK_ATRI_CONC TK_MAIS TK_MENOS TK_VEZES TK_DIVISAO TK_MOD TK_CONC
%token TK_IGUAL TK_MENOR TK_MAIOR TK_MAI TK_MEI TK_DIF TK_AND TK_OR TK_SWAP
%token TK_NOT TK_VIR TK_PONVIR TK_DOISPON TK_APAR TK_FPAR TK_ACON TK_FCON
%token TK_ACHA TK_FCHA TK_TRUE TK_FALSE TK_ID TK_CHARE TK_INTEIRO TK_STRING
%token TK_REAL TK_DEBUG TK_GLOBALS TK_FUNCTIONS

%right TK_ATRIBUICAO TK_ATRI_MAIS TK_ATRI_MENOS TK_ATRI_VEZES TK_ATRI_DIV TK_ATRI_MOD TK_ATRI_CONC
%left  TK_OR
%left  TK_AND
%left  TK_IGUAL TK_DIF
%left  TK_MENOR TK_MEI TK_MAIOR TK_MAI
%left  TK_CONC
%left  TK_MAIS TK_MENOS
%left  TK_VEZES TK_DIVISAO TK_MOD
%left  TK_NOT
%right TK_ADD TK_SUB
%nonassoc UNARIO
%nonassoc AMB_IF
%nonassoc TK_ELSE

%%

S :	GLOBAL VARIAVEIS FUNCTIONS FUNCOES MAIN TK_ACHA CORPO TK_FCHA
		{
			string codigo = LIBS + $2.c + $4.c + $5.c + "{\n" + declara_temp() + declara_var_for() + $7.c + "\nreturn 0;\n}\n";
			cout << codigo << endl;
		}
	| GLOBAL FUNCTIONS FUNCOES MAIN TK_ACHA CORPO TK_FCHA
		{
			string codigo = LIBS + $3.c + $4.c + "{\n" + declara_temp() + declara_var_for() + $6.c + "\nreturn 0;\n}\n";
			cout << codigo << endl;
		}
	;
GLOBAL : TK_GLOBALS
		{
			muda_instancia(true);
		}
	;
FUNCTIONS : TK_FUNCTIONS
		{
			muda_instancia(false);
		}
	;
MAIN : TK_MAIN TK_APAR TK_VOID TK_FPAR
		{
			string retorno = inserir_funcao($1.v, "int", $3.v);
		    if(retorno != "")
				yyerror("Erro: Funcao declarada com nome reservado \"main\"");
			eliminar_var_local();

			$$.v = "";
			$$.t = "";
			$$.c = "int main (void)\n";
		}
	;
VARIAVEIS : VARIAVEL TK_PONVIR
		{
			$$.v = "";
			$$.t = "";
			$$.c = $1.c + ";\n";
		}
	| VARIAVEIS VARIAVEL TK_PONVIR
		{
			$$.v = "";
			$$.t = "";
			$$.c = $1.c + $2.c + ";\n";
		}
	;
VARIAVEL : TIPO TK_ID INDEX
		{
			int dimensao,
				fim;
			string lin = "",
				   col = "";
			unsigned int pos = ($3.t).find("[");
			if(pos == string::npos)
			{
				if($1.v == "string")
					$$.c = "char " + $2.v + "[256]";
				else if ($1.v == "bool")
					$$.c = "int " + $2.v;
				else
					$$.c = $1.v + " " + $2.v;
				dimensao = 0;
			}
			else
			{
				if($1.v == "string")
					yyerror("Erro: Array string.");
				else if ($1.v == "bool")
					yyerror("Erro: Array bool.");

				if(($3.t).find("[", pos+1) == string::npos)
				{
					lin = $3.v;
					dimensao = 1;
				}
				else
				{
					fim = ($3.v).find(" ");
					lin = ($3.v).substr(0, fim);
					col = ($3.v).substr(++fim, ($3.v).length()-fim);
					dimensao = 2;
				}
				$$.c = $1.v + " " + $2.v + $3.c;
			}
			if(busca_funcao($2.v))
				yyerror(("Erro: ID \"" + $2.v  + "\" declarado como funcao.").c_str());

			string retorno;
			if(retorna_instancia())
				retorno = inserir_var_global($2.v, $1.v, lin, col, dimensao, false);
			else
			{
				if(busca_var_global ($2.v))
					yyerror(("Erro: ID \"" + $2.v  + "\" declarado como variavel global.").c_str());

				retorno = inserir_var_local($2.v, $1.v, lin, col, dimensao, false);
			}
			if(retorno != "")
					yyerror(retorno.c_str());

			$$.v = "";
			$$.t = $1.v;
		}
	| VARIAVEL TK_VIR TK_ID INDEX
		{
			int dimensao,
				fim;
			string lin = "",
				   col = "";
			unsigned int pos = ($4.t).find("[");
			if(pos == string::npos)
			{
				if($1.t == "string")
					$$.c = $1.c + ";\n" + "char " + $3.v + "[256]";
				else if ($1.t == "bool")
					$$.c = $1.c + ";\n" + "int " + $3.v;
				else
					$$.c = $1.c + ";\n" + $1.t + " " + $3.v;
				dimensao = 0;
			}
			else
			{
				if($1.t == "string")
					yyerror("Erro: Array string.");
				else if ($1.t == "bool")
					yyerror("Erro: Array bool.");
					
				if(($4.t).find("[", pos+1) == string::npos)
				{
					lin = $4.v;
					dimensao = 1;					
				}
				else
				{
					fim = ($4.v).find(" ");
					lin = ($4.v).substr(0, fim);					
					col = ($4.v).substr(++fim, ($4.v).length()-fim);
					dimensao = 2;
				}
				$$.c = $1.c + ";\n" + $1.t + " " + $3.v + $4.c;
			}
			if(busca_funcao($3.v))
				yyerror(("Erro: ID \"" + $3.v  + "\" declarado como funcao.").c_str());

			string retorno;
			if(retorna_instancia())
				retorno = inserir_var_global($3.v, $1.t, lin, col, dimensao, false);
			else
			{
				if(busca_var_global ($3.v))
					yyerror(("Erro: ID \"" + $3.v  + "\" declarado como variavel global.").c_str());
				retorno = inserir_var_local($3.v, $1.t, lin, col, dimensao, false);
			}
			if(retorno != "")
					yyerror(retorno.c_str());
			
			$$.v = "";
			$$.t = $1.t;
		}
	;
INDEX : TK_ACON TK_INTEIRO TK_FCON
		{
			$$.v = $2.v;
			$$.t = "[]";
			$$.c = "[" + $2.v + "]";
		}
	| TK_ACON TK_INTEIRO TK_FCON TK_ACON TK_INTEIRO TK_FCON
		{
			int n = atoi(($2.v).c_str()) * atoi(($5.v).c_str());
			$$.v = $2.v + " " + $5.v;
			$$.t = "[][]";
			$$.c = "[" + int_to_str(n) + "]";
		}
	|
		{
			$$.v = "";
			$$.t = "";
			$$.c = "";
		}
	;
VAR : VAR1
	| VAR2
	;
VAR1 : TK_ID
		{
			SIMBOLO *ptr = busca_var_local($1.v);
			if(!ptr)
			{
				ptr = busca_var_global($1.v);
				
				if(!ptr)
				{
					if(!busca_var_for_atual($1.v))					
						yyerror("Erro: Variavel nao declarada.");

					$$.v = $1.v;
					$$.t = "int";
					$$.c = "";
				}
			}
			if(ptr)
			{
				if(ptr->array == 0)
				{
					$$.v = $1.v;
					$$.t = ptr->tipo;
					$$.c = "";
				}
				else
					yyerror("Erro: Variavel com dimensao invalida.");
			}
		}
	;
VAR2 : TK_ID TK_ACON E TK_FCON
		{
			if($3.t != "int")
				yyerror("Erro: Index deve ser inteiro.");

			SIMBOLO *ptr = busca_var_local($1.v);
			if(!ptr)
			{
				ptr = busca_var_global($1.v);
				
				if(!ptr)
					yyerror("Erro: Variavel nao declarada.");
			}
			if(ptr)
			{
				if(ptr->array == 1)
				{
					if (ptr->lin != "*")
					{
						unsigned int pos = ($3.v).find_first_not_of("0123456789");
						if(pos == string::npos)
						{
							int a = atoi(($3.v).c_str()),
								b = atoi((ptr->lin).c_str());
							if(a >= b)
								yyerror("Erro: Variavel com indice invalido.");
						}
					}
					$$.v = $1.v + "[" + $3.v + "]";
					$$.t = ptr->tipo;
					$$.c = $3.c;
				}
				else
					yyerror("Erro: Variavel com dimensao invalida.");
			}
		}
	| TK_ID TK_ACON E TK_FCON TK_ACON E TK_FCON
		{
			if($3.t != "int" || $6.t != "int")
				yyerror("Erro: Index deve ser inteiro.");
				
			SIMBOLO *ptr = busca_var_local($1.v);
			if(!ptr)
			{
				ptr = busca_var_global($1.v);
				
				if(!ptr)
					yyerror("Erro: Variavel nao declarada.");
			}
			if(ptr)
			{
				if(ptr->array == 2)
				{
					if(ptr->lin != "*")
					{
						unsigned int pos = ($3.v).find_first_not_of("0123456789");
						if(pos == string::npos)
						{
							int a = atoi(($3.v).c_str()),
								b = atoi((ptr->lin).c_str());
							if(a >= b)
								yyerror("Erro: Variavel com indice invalido.");
						}
						pos = ($6.v).find_first_not_of("0123456789");
						if(pos == string::npos)
						{
							int a = atoi(($6.v).c_str()),
								b = atoi((ptr->col).c_str());
							if(a >= b)
								yyerror("Erro: Variavel com indice invalido.");
						}
					}
					string temp1 = gera_temp($3.t),
						   temp2 = gera_temp($3.t);
					$$.v = $1.v + "[" + temp2 + "]";
					$$.t = ptr->tipo;
					
					if(ptr->col == "*")
						$$.c = $3.c + $6.c + temp1 + " = " + $3.v + " * " + $1.v + "_COL_;\n"
							   + temp2 + " = " + temp1 + " + " + $6.v + ";\n";
					else
						$$.c = $3.c + $6.c + temp1 + " = " + $3.v + " * " + ptr->col + ";\n"
							   + temp2 + " = " + temp1 + " + " + $6.v + ";\n";
				}
				else
					yyerror("Erro: Variavel com dimensao invalida.");
			}			
		}
	;
TIPO : TK_CHAR
	| TK_STRING
	| TK_BOOL
	| TK_INT
	| TK_DOUBLE
	;
FUNCOES : FUNCAO FUNCOES
		{
			$$.v = "";
			$$.t = "";
			$$.c = $1.c + $2.c;
		}
	|
		{
			$$.v = "";
			$$.t = "";
			$$.c = "";
		}
	;
FUNCAO : PRE_FUN PROTOTIPO TK_ACHA CORPO TK_FCHA
		{
			$$.v = "";
			$$.t = "";
			$$.c = $2.c + "{\n" + declara_temp() + declara_var_for() + $4.c + "}\n";
		}
	;
PRE_FUN :
		{
			eliminar_var_local();
		}
	;
PROTOTIPO : RET_FUN TK_ID TK_APAR TK_VOID TK_FPAR
		{
/*
			if($1.v == "string")
				yyerror("Erro: Impossivel retorno tipo string.");
*/			
			if(busca_var_global($2.v))
				yyerror(("Erro: ID \"" + $2.v  + "\" declarado como variavel global.").c_str());

			string retorno = inserir_funcao($2.v, $1.v, $4.v);
		    if(retorno != "")
				yyerror(retorno.c_str());
			$$.v = "";
			$$.t = "";
			
			if($1.v == "bool")
				$$.c = "int " + $2.v + " (" + $4.v + ")\n";
			if($1.v == "string")
				$$.c = "char *" + $2.v + " (" + $4.v + ")\n";
			else
				$$.c = $1.v + " " + $2.v + " (" + $4.v + ")\n";
		}
	| RET_FUN TK_ID TK_APAR LPARAM TK_FPAR
		{
/*
			if($1.v == "string")
				yyerror("Erro: Impossivel retorno tipo string.");
*/		
			if(busca_var_global($2.v))
				yyerror(("Erro: ID \"" + $2.v  + "\" declarado como variavel global.").c_str());

			string retorno = inserir_funcao($2.v, $1.v, $4.t);
		    if(retorno != "")
				yyerror(retorno.c_str());
			$$.v = "";
			$$.t = "";

			if($1.v == "bool")
				$$.c = "int " + $2.v + " (" + $4.c + ")\n";
			else if($1.v == "string")
				$$.c = "char *" + $2.v + " (" + $4.c + ")\n";
			else
				$$.c = $1.v + " " + $2.v + " (" + $4.c + ")\n";
		}
	;
RET_FUN : TIPO
	| TK_VOID
	;
LPARAM : TIPO TK_ID INDEX_P TK_VIR LPARAM
		{
			int dimensao;
			if($3.t == "")
			{
				if($1.v == "string")
					$$.c = "char " + $2.v + "[], " + $5.c;
				else if($1.v == "bool")
					$$.c = "int " + $2.v + ", " + $5.c;
				else
					$$.c = $1.v + " " + $2.v + ", " + $5.c;
				dimensao = 0;
			}
			else if ($3.t == "[]")
			{
				if($1.v == "string")
					yyerror("Erro: Array string.");
				else if($1.v == "bool")
					yyerror("Erro: Array bool.");
				$$.c = $1.v + " " + $2.v + $3.c + ", " + $5.c;
				dimensao = 1;
			}
			else
			{
				if($1.v == "string")
					yyerror("Erro: Array string.");
				else if($1.v == "bool")
					yyerror("Erro: Array bool.");
				$$.c = $1.v + " " + $2.v + $3.c + ", int " + $2.v + "_COL_" + ", " + $5.c;
				dimensao = 2;
			}
			if(busca_funcao($2.v))
				yyerror(("Erro: ID \"" + $2.v  + "\" declarado como funcao.").c_str());

			if(busca_var_global($2.v))
				yyerror(("Erro: ID \"" + $2.v  + "\" declarado como variavel global.").c_str());

			string retorno = "";
			if(dimensao == 2)
			{
				retorno = inserir_var_local($2.v, $1.v, "*", "*", dimensao, false);
				if(retorno != "")
					yyerror(retorno.c_str());
				retorno = inserir_var_local($2.v + "_COL_", "int", "", "", dimensao, false);
				if(retorno != "")
					yyerror(retorno.c_str());
			}
			else
			{
				retorno = inserir_var_local($2.v, $1.v, "", "", dimensao, false);
				if(retorno != "")
					yyerror(retorno.c_str());
			}

			$$.v = "";
			$$.t = $1.v + $3.t + " " + $5.t;
		}
	| TIPO TK_ID INDEX_P
		{
			int dimensao;
			if($3.t == "")
			{
				if($1.v == "string")
					$$.c = "char " + $2.v + "[]";
				else if($1.v == "bool")
					$$.c = "int " + $2.v;
				else
					$$.c = $1.v + " " + $2.v + $3.c;
				dimensao = 0;
			}
			else if ($3.t == "[]")
			{
				if($1.v == "string")
					yyerror("Erro: Array string.");
				else if($1.v == "bool")
					yyerror("Erro: Array bool.");
				$$.c = $1.v + " " + $2.v + $3.c;
				dimensao = 1;
			}
			else
			{
				if($1.v == "string")
					yyerror("Erro: Array string.");
				else if($1.v == "bool")
					yyerror("Erro: Array bool.");
				$$.c = $1.v + " " + $2.v + $3.c + ", int " + $2.v + "_COL_";
				dimensao = 2;
			}
			if(busca_funcao($2.v))
				yyerror(("Erro: ID \"" + $2.v  + "\" declarado como funcao.").c_str());

			if(busca_var_global($2.v))
				yyerror(("Erro: ID \"" + $2.v  + "\" declarado como variavel global.").c_str());

			string retorno = "";
			if(dimensao == 2)
			{
				retorno = inserir_var_local($2.v, $1.v, "*", "*", dimensao, false);
				if(retorno != "")
					yyerror(retorno.c_str());
				retorno = inserir_var_local($2.v + "_COL_", "int", "", "", dimensao, false);
				if(retorno != "")
					yyerror(retorno.c_str());
			}
			else
			{
				retorno = inserir_var_local($2.v, $1.v, "", "", dimensao, false);
				if(retorno != "")
					yyerror(retorno.c_str());
			}

			$$.v = "";
			$$.t = $1.v + $3.t;
		}
	;
INDEX_P : TK_ACON TK_FCON
		{
			$$.v = "";
			$$.t = "[]";
			$$.c = "[]";
		}
	| TK_ACON TK_FCON TK_ACON TK_FCON
		{
			$$.v = "";
			$$.t = "[][]";
			$$.c = "[]";
		}
	|
		{
			$$.v = "";
			$$.t = "";
			$$.c = "";
		}
	;
CORPO : VARIAVEIS BLOCO
		{
			$$.v = "";
			$$.t = "";
			$$.c = $1.c + $2.c;
		}
	| BLOCO
		{
			$$.v = "";
			$$.t = "";
			$$.c = $1.c;
		}
	;
BLOCO : CMDS
	|
		{
			$$.v = "";
			$$.t = "";
			$$.c = "";
		}
	;
CMDS : CMD CMDS
		{
			$$.v = "";
			$$.t = "";
			$$.c = $1.c + $2.c;
		}
	| CMD
	;
CMD : CMD_IF
	| CMD_FOR
	| CMD_WHILE
	| CMD_SWITCH
	| CMD_PRINT
	| CMD_SCAN
	| CMD_SWAP
	| CMD_DEBUG
	| TK_BREAK TK_PONVIR
		{
			LOOP *ptr = valores_loop();
			
			if(!ptr)
				yyerror("Erro: Break deve ser usado em loops ou switch.");
				
			$$.v = $1.v;
			$$.t = $1.t;
			$$.c = "goto " + ptr->b + ";\n";
		}
	| TK_CONT TK_PONVIR
		{
			LOOP *ptr = valores_loop();
			
			if(!ptr || ptr->sw)
				yyerror("Erro: Continue deve ser usado em loops.");
				
			$$.v = $1.v;
			$$.t = $1.t;
			$$.c = "goto " + ptr->c + ";\n";
		}
	| TK_RET TK_PONVIR
		{
			FUNCAO *ptr = funcao_atual();
			
			if(!ptr)
				yyerror("Erro: Nao exite funcao.");
			if(ptr->nome == "main" || ptr->retorno != "void")
				yyerror("Erro: Funcao exige valor para retorno.");
				
			$$.v = $1.v;
			$$.t = $1.t;
			$$.c = $1.v + ";\n";
		}
	| TK_RET E TK_PONVIR
		{
			FUNCAO *ptr = funcao_atual();
			
			if(!ptr)
				yyerror("Erro: Nao exite funcao.");
			if(ptr->retorno != $2.t)
				yyerror(("Erro: Funcao exige retorno do tipo \"" + ptr->retorno + "\"" ".").c_str());
				
			$$.v = $1.v;
			$$.t = $1.t;
			$$.c = $2.c + $1.v + " " + $2.v + ";\n";
		}
	| ATRIBUICAO TK_PONVIR
		{
			$$.v = $1.v;
			$$.t = $1.t;
			$$.c = $1.c;			
		}
	| CH_FUN TK_PONVIR
		{
			$$.v = $1.v;
			$$.t = $1.t;
			$$.c = $1.c + $1.v + ";\n";
		}
	;
CMD_IF : TK_IF TK_APAR E TK_FPAR BLOCO_CM %prec AMB_IF
		{			
			if($3.t != "bool")
				yyerror("Erro: Expressao nao bool.");

			string r1 = gera_rotulo(),
				   temp = gera_temp("bool");

			$$.v = "";
			$$.t = "";
			$$.c = $3.c + temp + " = !" + $3.v + ";\n"
				   + "if( " + temp + " ) goto " + r1 + ";\n"
				   + $5.c + r1 + ": ;\n";
		}
	| TK_IF TK_APAR E TK_FPAR BLOCO_CM TK_ELSE BLOCO_CM
		{			
			if($3.t != "bool")
				yyerror("Erro: Expressao nao bool.");

			string r1 = gera_rotulo(),
				   r2 = gera_rotulo(),
				   temp = gera_temp("bool");

			$$.v = "";
			$$.t = "";
			$$.c = $3.c + temp + " = !" + $3.v + ";\n"
				   + "if( " + temp + " ) goto " + r1 + ";\n"
				   + $5.c + "goto " + r2 + ";\n" + r1 + ": "
				   + $7.c + r2 + ": ;\n";
		}
	;
CMD_FOR : LOOP_ON1 TK_FOR TK_APAR CMP_FOR TK_PONVIR E TK_PONVIR ATRIBUICAO TK_FPAR BLOCO_CM LOOP_OFF
		{
			if($6.t != "bool")
				yyerror("Erro: Expressao nao bool.");

			string r1 = $1.v,
				   r2 = $1.t,
				   temp = gera_temp("bool");
			
			if($4.t != "")
				deletar_for();

			$$.v = "";
			$$.t = "";
			$$.c = $4.c + r2 + ": " + $6.c + temp + " = ! " + $6.v + ";\n"
				   + "if( " + temp + " ) goto " + r1 + ";\n"
				   + $10.c + $8.c + "goto " + r2 + ";\n" + r1 + ": ;\n";
		}
	;
CMP_FOR : TK_INT TK_ID TK_ATRIBUICAO VAR
		{
			if(busca_var_local($2.v) || busca_var_global($2.v) || busca_var_for_atual($2.v))
				yyerror("Erro: ID de variavel em uso.");
		
			if($4.t != "int" && $4.t != "char")
				yyerror("Erro: Valor nao int.");
				
			inserir_for($2.v);

			$$.v = gera_temp($1.v);
			$$.t = "int";
			$$.c = $4.c + $$.v + " = " + $4.v + ";\n" + $2.v + " = " + $$.v + ";\n";
		}
	| TK_INT TK_ID TK_ATRIBUICAO TK_INTEIRO
		{
			if(busca_var_local($2.v) || busca_var_global($2.v) || busca_var_for_atual($2.v))
				yyerror("Erro: ID de variavel em uso.");
		
			inserir_for($2.v);

			$$.v = gera_temp($1.v);
			$$.t = "int";
			$$.c = $$.v + " = " + $4.v + ";\n" + $2.v + " = " + $$.v + ";\n";
		}
	| ATRIBUICAO
	;
CMD_WHILE : LOOP_ON1 TK_WHILE TK_APAR E TK_FPAR BLOCO_CM LOOP_OFF
		{
			if($4.t != "bool")
				yyerror("Erro: Expressao nao bool.");

			string r1 = $1.v,
				   r2 = $1.t,
				   temp = gera_temp("bool");

			$$.v = "";
			$$.t = "";
			$$.c = r2 + ": " + $4.c + temp + " = ! " + $4.v + ";\n"
				   + "if( " + temp + " ) goto " + r1 + ";\n"
				   + $6.c + "goto " + r2 + ";\n" + r1 + ": ;\n";
		}
	;
BLOCO_CM : CMD
	| TK_ACHA BLOCO TK_FCHA
		{
			$$.v = "";
			$$.t = "";
			$$.c = $2.c;
		}
	;
CMD_SWITCH : LOOP_ON2 TK_SWITCH TK_APAR EXP_SWITCH TK_FPAR TK_ACHA BLOCO_SWITCH TK_FCHA LOOP_OFF
		{
			$$.v = "";
			$$.t = "";
			$$.c = $4.c + $7.c + $1.v + ": ;\n";
		}
	;
EXP_SWITCH : VAR
		{
			if($1.t != "string" && $1.t != "int" && $1.t != "char")
				yyerror("Erro: Expressao invalida para switch.");
			inserir_switch($1.v, $1.t);
			$$.v = $1.v;
			$$.t = $1.t;
			$$.c = $1.c;
		}
	;
BLOCO_SWITCH : TK_CASE CASE_F TK_DOISPON BLOCO BLOCO_SWITCH
		{
			VAR *ptr = pegar_switch();
			string temp = gera_temp("int"),
				   r1 = gera_rotulo();
			if(ptr->tipo != $2.t)
				yyerror("Erro: Comparacao com tipos distintos.");
			
			$$.v = "";
			$$.t = "";
			if($2.t == "string")
				$$.c = temp + " = strcmp(" + ptr->nome + ", " + $2.v + ");\n"
					   + "if( " + temp + " ) goto " + r1 + ";\n" + $4.c + r1
					   + ": ;\n" + $5.c;
			else
				$$.c = temp + " = " + ptr->nome + " == " + $2.v + ";\n" + temp
					   + " = !" + temp + ";\n" + "if( " + temp + " ) goto "
					   + r1 + ";\n" + $4.c + r1 + ": ;\n" + $5.c;
		}
	| TK_DEFAULT TK_DOISPON BLOCO
		{
			$$.v = "";
			$$.t = "";
			$$.c = $3.c;
		}
	|
		{
			$$.v = "";
			$$.t = "";
			$$.c = "";
		}
	;
CASE_F : TK_STR
	| TK_CHARE
	| TK_INTEIRO
	;
LOOP_ON1 :
		{
			string r1 = gera_rotulo(),
				   r2 = gera_rotulo();
			inserir_loop(r1, r2, false);
			$$.v = r1;
			$$.t = r2;
			$$.c = "";
		}
	;
LOOP_ON2 :
		{
			string r1 = gera_rotulo();
			inserir_loop(r1, "", true);
			$$.v = r1;
			$$.t = "";
			$$.c = "";
		}
	;
LOOP_OFF :
		{
			deletar_loop();
			$$.v = "";
			$$.t = "";
			$$.c = "";
		}
	;
ATRIBUICAO : VAR TK_ATRIBUICAO E
		{
			if($1.t != $3.t)
				yyerror("Erro: Atribuicao de tipos distintos");

			if($1.t == "string")
				$$.c = $1.c + $3.c + "strcpy(" + $1.v + ", " + $3.v + ");\n";
			else
				$$.c = $1.c + $3.c + $1.v + " = " + $3.v + ";\n";
			$$.v = $1.v;
			$$.t = $1.t;
		}
	| VAR TK_ATRI_MAIS E
		{
			ts_operacoes(&$$, &$1, &$3, "+");
			$$.c += $1.v + " = " + $$.v + ";\n";
		}
	| VAR TK_ATRI_MENOS E
		{
			ts_operacoes(&$$, &$1, &$3, "-");
			$$.c += $1.v + " = " + $$.v + ";\n";
		}
	| VAR TK_ATRI_VEZES E
		{
			ts_operacoes(&$$, &$1, &$3, "*");
			$$.c += $1.v + " = " + $$.v + ";\n";
		}
	| VAR TK_ATRI_DIV E
		{
			ts_operacoes(&$$, &$1, &$3, "/");
			$$.c += $1.v + " = " + $$.v + ";\n";
		}
	| VAR TK_ATRI_MOD E
		{
			ts_operacoes(&$$, &$1, &$3, "%");
			$$.c += $1.v + " = " + $$.v + ";\n";
		}
	| E3
	;
CH_FUN : TK_ID TK_APAR LARGS TK_FPAR
		{
			FUNCAO *ptr = busca_funcao($1.v);
			if(!ptr)
				yyerror("Erro: Funcao invalida.");
			if(ptr->parametros != $3.t)
				yyerror("Erro: Numero de parametros esta invalido.");
				
			$$.v = $1.v + "(" + $3.v +")";
			$$.t = ptr->retorno;
			$$.c = $3.c;
		}
	;
LARGS : AUX_L TK_VIR LARGS
		{
			$$.v = $1.v + ", " + $3.v;
			$$.t = $1.t + " " + $3.t;
			$$.c = $1.c + $3.c;
		}
	| AUX_L
	|
		{
			$$.v = "";
			$$.t = "void";
			$$.c = "";
		}
	;
AUX_L : VAR2
		{
			$$.v = gera_temp($1.t);
			$$.t = $1.t;
			$$.c = $$.v + " = " + $1.v + ";\n";
		}
	| AUX_E
	| TK_ID
		{
			SIMBOLO *ptr = busca_var_local($1.v);
			if(!ptr)
			{
				ptr = busca_var_global($1.v);
				if(!ptr)
				{
					if(!busca_var_for_atual($1.v))					
						yyerror("Erro: Variavel nao declarada.");

					$$.v = gera_temp("int");
					$$.t = "int";
					$$.c = $$.v + " = " + $1.v + ";\n";
				}
			}
			if(ptr)
			{
				if(ptr->array == 0)
				{
					$$.t = ptr->tipo;
					if(ptr->tipo == "string")
					{
						$$.v = $1.v;
						$$.c = "";
					}
					else
					{
						$$.v = gera_temp(ptr->tipo);
						$$.c = $$.v + " = " + $1.v + ";\n";
					}
				}
				else if(ptr->array == 1)
				{
					$$.t = ptr->tipo + "[]";
					$$.v = $1.v;
					$$.c = "";
				}
				else
				{
					string temp = gera_temp("int");
					$$.t = ptr->tipo + "[][]";
					$$.v = $1.v + ", " + temp;
					$$.c = temp + " = " + ptr->col + ";\n";
				}
			}
		}
	;
CMD_SCAN : TK_SCAN TK_APAR LLV TK_FPAR TK_PONVIR
		{
			$$.v = "";
			$$.t = "";
         	$$.c = $3.c;
		}
	;
LLV : VAR TK_VIR LLV
		{
			string temp = gera_temp($1.t);
			if($1.t == "string")
				$$.c = $1.c + "cin >> " + temp + ";\n" + "strcpy(" + $1.v + ", " + temp + ");\n" + $3.c;
			else
				$$.c = $1.c + "cin >> " + temp + ";\n" + $1.v + " = " + temp + ";\n" + $3.c;

			$$.v = "";
			$$.t = "";
		}
	| VAR
		{
			string temp = gera_temp($1.t);
			if($1.t == "string")
				$$.c = $1.c + "cin >> " + temp + ";\n" + "strcpy(" + $1.v + ", " + temp + ");\n";
			else
				$$.c = $1.c + "cin >> " + temp + ";\n" + $1.v + " = " + temp + ";\n";

			$$.v = "";
			$$.t = "";
		}
	;
CMD_PRINT : TK_PRINT TK_APAR G TK_FPAR TK_PONVIR
		{
			if($3.t != "string")
				yyerror("Erro: Tipo invalido.");
				
			$$.v = "";
			$$.t = "";
			$$.c = $3.c + "cout << " + $3.v + ";\n";
		}
	| TK_PRINTLN TK_APAR G TK_FPAR TK_PONVIR
		{
			if($3.t != "string")
				yyerror("Erro: Tipo invalido.");
				
			$$.v = "";
			$$.t = "";
			$$.c = $3.c + "cout << " + $3.v + " << endl;\n";
		}
	| TK_PRINTLN TK_APAR VAR TK_FPAR TK_PONVIR
		{
			string temp = gera_temp($3.t);
			if($3.t == "string")
				$$.c = $3.c + "strcpy(" + temp + ", " + $3.v + ");\ncout << " + temp + " << endl;\n";
			else
				$$.c = $3.c + temp + " = " + $3.v + ";\ncout << " + temp + " << endl;\n";
			
			$$.v = "";
			$$.t = "";
		}
	;
CMD_SWAP : TK_SWAP TK_APAR VAR TK_VIR VAR TK_FPAR TK_PONVIR
		{
			if($3.t != $5.t)
                yyerror("Erro: Variaveis com tipos distintos.");
			else
			{
				string temp = gera_temp($3.t);
				if($3.t == "string")
				{
					$$.c = "strcpy(" + temp + ", " + $3.v + ");\nstrcpy(" + $3.v + ", " + $5.v + ");\nstrcpy(" + $5.v + ", " + temp + ");\n";
				}
				else
					$$.c = temp + " = " + $3.v + ";\n" + $3.v + " = " + $5.v + ";\n" + $5.v + " = " + temp + ";\n"; 
			}
			$$.v = "";
			$$.t = "";
		}
	;
CMD_DEBUG : TK_DEBUG TK_APAR TK_FPAR TK_PONVIR
		{
			$$.v = "";
			$$.t = "";
			$$.c = debug(0);
		}
	| TK_DEBUG TK_APAR TK_STR TK_FPAR TK_PONVIR
		{
			if($3.v == "\"\"")
				$$.c = debug(0);
			else if($3.v == "\"local\"")
				$$.c = debug(1);
			else if($3.v == "\"global\"")
				$$.c = debug(2);
			else
				yyerror("Erro: Opcao invalida.");
			$$.v = "";
			$$.t = "";
		}
	;
E : AUX_E
	| VAR
	;
AUX_E : E1
	| E2
	| F 
	;
E1 : E TK_AND E
		{
			ts_comparacao(&$$, &$1, &$3, $2.v);
		}
	| E TK_OR E
		{
			ts_comparacao(&$$, &$1, &$3, $2.v);
		}
	| E TK_MENOR E
		{
			ts_comparacao(&$$, &$1, &$3, $2.v);
		}
	| E TK_MAIOR E
		{
			ts_comparacao(&$$, &$1, &$3, $2.v);
		}
	| E TK_MEI E
		{
			ts_comparacao(&$$, &$1, &$3, $2.v);
		}
	| E TK_MAI E
		{
			ts_comparacao(&$$, &$1, &$3, $2.v);
		}
	| E TK_IGUAL E
		{
			ts_comparacao(&$$, &$1, &$3, $2.v);
		}
	| TK_NOT E
		{
			if($2.t != "bool" && $2.t != "int")
				yyerror("Erro: \"Not\" somente para int e bool.");
				
			$$.v = gera_temp("bool");
			$$.t = "bool";
			$$.c = $2.c + $$.v + " = !" + $2.v + ";\n";
		}
	| E TK_DIF E
		{
			ts_comparacao(&$$, &$1, &$3, $2.v);
		}
	;
E2: E TK_MAIS E
		{
			ts_operacoes(&$$, &$1, &$3, $2.v);
		}
	| E TK_MENOS E
		{
			ts_operacoes(&$$, &$1, &$3, $2.v);
		}
	| E TK_VEZES E
		{
			ts_operacoes(&$$, &$1, &$3, $2.v);
		}
	| E TK_DIVISAO E
		{
			ts_operacoes(&$$, &$1, &$3, $2.v);
		}
	| E TK_MOD E
		{
			ts_operacoes(&$$, &$1, &$3, $2.v);
		}
	| E3
	| G
	;
E3: VAR TK_SUB
		{
			ATRIBUTOS temp = {"1", "int", ""};
			ts_operacoes(&$$, &$1, &temp, "-");
			$$.c += $1.v + " = " + $$.v + ";\n";
       }
	| VAR TK_ADD
	   {
			ATRIBUTOS temp = {"1", "int", ""};
			ts_operacoes(&$$, &$1, &temp, "+");
			$$.c += $1.v + " = " + $$.v + ";\n";
		}
	;
F : TK_MENOS E %prec UNARIO
		{
			if($2.t != "int" && $2.t != "double")
				yyerror("Erro: Unario somente para int/double");
                
			$$.t = $2.t;
			$$.v = gera_temp($2.t);
			$$.c = $2.c + $$.v + " = -" + $2.v + ";\n";
        }
	| TK_APAR E TK_FPAR
		{   
			$$.t = $2.t;
			$$.v = $2.v;
			$$.c = $2.c;
		}	
	| CONST
		{
			
			$$.t = $1.t;
			$$.v = gera_temp($1.t);
			$$.c = $$.v + " = " + $1.v + ";\n";
		}
	| CH_FUN
	;
G :	E TK_CONC E
		{
			string retorno = tipoResultado($2.v, $1.t, $3.t);
			if (retorno != "string")
				yyerror(retorno.c_str());
				
			$$.v = gera_temp(retorno);
			$$.t = retorno;
			
			if($1.t == "int")
			{
				if($3.t == "int")
				{
					$$.c = $1.c + $3.c + "sprintf(" + $$.v + ", \"%d%d\", " + $1.v + ", " + $3.v + ");\n";
				}
				else if($3.t == "char")
				{
					$$.c = $1.c + $3.c + "sprintf(" + $$.v + ", \"%d%c\", " + $1.v + ", " + $3.v + ");\n";
				}
				else
				{
					$$.c = $1.c + $3.c + "sprintf(" + $$.v + ", \"%d%s\", " + $1.v + ", " + $3.v + ");\n";
				}
			}
			else if($1.t == "bool")
			{
				$$.c = $1.c + $3.c + "sprintf(" + $$.v + ", \"%d%s\", " + $1.v + ", " + $3.v + ");\n";
			}
			else if($1.t == "double")
			{
				$$.c = $1.c + $3.c + "sprintf(" + $$.v + ", \"%.3lf%s\", " + $1.v + ", " + $3.v + ");\n";
			}
			else if($1.t == "char")
			{
				if($3.t == "int")
				{
					$$.c = $1.c + $3.c + "sprintf(" + $$.v + ", \"%c%d\", " + $1.v + ", " + $3.v + ");\n";
				}
				else if($3.t == "char")
				{
					$$.c = $1.c + $3.c + "sprintf(" + $$.v + ", \"%c%c\", " + $1.v + ", " + $3.v + ");\n";
				}
				else
				{
					$$.c = $1.c + $3.c + "sprintf(" + $$.v + ", \"%c%s\", " + $1.v + ", " + $3.v + ");\n";
				}
			}
			else
			{
				if($3.t == "int")
				{
					$$.c = $1.c + $3.c + "sprintf(" + $$.v + ", \"%s%d\", " + $1.v + ", " + $3.v + ");\n";
				}
				else if($3.t == "bool")
				{
					$$.c = $1.c + $3.c + "sprintf(" + $$.v + ", \"%s%d\", " + $1.v + ", " + $3.v + ");\n";
				}
				else if($3.t == "double")
				{
					$$.c = $1.c + $3.c + "sprintf(" + $$.v + ", \"%s%.3lf\", " + $1.v + ", " + $3.v + ");\n";
				}
				else if($3.t == "char")
				{
					$$.c = $1.c + $3.c + "sprintf(" + $$.v + ", \"%s%c\", " + $1.v + ", " + $3.v + ");\n";
				}
				else
				{
					$$.c = $1.c + $3.c + "sprintf(" + $$.v + ", \"%s%s\", " + $1.v + ", " + $3.v + ");\n";
				}
			}
		}
	| TK_STR
		{
			$$.t = $1.t;
			$$.v = gera_temp($1.t);
			$$.c = "strcpy(" + $$.v + ", " + $1.v + ");\n";
		}
	;
CONST : TK_CHARE
	| TK_INTEIRO
	| TK_REAL
	| TK_TRUE
	| TK_FALSE
	;
%%

#include "lex.yy.c"

extern int nLinhas;

void ts_comparacao(ATRIBUTOS *ss, ATRIBUTOS *s1, ATRIBUTOS *s2, string op)
{
	string retorno = tipoResultado(op, s1->t, s2->t);
	
	if(retorno != "bool")
		yyerror(retorno.c_str());

	ss->v = gera_temp("bool");
	ss->t = retorno;

	if(s1->t == "string" && s2->t == "string")
	{
		string valor = gera_temp("bool");
		ss->c = s1->c + s2->c + valor + " = strcmp(" + s1->v + ", " + s2->v + ");\n"
					+ ss->v + " = " + valor + op + " 0;\n";
	}
	else
		ss->c = s1->c + s2->c + ss->v + " = " + s1->v + " " + op + " " + s2->v + ";\n";
}

void ts_operacoes(ATRIBUTOS *ss, ATRIBUTOS *s1, ATRIBUTOS *s2, string op)
{
	string retorno = tipoResultado(op, s1->t, s2->t);
	
	if(retorno.find("Erro") == 0)
		yyerror(retorno.c_str());

	ss->v = gera_temp(retorno);
	ss->t = retorno;
	ss->c = s1->c + s2->c + ss->v + " = " +  s1->v + " " + op + " " + s2->v + ";\n";
}

int yyparse (void);

void yyerror (const char* st)
{
	fprintf(stderr,"Linha %d - %s\n", nLinhas, st);
	
	exit(1);
}

int main (int argc, char* argv[])
{
	yyparse();
}

/* FIM */
