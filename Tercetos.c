#include "Tercetos.h"

terceto tercetos[MAX_TERCETOS];
int indiceTerceto = 0;

int crearTerceto(char* operador, int op1, int op2)
{
    /* operador es el operador */
    /* op1 es el operando izquierdo */
    /* op2 es el operando derecho */
    
    tercetos[indiceTerceto].indice = indiceTerceto;
    strcpy(tercetos[indiceTerceto].operando, operador);
    itoa(op1, tercetos[indiceTerceto].operadorIzq, 10);
    itoa(op2, tercetos[indiceTerceto].operadorDer, 10);

    return indiceTerceto++;
}

int crearTercetoUnitario(int valor)
{
    tercetos[indiceTerceto].indice = indiceTerceto;
    itoa(valor,tercetos[indiceTerceto].operando,10);
    strcpy(tercetos[indiceTerceto].operadorIzq, "_");
    strcpy(tercetos[indiceTerceto].operadorDer, "_");

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
    FILE *ptercetos = fopen("Tercetos.txt", "w");
    if (!ptercetos) {
        perror("Error al abrir el archivo");
        return;
    }

    int i = 0;
    for (i; i < indiceTerceto; i++) {
        char MinValue[50];
        itoa(SHRT_MIN, MinValue, 10);

        char* operadorIzq;
        char* operadorDer;
        if(strcmp(tercetos[i].operadorIzq, "-32768") == 0){
            strcpy(operadorIzq, "_");
        }
        else {
            strcpy(operadorIzq, tercetos[i].operadorIzq);
        }
        
        if(strcmp(tercetos[i].operadorDer, "-32768") == 0){
            strcpy(operadorDer, "_");
        }
        else {
            strcpy(operadorDer, tercetos[i].operadorDer);
        }
        
        fprintf(ptercetos, "[%d] (%s, %s, %s)\n", i, tercetos[i].operando, operadorIzq, operadorDer);
    }
        
    fclose(ptercetos);
        
    return;
}