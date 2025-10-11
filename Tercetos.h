#ifndef TERCETOS_H
#define TERCETOS_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>

#define MAX_TERCETOS 1000

/*VARIABLES GLOBALES*/
extern FILE *ptercetos;

typedef struct {
    int indice;
    char operador[50];    
    char operandoIzq[50];    
    char operandoDer[50];      
}terceto;

/*
typedef struct {
    int indiceBuscado;      // Índice del terceto que quieres actualizar
    char nuevoOperandoIzq[20];   // Nuevo valor para el operador izquierdo
} DatosAccion;
*/

extern terceto tercetos[MAX_TERCETOS];
extern int indiceTerceto;

int crearTerceto(char* operador, int op1, int op2);
int crearTercetoUnitario(int valor);
int crearTercetoUnitarioStr(const char *valor);
void completarTerceto(int indice, char* op);
char* verOperadorTerceto(int indice);
void modificarOperadorTerceto(int indice, char* op);
void modificarOperandoDerechoConTerceto(int indice, int nroTerceto);
void modificarOperandoIzquierdoConTerceto(int indice, int nroTerceto);
void imprimirTercetos();

#endif