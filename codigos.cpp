/***************************************************************************************
 *	Projeto: Compilador - Linguagem FOCA                                               *
 *	Autores: Bernardo de Araujo Mesquita Chaves                                        *
 *           Claudio Sergio Forain Junior                                              *
 *	         Roque Elias Assumpcao Pinel                                               *
 *	Periodo: 2007-01                                                                   *
 ***************************************************************************************/

#include "codigos.h"

int numTemp = 0;
int numRotulo = 0;

bool global = true;

string declaracaoTemp = "";

FUNCAO *ptr_funcao = NULL;

SIMBOLO *ptr_global = NULL;
SIMBOLO *ptr_local = NULL;

LOOP *ptr_loop = NULL;

VAR *ptr_for_atual = NULL;
VAR *ptr_for_decla = NULL;

VAR *ptr_switch = NULL;

string inserir_funcao (string nome, string retorno, string parametros)
{
	if(busca_funcao(nome))
		return "Erro: Nome \"" + nome + "\" usado como funcao.";

	FUNCAO *ptr = new FUNCAO;
		
	ptr->nome = nome;
	ptr->retorno = retorno;
	ptr->parametros = parametros;

	ptr->ant = ptr_funcao;
	ptr_funcao = ptr;

	return "";	
}

FUNCAO *busca_funcao (string nome)
{
	FUNCAO *ptr = ptr_funcao;

	while(ptr)
	{
		if(ptr->nome == nome)
			return ptr;
			
		ptr = ptr->ant;
	}
	
	return NULL;
}

FUNCAO *funcao_atual (void)
{
	return ptr_funcao;
}

string inserir_var_global (string nome, string tipo, string lin, string col, int array, bool cons)
{
	if(busca_var_global(nome))
		return "Erro: Nome \"" + nome + "\" usado como varivel global.";

	SIMBOLO *ptr = new SIMBOLO;

	ptr->nome = nome;
	ptr->tipo = tipo;
	ptr->lin = lin;
	ptr->col = col;
	ptr->array = array;
	ptr->cons = cons;
	ptr->ant = ptr_global;
	ptr_global = ptr;

	return "";	
}

SIMBOLO *busca_var_global (string nome)
{
	SIMBOLO *ptr = ptr_global;

	while(ptr)
	{
		if(ptr->nome == nome)
			return ptr;
			
		ptr = ptr->ant;
	}

	return NULL;
}

string inserir_var_local (string nome, string tipo, string lin, string col, int array, bool cons)
{
	if(busca_var_local(nome))
		return "Erro: Nome \"" + nome + "\" usado como varivel local.";

	SIMBOLO *ptr = new SIMBOLO;

	ptr->nome = nome;
	ptr->tipo = tipo;
	ptr->lin = lin;
	ptr->col = col;
	ptr->array = array;
	ptr->cons = cons;
	ptr->ant = ptr_local;
	ptr_local = ptr;

	return "";	
}

SIMBOLO *busca_var_local (string nome)
{
	SIMBOLO *ptr = ptr_local;

	while(ptr)
	{
		if(ptr->nome == nome)
			return ptr;
		ptr = ptr->ant;
	}
	return NULL;
}

void eliminar_var_local (void)
{
	SIMBOLO *ptr, *ant;
	
	for(ptr = ptr_local; ptr; ptr = ant)
	{
		ant = ptr->ant;
		delete ptr;
	}
	ptr_local = NULL;
}

void muda_instancia (bool nGlobal)
{
	global = nGlobal;
}

const bool retorna_instancia (void)
{
	return global;
}

string int_to_str (const int n)
{
	char valor[TAM_VALOR];
	sprintf(valor, "%d", n);
	return valor;
}

string double_to_str (const double n)
{
	char valor[TAM_VALOR];
	sprintf(valor, "%0.3lf", n);
	return valor;
}

string gera_temp (string tipo)
{
	string temp = "F_" + int_to_str(++numTemp);

	if(tipo == "string")
		declaracaoTemp += "char " + temp + "[256];\n";
	else if(tipo == "bool")
		declaracaoTemp += "int " + temp + ";\n";
	else 
		declaracaoTemp += tipo + " " + temp + ";\n";

	return temp;
}

