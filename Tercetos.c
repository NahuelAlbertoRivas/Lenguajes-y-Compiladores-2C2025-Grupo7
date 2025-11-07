#include "Tercetos.h"

terceto tercetos[MAX_TERCETOS];
int indiceTerceto = 0;

int crearTerceto(char* operador, char *op1, char *op2)
{
    /* operador es el operador */
    /* op1 es el operando izquierdo */
    /* op2 es el operando derecho */

    tercetos[indiceTerceto].indice = indiceTerceto;
    strcpy(tercetos[indiceTerceto].operador, operador);
    strcpy(tercetos[indiceTerceto].operandoIzq, op1);
    strcpy(tercetos[indiceTerceto].operandoDer, op2);
    
    return indiceTerceto++;
}

int crearTercetoUnitario(int valor)
{
    tercetos[indiceTerceto].indice = indiceTerceto;
    itoa(valor,tercetos[indiceTerceto].operador, 10);
    strcpy(tercetos[indiceTerceto].operandoIzq, "_");
    strcpy(tercetos[indiceTerceto].operandoDer, "_");

    return indiceTerceto++;
}

int crearTercetoUnitarioStr(const char *op)
{
    tercetos[indiceTerceto].indice = indiceTerceto;
    strcpy(tercetos[indiceTerceto].operador, op);
    strcpy(tercetos[indiceTerceto].operandoIzq, "_");
    strcpy(tercetos[indiceTerceto].operandoDer, "_");

    return indiceTerceto++;
}

int getIndice()
{
    return indiceTerceto;
}

char* verOperadorTerceto(int indice)
{
    /* indice indica el terceto */

    return tercetos[indice].operador;
}

void modificarOperadorTerceto(int indice, char* op)
{
    /* Esto se usa para negar la condición de salto */
    /* indice indica el terceto */
    /* op es el salto */

    strcpy(tercetos[indice].operador, op);
}

void modificarOperandoDerechoConTerceto(int indice, char *nroTerceto)
{
    /* Esto se usa para negar la condición de salto */
    /* indice indica el terceto */
    /* op es el salto */

    strcpy(tercetos[indice].operandoDer, nroTerceto);
}

void modificarOperandoIzquierdoConTerceto(int indice, char *nroTerceto)
{
    /* Esto se usa para negar la condición de salto */
    /* indice indica el terceto */
    /* op es el salto */

    strcpy(tercetos[indice].operandoIzq, nroTerceto);
}

void imprimirTercetos()
{
    int i;

    FILE *ptercetos = fopen("intermediate-code.txt", "w");
    if (!ptercetos) 
    {
        perror("Error al abrir el archivo");
        return;
    }

    for (i = 0; i < indiceTerceto; i++) {
        char MinValue[50];
        itoa(SHRT_MIN, MinValue, 10);

        char operandoIzq[50];
        char operandoDer[50];

        if(strcmp(tercetos[i].operandoIzq, "-32768") == 0)
        {
            strcpy(operandoIzq, "_");
        }
        else 
        {
            strcpy(operandoIzq, tercetos[i].operandoIzq);
        }

        if(strcmp(tercetos[i].operandoDer, "-32768") == 0)
        {
            strcpy(operandoDer, "_");
        }
        else 
        {
            strcpy(operandoDer, tercetos[i].operandoDer);
        }
        
        fprintf(ptercetos, "[%d] (%s, %s, %s)\n", i, tercetos[i].operador, operandoIzq, operandoDer);
    }
        
    fclose(ptercetos);
        
    return;
}

/*
int copiarListaDeTercetos(Lista* lista_externa) {
    Nodo* current = lista_tercetos;  // Lista interna de tercetos

    // Recorremos toda la lista de tercetos
    while (current != NULL) {
        terceto* terceto_actual = (terceto*)current->dato;  // Obtener el terceto desde el nodo

        terceto nuevo_terceto;
        // Copiar los datos del terceto a la nueva estructura
        strncpy(nuevo_terceto.operando, terceto_actual->operando, sizeof(nuevo_terceto.operando) - 1);
        nuevo_terceto.operando[sizeof(nuevo_terceto.operando) - 1] = '\0';  // Asegura la terminación de la cadena

        strncpy(nuevo_terceto.operadorIzq, terceto_actual->operadorIzq, sizeof(nuevo_terceto.operadorIzq) - 1);
        nuevo_terceto.operadorIzq[sizeof(nuevo_terceto.operadorIzq) - 1] = '\0';  // Asegura la terminación de la cadena

        strncpy(nuevo_terceto.operadorDer, terceto_actual->operadorDer, sizeof(nuevo_terceto.operadorDer) - 1);
        nuevo_terceto.operadorDer[sizeof(nuevo_terceto.operadorDer) - 1] = '\0';  // Asegura la terminación de la cadena

        nuevo_terceto.indice = terceto_actual->indice;  // Copiar el índice

        // Insertar el nuevo terceto en la lista externa
        insertarListaAlFinal(lista_externa, &nuevo_terceto, sizeof(nuevo_terceto));

        // Avanzamos al siguiente nodo de la lista interna
        current = current->sig;
    }

    return TODO_OK;
}
    */