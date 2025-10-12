#ifndef PILA_DINAMICA
#define PILA_DINAMICA

#define TODO_OK 1
#define SIN_MEM 0
#define PILA_LLENA 1
#define PILA_VACIA -435

typedef int (*AccionarSimple)(void *, void *);

typedef struct sNodo
{
    void *info;
    unsigned tamInfo;
    struct sNodo *sig;
} tNodo;

typedef tNodo *tPila;

void crear_pila(tPila *pp);

int pila_vacia(const tPila *pp);

int pila_llena(const tPila *pp, unsigned tamInfo);

int poner_en_pila(tPila *pp, const void *info, unsigned tamInfo);

int ver_tope(const tPila *pp, void *buffer, unsigned cantBytes);

int sacar_de_pila(tPila *pp, void *buffer, unsigned cantBytes);

void vaciar_pila(tPila *pp);

int mapear_y_vaciar_pila(tPila *pp, void *contexto, AccionarSimple tarea);

#endif
