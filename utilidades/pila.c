#include "pila.h"
#include <stdlib.h>
#include <string.h>

#define RESERVAR_MEMORIA_NODO(nodo, tamNodo, info, tamInfo) ( (   !((nodo) = (tNodo *) malloc(tamNodo))    \
                                                                || !((info)= malloc(tamInfo))          )?  \
                                                                   free(nodo), SIN_MEM : TODO_OK           )
#define MINIMO(x, y) ((x) <= (y)? (x) : (y))

void crear_pila(tPila *pp)
{
    *pp = NULL;
}

int pila_vacia(const tPila *pp)
{
    return *pp == NULL;
}

int poner_en_pila(tPila *pp, const void *info, unsigned tamInfo)
{
    tNodo *nue;

    if(!RESERVAR_MEMORIA_NODO(nue, sizeof(tNodo), nue->info, tamInfo))
        return SIN_MEM;

    memcpy(nue->info, info, (nue->tamInfo = tamInfo));
    nue->sig = *pp;
    *pp = nue;

    return TODO_OK;
}

int ver_tope(const tPila *pp, void *buffer, unsigned cantBytes)
{
    if(!(*pp))
        return PILA_VACIA;

    memcpy(buffer, (*pp)->info, MINIMO(cantBytes, (*pp)->tamInfo));

    return TODO_OK;
}

int sacar_de_pila(tPila *pp, void *buffer, unsigned cantBytes)
{
    tNodo *elim = *pp;

    if(!elim)
        return PILA_VACIA;

    *pp = elim->sig;
    memcpy(buffer, elim->info, MINIMO(cantBytes, elim->tamInfo));
    free(elim->info);
    free(elim);

    return TODO_OK;
}

void vaciar_pila(tPila *pp)
{
    while(*pp)
    {
        tNodo *elim = *pp;
        *pp = elim->sig;
        free(elim->info);
        free(elim);
    }
}

int mapear_y_vaciar_pila(tPila *pp, void *contexto, AccionarSimple tarea)
{
    int res;

    while(*pp)
    {
        tNodo *elim = *pp;
        *pp = elim->sig;
        res = tarea(elim->info, contexto);
        free(elim->info);
        free(elim);
    }

    return res;
}
