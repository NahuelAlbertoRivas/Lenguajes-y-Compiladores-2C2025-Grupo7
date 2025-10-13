#ifndef TERCETOS_H
#define TERCETOS_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>

#define MAX_TERCETOS 3000

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

int crearTerceto(char* operador, char *op1, char *op2);
int crearTercetoUnitario(int valor);
int crearTercetoUnitarioStr(const char *valor);
int getIndice();
char* verOperadorTerceto(int indice);
void modificarOperadorTerceto(int indice, char* op);
void modificarOperandoDerechoConTerceto(int indice, char *nroTerceto);
void modificarOperandoIzquierdoConTerceto(int indice, char *nroTerceto);
void imprimirTercetos();

#endif