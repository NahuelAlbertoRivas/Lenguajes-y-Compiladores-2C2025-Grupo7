#include "lista.h"

#define RESERVAR_MEMORIA_NODO(nodo, tamNodo, info, tamInfo)( (   !( (nodo) = (tNodoLista *) malloc(tamNodo) )    \
                                                              || !( (info) = malloc(tamInfo) )          )?  \
                                                                     free(nodo), SIN_MEM : TODO_OK          )

void crearLista(tLista *p)
{
    *p = NULL;
}

int listaVacia(const tLista *p)
{
    return *p == NULL;
}


int listaLlena(const tLista *p, unsigned cantBytes)
{
    tNodoLista *aux = (tNodoLista *)malloc(sizeof(tNodoLista));
    void *info = malloc(cantBytes);

    free(aux);
    free(info);
    return aux == NULL || info == NULL;
}


int vaciarLista(tLista *p)
{
    int cant = 0;
    while(*p)
    {
        tNodoLista *aux = *p;

        cant++;
        *p = aux->sig;
        free(aux->info);
        free(aux);
    }
    return cant;
}


int ponerAlComienzo(tLista *p, const void *d, unsigned cantBytes)
{
    tNodoLista *nue;

    if((nue = (tNodoLista *)malloc(sizeof(tNodoLista))) == NULL || (nue->info = malloc(cantBytes)) == NULL)
    {
        free(nue);
        return 0;
    }
    memcpy(nue->info, d, cantBytes);
    nue->tamInfo = cantBytes;
    nue->sig = *p;
    *p = nue;
    return 1;
}


int sacarPrimeroLista(tLista *p, void *d, unsigned cantBytes)
{
    tNodoLista *aux = *p;

    if(aux == NULL)
        return 0;
    *p = aux->sig;
    memcpy(d, aux->info, minimo(cantBytes, aux->tamInfo));
    free(aux->info);
    free(aux);
    return 1;
}


int verPrimeroLista(const tLista *p, void *d, unsigned cantBytes)
{
    if(*p == NULL)
        return 0;
    memcpy(d, (*p)->info, minimo(cantBytes, (*p)->tamInfo));
    return 1;
}


int ponerAlFinal(tLista *p, const void *d, unsigned cantBytes)
{
    tNodoLista *nue;

    while(*p)
        p = &(*p)->sig;
    if((nue = (tNodoLista *)malloc(sizeof(tNodoLista))) == NULL || (nue->info = malloc(cantBytes)) == NULL)
    {
        free(nue);
        return 0;
    }
    memcpy(nue->info, d, cantBytes);
    nue->tamInfo = cantBytes;
    nue->sig = NULL;
    *p = nue;
    return 1;
}


int sacarUltimoLista(tLista *p, void *d, unsigned cantBytes)
{
    if(*p == NULL)
        return 0;
    while((*p)->sig)
        p = &(*p)->sig;
    memcpy(d, (*p)->info, minimo(cantBytes, (*p)->tamInfo));
    free((*p)->info);
    free(*p);
    *p = NULL;
    return 1;
}


int verUltimoLista(const tLista *p, void *d, unsigned cantBytes)
{
    if(*p == NULL)
        return 0;
    while((*p)->sig)
        p = &(*p)->sig;
    memcpy(d, (*p)->info, minimo(cantBytes, (*p)->tamInfo));
    return 1;
}


int mostrarLista(const tLista *p, void (*mostrar)(const void *, FILE *), FILE *fp)
{
    int cant = 0;

    while(*p)
    {
        mostrar((*p)->info, fp);
        p = &(*p)->sig;
        cant++;
    }
    return cant;
}


int ponerEnOrden(tLista *p, const void *d, unsigned cantBytes, int (*comparar)(const void *, const void *),
                  int (*acumular)(void **, unsigned *, const void *, unsigned))
{
    tNodoLista *nue;

    while(*p && comparar((*p)->info, d) < 0)
        p = &(*p)->sig;
    if(*p && comparar((*p)->info, d) == 0)
    {
        if(acumular)
            if(!acumular(&(*p)->info, &(*p)->tamInfo, d, cantBytes))
                return SIN_MEM;
        return CLA_DUP;
    }
    if((nue = (tNodoLista *)malloc(sizeof(tNodoLista))) == NULL || (nue->info = malloc(cantBytes)) == NULL)
    {
        free(nue);
        return SIN_MEM;
    }
    memcpy(nue->info, d, cantBytes);
    nue->tamInfo = cantBytes;
    nue->sig = *p;
    *p = nue;
    return TODO_OK;
}


void ordenar(tLista *p, int (*comparar)(const void *, const void *))
{
    tLista *pri = p; // obs: ' pri ' siempre apuntar� al inicio de la lista

    if(*p == NULL) // si la lista est� vac�a, retorna
        return;
    while((*p)->sig) // mientras que no estemos en el �ltimo nodo de la lista, recorremos la lista mediante ' p '
    {
        if(comparar((*p)->info, (*p)->sig->info) > 0) // si la info. del nodo actual es mayor al ' siguiente '
        {
            tLista *q = pri; // ' q ' siempre apunta al inicio de la lista al comenzar cada iteraci�n
            tNodoLista *aux = (*p)->sig; // ' aux ' adquiere el ' siguiente ' nodo

            (*p)->sig = aux->sig; // se asigna a ' p ' el pr�ximo nodo del nodo ' siguiente '
            while((*q)->sig && comparar((*q)->info, aux->info) > 0) // mientras que la info. del primer elemento de la lista sea ' mayor ' al ' siguiente '
                q = &(*q)->sig; // avanzo al siguiente nodo
            aux->sig = *q; //
            *q = aux;
        }
        else // si la info. del actual es menor *o igual* a la del sig.
            p = &(*p)->sig; // simplemente avanzo al siguiente nodo
    }
}

tLista *buscarDirMenorOMayor(tLista *pl, int (*comparar)(const void *, const void *)){
    tLista *punteroNodo = pl;

    while(*(pl = &((*pl)->sig))){
        if(comparar((*punteroNodo)->info, (*pl)->info) == BUSCADO)
            punteroNodo = pl;
    }

    return punteroNodo;
}

int ordenarNodosLista(tLista *pl, int (*comparar)(const void *, const void *)){
    tLista *dirNodo;
    tNodoLista *nodo;

    while(*pl){
        dirNodo = buscarDirMenorOMayor(pl, comparar);
        nodo = *dirNodo;

        *dirNodo = nodo->sig;
        nodo->sig = *pl;
        *pl = nodo;

        pl = &((*pl)->sig);
    }

    return TODO_OK;
}

tLista *obtenerLaDireccionDelSiguiente(tLista *pl){
    return &((*pl)->sig);
}

int accionarSobreElPrimero(tLista *pl, void *recurso, accionManejoDatos tarea){
    tarea((*pl)->info, recurso);
    return TODO_OK;
}

tLista *buscarDirClave(tLista *pl, void *clave, int (*comparar)(const void *, const void *)){
    tLista *punteroNodo = NULL;
    bool encontrado = false;

    while((*pl) && !encontrado){
        if(comparar((*punteroNodo)->info, clave) == BUSCADO){
            punteroNodo = pl;
            encontrado = true;
        }
        pl = &((*pl)->sig);
    }

    return punteroNodo;
}


int mapLista(const tLista *pl, int (*accion)(void *, void *), void *contexto)
{
    int cant = 0;

    while(*pl)
    {
        cant = accion((*pl)->info, contexto);
        pl = &(*pl)->sig;
    }

    return cant;
}
