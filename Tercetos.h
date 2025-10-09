#ifndef TERCETOS_H
#define TERCETOS_H

#define MAX_TERCETOS 1000

/*VARIABLES GLOBALES*/
extern FILE *ptercetos;

typedef struct {
    int indice;
    char operando[50];    
    char operadorIzq[50];    
    char operadorDer[50];      
}terceto;

/*/
typedef struct {
    int indiceBuscado;      // Índice del terceto que quieres actualizar
    char nuevoOperadorIzq[20];   // Nuevo valor para el operador izquierdo
} DatosAccion;
 */

extern terceto tercetos[MAX_TERCETOS];
extern int indiceTerceto;

int crearTerceto(char* operador, char* op1, char* op2);
void completarTerceto(int indice, char* op);
char* verOperadorTerceto(int indice);
void modificarOperadorTerceto(int indice, char* op);
void imprimirTercetos();

#endif