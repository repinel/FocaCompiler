/***************************************************************************************
 *	Projeto: Compilador - Linguagem FOCA                                               *
 *	Autores: Bernardo de Araujo Mesquita Chaves                                        *
 *           Claudio Sergio Forain Junior                                              *
 *	         Roque Elias Assumpcao Pinel                                               *
 *	Periodo: 2007-01                                                                   *
 ***************************************************************************************/

#include "tabela.h"
#include <iostream>
using namespace std;

#define OP_1	1
#define OP_2	2
#define OP_3	3
#define OP_4	4
#define OP_5	5

#define INT 	"int"
#define BOOL 	"bool"
#define DOUBLE 	"double"
#define CHAR 	"char"
#define STRING 	"string"
#define ERRO 	""

struct OPERACAO {
	int opr;
	string op1, op2, res;
} TAB_OPERACAO[N_OPERACOES] = {
	{OP_1, INT, INT, INT}, {OP_1, INT, BOOL, ERRO}, {OP_1, INT, DOUBLE, DOUBLE}, {OP_1, INT, CHAR, INT}, {OP_1, INT, STRING, ERRO},
	{OP_1, BOOL, INT, ERRO}, {OP_1, BOOL, BOOL, ERRO}, {OP_1, BOOL, DOUBLE, ERRO}, {OP_1, BOOL, CHAR, ERRO}, {OP_1, BOOL, STRING, ERRO},
	{OP_1, DOUBLE, INT, DOUBLE}, {OP_1, DOUBLE, BOOL, ERRO}, {OP_1, DOUBLE, DOUBLE, DOUBLE}, {OP_1, DOUBLE, CHAR, DOUBLE}, {OP_1, DOUBLE, STRING, ERRO},
	{OP_1, CHAR, INT, INT}, {OP_1, CHAR, BOOL, ERRO}, {OP_1, CHAR, DOUBLE, DOUBLE}, {OP_1, CHAR, CHAR, CHAR}, {OP_1, CHAR, STRING, ERRO},		
	{OP_1, STRING, INT, ERRO}, {OP_1, STRING, BOOL, ERRO}, {OP_1, STRING, DOUBLE, ERRO}, {OP_1, STRING, CHAR, ERRO}, {OP_1, STRING, STRING, ERRO},

	{OP_2, INT, INT, INT}, {OP_2, INT, BOOL, ERRO}, {OP_2, INT, DOUBLE, ERRO}, {OP_2, INT, CHAR, INT}, {OP_2, INT, STRING, ERRO},
	{OP_2, BOOL, INT, ERRO}, {OP_2, BOOL, BOOL, ERRO}, { OP_2, BOOL, DOUBLE, ERRO}, {OP_2, BOOL, CHAR, ERRO}, {OP_2, BOOL, STRING, ERRO},
	{OP_2, DOUBLE, INT, ERRO}, {OP_2, DOUBLE, BOOL, ERRO}, {OP_2, DOUBLE, DOUBLE, ERRO}, {OP_2, DOUBLE, CHAR, ERRO}, {OP_2, DOUBLE, STRING, ERRO},
	{OP_2, CHAR, INT, INT}, {OP_2, CHAR, BOOL, ERRO}, {OP_2, CHAR, DOUBLE, ERRO}, {OP_2, CHAR, CHAR, CHAR}, {OP_2, CHAR, STRING, ERRO},
	{OP_2, STRING, INT, ERRO}, {OP_2, STRING, BOOL, ERRO}, {OP_2, STRING, DOUBLE, ERRO}, {OP_2, STRING, CHAR, ERRO}, {OP_2, STRING, STRING, ERRO},

	{OP_3, INT, INT, DOUBLE}, {OP_3, INT, BOOL, ERRO}, {OP_3, INT, DOUBLE, DOUBLE}, {OP_3, INT, CHAR, DOUBLE}, {OP_3, INT, STRING, ERRO},
	{OP_3, BOOL, INT, ERRO}, {OP_3, BOOL, BOOL, ERRO}, {OP_3, BOOL, DOUBLE, ERRO}, {OP_3, BOOL, CHAR, ERRO}, {OP_3, BOOL, STRING, ERRO},
	{OP_3, DOUBLE, INT, DOUBLE}, {OP_3, DOUBLE, BOOL, ERRO}, {OP_3, DOUBLE, DOUBLE, DOUBLE}, {OP_3, DOUBLE, CHAR, DOUBLE}, {OP_3, DOUBLE, STRING, ERRO},
	{OP_3, CHAR, INT, INT}, {OP_3, CHAR, BOOL, ERRO}, {OP_3, CHAR, DOUBLE, DOUBLE}, {OP_3, CHAR, CHAR, CHAR}, {OP_3, CHAR, STRING, ERRO},
	{OP_3, STRING, INT, ERRO}, {OP_3, STRING, BOOL, ERRO}, {OP_3, STRING, DOUBLE, ERRO}, {OP_3, STRING, CHAR, ERRO}, {OP_3, STRING, STRING, ERRO},

	{OP_4, INT, INT, BOOL}, {OP_4, INT, BOOL, ERRO}, {OP_4, INT, DOUBLE, BOOL}, {OP_4, INT, CHAR, BOOL}, {OP_4, INT, STRING, ERRO},
	{OP_4, BOOL, INT, ERRO}, {OP_4, BOOL, BOOL, BOOL}, {OP_4, BOOL, DOUBLE, ERRO}, {OP_4, BOOL, CHAR, ERRO}, {OP_4, BOOL, STRING, ERRO},
	{OP_4, DOUBLE, INT, BOOL}, {OP_4, DOUBLE, BOOL, ERRO}, {OP_4, DOUBLE, DOUBLE, BOOL}, {OP_4, DOUBLE, CHAR, BOOL}, {OP_4, DOUBLE, STRING, ERRO},
	{OP_4, CHAR, INT, BOOL}, {OP_4, CHAR, BOOL, ERRO}, {OP_4, CHAR, DOUBLE, BOOL}, {OP_4, CHAR, CHAR, BOOL}, {OP_4, CHAR, STRING, ERRO},
	{OP_4, STRING, INT, ERRO}, {OP_4, STRING, BOOL, ERRO}, {OP_4, STRING, DOUBLE, ERRO}, {OP_4, STRING, CHAR, ERRO}, {OP_4, STRING, STRING, BOOL},
	
	{OP_5, INT, INT, STRING}, {OP_5, INT, BOOL, ERRO}, {OP_5, INT, DOUBLE, ERRO}, {OP_5, INT, CHAR, STRING}, {OP_5, INT, STRING, STRING},
	{OP_5, BOOL, INT, ERRO}, {OP_5, BOOL, BOOL, ERRO}, {OP_5, BOOL, DOUBLE, ERRO}, {OP_5, BOOL, CHAR, ERRO}, {OP_5, BOOL, STRING, STRING},
	{OP_5, DOUBLE, INT, ERRO}, {OP_5, DOUBLE, BOOL, ERRO}, {OP_5, DOUBLE, DOUBLE, ERRO}, {OP_5, DOUBLE, ERRO, BOOL}, {OP_5, DOUBLE, STRING, STRING},
	{OP_5, CHAR, INT, STRING}, {OP_5, CHAR, BOOL, ERRO}, {OP_5, CHAR, DOUBLE, ERRO}, {OP_5, CHAR, CHAR, STRING}, {OP_5, CHAR, STRING, STRING},
	{OP_5, STRING, INT, STRING}, {OP_5, STRING, BOOL, STRING}, {OP_5, STRING, DOUBLE, STRING}, {OP_5, STRING, CHAR, STRING}, {OP_5, STRING, STRING, STRING}
};

string tipoResultado(string op, string op1, string op2)
{
	int valor;
	string retorno = "";
	
	if(op == "+" || op == "-" || op == "*")
		valor = OP_1;
	else if(op == "%")
		valor = OP_2;
	else if(op == "/")
		valor = OP_3;
	else if(op == ">" || op == "<" || op == ">=" || op == "<=" || op == "==" || op == "!=")
		valor = OP_4;
	else if(op == ".")
		valor = OP_5;
	else if (op == "||" || op == "&&")
	{
		if(op1 == BOOL && op2 == BOOL)
			return BOOL;
		else
			return "Erro: Operacao invalida.";
	}
	
	for(int i = 0; i < N_OPERACOES; i++)
	{
		if(TAB_OPERACAO[i].opr == valor && TAB_OPERACAO[i].op1 == op1 && TAB_OPERACAO[i].op2 == op2)
		{
			retorno = TAB_OPERACAO[i].res;
			break;
		}
	}
	if(retorno != "")
		return retorno;

	return "Erro: Operacao invalida.";
}

/* FIM */
