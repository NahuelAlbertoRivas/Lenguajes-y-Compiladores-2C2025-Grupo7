#include "Tercetos.h"

terceto tercetos[MAX_TERCETOS];
int indiceTerceto = 0;

int crearTerceto(char* operador, char* op1, char* op2)
{
    /* operador es el operador */
    /* op1 es el operando izquierdo */
    /* op2 es el operando derecho */

    strcpy(tercetos[indiceTerceto].operando, operador);
    strcpy(tercetos[indiceTerceto].operadorIzq, op1);
    strcpy(tercetos[indiceTerceto].operadorDer, op2);

    return indiceTerceto++;
}

/*
void completarTerceto(int indice, char* op)
{
    /* Esto se usa para completar los saltos */
    /* indice indica el terceto */
    /* op es el único operando */
/*
    strcpy(tercetos[indice].operadorIzq, op);

    return;
}
*/

char* verOperadorTerceto(int indice)
{
    /* indice indica el terceto */

    return tercetos[indice].operando;
}

void modificarOperadorTerceto(int indice, char* op)
{
    /* Esto se usa para negar la condición de salto */
    /* indice indica el terceto */
    /* op es el salto */

    strcpy(tercetos[indice].operando, op);
}

void imprimirTercetos()
{
    int i = 0;
    for (i; i < indiceTerceto; i++)
        fprintf(ptercetos, "[%d] (%s, %s, %s)\n", i, tercetos[i].operando, tercetos[i].operadorIzq, tercetos[i].operadorDer);

    return;
}