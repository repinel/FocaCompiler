/***************************************************************************************
 *	Projeto: Compilador - Linguagem FOCA                                               *
 *	Autores: Bernardo de Araujo Mesquita Chaves                                        *
 *           Claudio Sergio Forain Junior                                              *
 *	         Roque Elias Assumpcao Pinel                                               *
 *	Periodo: 2007-01                                                                   *
 ***************************************************************************************/

#ifndef CODIGOS_H
#define CODIGOS_H

#include <iostream>
#include <cstdio>
#include <string>

using namespace std;

#define TAM_VALOR 20

typedef struct _SIMBOLO {
	string nome,
		   tipo,
		   lin,
		   col;
	int array;
	bool cons;
	struct _SIMBOLO *ant;
} SIMBOLO;

typedef struct _FUNCAO {
	string nome,
		   retorno,
		   parametros;
	struct _FUNCAO *ant;
} FUNCAO;

typedef struct _LOOP {
	string b,
		   c;
	bool sw;
	struct _LOOP *ant;
} LOOP;

typedef struct _VAR {
	string nome,
		   tipo;
	struct _VAR *ant;
} VAR;

string inserir_funcao (string, string, string);
FUNCAO *busca_funcao (string);
FUNCAO *funcao_atual (void);

string inserir_var_global (string, string, string, string, int, bool);
SIMBOLO *busca_var_global (string);
string inserir_var_local (string, string, string, string, int, bool);
SIMBOLO *busca_var_local (string);

void eliminar_var_local (void);
void muda_instancia (bool);
const bool retorna_instancia (void);

void add_instancia (string);
string rem_instancia (void);
string nome_instancia (void);

string int_to_str (const int);
string double_to_str (const double);

string gera_temp (string);
string gera_rotulo (void);
string declara_temp (void);

void inserir_loop (string, string, bool);
void deletar_loop (void);
LOOP *valores_loop (void);

void inserir_for (string);
VAR *busca_var_for_atual (string);
VAR *busca_var_for_decla (string);
string declara_var_for (void);
void deletar_for (void);

void inserir_switch (string, string);
VAR *pegar_switch (void);
void deletar_switch (void);

string debug (const int);
string imprimir_var (SIMBOLO *);

#endif	/* CODIGOS_H */