string gera_rotulo (void)
{
	return "L_" + int_to_str(++numRotulo);
}

string declara_temp (void)
{
	string var = declaracaoTemp;
	declaracaoTemp = "";
	numTemp = 0;
	return var;
}

void inserir_loop (string b, string c, bool sw)
{
	LOOP *ptr = new LOOP;
	
	ptr->b = b;	
	ptr->c = c;
	ptr->sw = sw;
	
	ptr->ant = ptr_loop;
	ptr_loop = ptr;
}

void deletar_loop (void)
{
	if(ptr_loop)
	{
		LOOP *ptr = ptr_loop->ant;
		delete ptr_loop;
		ptr_loop = ptr;
	}
}

LOOP *valores_loop (void)
{
	return ptr_loop;
}

void inserir_for (string nome)
{
	VAR *ptr1 = new VAR, *ptr2 = new VAR;
	
	ptr1->nome = nome;
	ptr1->ant = ptr_for_atual;
	ptr_for_atual = ptr1;
	
	if (!busca_var_for_decla(nome))
	{
		ptr2->nome = nome;
		ptr2->ant = ptr_for_decla;
		ptr_for_decla = ptr2;
	}
}

VAR *busca_var_for_atual (string nome)
{
	VAR *ptr = ptr_for_atual;

	while(ptr)
	{
		if(ptr->nome == nome)
			return ptr;
			
		ptr = ptr->ant;
	}
	
	return NULL;
}

VAR *busca_var_for_decla (string nome)
{
	VAR *ptr = ptr_for_decla;

	while(ptr)
	{
		if(ptr->nome == nome)
			return ptr;
			
		ptr = ptr->ant;
	}
	
	return NULL;
}

string declara_var_for (void)
{
	VAR *ptr, *ant;
	string codigo = "";

	for(ptr = ptr_for_decla; ptr; ptr = ant)
	{
		codigo += "int " + ptr->nome + ";\n";
		ant = ptr->ant;
		delete ptr;
	}
	
	ptr_for_decla = NULL;

	return codigo;
}

void deletar_for (void)
{
	if(ptr_for_atual)
	{
		VAR *ptr = ptr_for_atual->ant;
		delete ptr_for_atual;
		ptr_for_atual = ptr;
	}
}

void inserir_switch (string nome, string tipo)
{
	VAR *ptr1 = new VAR;
	
	ptr1->nome = nome;
	ptr1->tipo = tipo;
	ptr1->ant = ptr_switch;
	ptr_switch = ptr1;
}

VAR *pegar_switch (void)
{
	return ptr_switch;
}

void deletar_switch (void)
{
	if(ptr_switch)
	{
		VAR *ptr = ptr_switch->ant;
		delete ptr_for_atual;
		ptr_switch = ptr;
	}
}

string debug (const int opcao)
{
	bool tudo = false;
	string codigo = "";
	
	if(!opcao)
		tudo = true;
	if(tudo || opcao == 1)
	{
		if(ptr_local)
			codigo += "printf(\"VARIAVEIS LOCAIS:\\n\");\n";
		codigo += imprimir_var(ptr_local);
	}
	if(tudo || opcao == 2)
	{
		if(ptr_global)
			codigo += "printf(\"VARIAVEIS LOCAIS:\\n\");\n";
		codigo += imprimir_var(ptr_global);
	}
	
	return codigo;
}

string imprimir_var (SIMBOLO *ptr_inicial)
{
	string codigo = "";
	SIMBOLO *ptr = ptr_inicial;

	while(ptr)
	{
		if (ptr->array == 0)
		{
			codigo += "cout << \"" + ptr->nome + " : \" << " + ptr->nome + " << endl;\n";
		}
		else
			codigo += "printf(\"" + ptr->nome + " : <array>\\n\");\n";
		ptr = ptr->ant;
	}
	return codigo;
}

/* FIM */
