#include "hashmap.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

unsigned int _hash(const char *key);

HashMap *create_HashMap(int hsize)
{
    HashMap *hashmap = malloc(sizeof(HashMap));
    if(hashmap == NULL)
    {
        return NULL;
    }
    hashmap->table = malloc(sizeof(HashMapEntry *) * hsize);
    if(hashmap->table == NULL)
    {
        free(hashmap);
        return NULL;
    }
    hashmap->hsize = hsize;
    for (int i = 0; i < hsize; i++)
    {
        hashmap->table[i] = NULL;
    }
    return hashmap;
}

unsigned int _hash(const char *key)
{
    unsigned int hash_n = 0;
    while (*key)
    {
        hash_n = (hash_n << 5) + *key++;
    }
    return hash_n;
}

int add_HashMapEntry(HashMap *hashmap, const char *key, int value)
{
    unsigned int index;
    if(get_HashMapEntry_value(hashmap, key) != HM_KEY_NOT_FOUND)
    {
        //printf("[%s doesn't get in]\n\n", key);
        return HM_DUPLICATE_KEY;
    }
    index = _hash(key) % hashmap->hsize;
    //printf("Insertion index of %s:  %d\n\n", key, index);
    HashMapEntry *entry = malloc(sizeof(HashMapEntry));

    if(entry == NULL)
    {
        return HM_NOT_ENOUGH_MEMORY;
    }

    entry->key = strdup(key);
    entry->value = value;
    entry->next = hashmap->table[index];
    hashmap->table[index] = entry;

    return index;
}

int get_HashMapEntry_value(HashMap *hashmap, const char *key)
{
    unsigned int index = _hash(key) % hashmap->hsize;
    //printf("Index of '%s': %d\n", key, index);
    HashMapEntry *entry = hashmap->table[index];
    while (entry != NULL)
    {
        if (strcmp(entry->key, key) == 0)
        {
            return entry->value;
        }
        entry = entry->next;
    }
    return HM_KEY_NOT_FOUND;
}

int remove_HashMapEntry(HashMap *hashmap, const char *key)
{
    unsigned int index = _hash(key) % hashmap->hsize;
    HashMapEntry *prev = NULL;
    HashMapEntry *entry = hashmap->table[index];

    while (entry != NULL && strcmp(entry->key, key) != 0)
    {
        prev = entry;
        entry = entry->next;
    }

    if (entry == NULL)
    {
        return HM_KEY_NOT_FOUND;
    }

    if (prev == NULL)
    {
        hashmap->table[index] = entry->next;
    }
    else
    {
        prev->next = entry->next;
    }

    free(entry->key);
    free(entry);

    return HM_SUCCESS;
}

int update_HashMapEntry_value(HashMap *hashmap, const char *key, int val)
{
    unsigned int index = _hash(key) % hashmap->hsize;
    HashMapEntry *prev = NULL;
    HashMapEntry *entry = hashmap->table[index];

    while (entry != NULL && strcmp(entry->key, key) != 0)
    {
        prev = entry;
        entry = entry->next;
    }

    if (entry == NULL)
    {
        return HM_KEY_NOT_FOUND;
    }

    entry->value = val;

    return HM_SUCCESS;
}

void destroy_HashMap(HashMap *hashmap)
{
    for (int i = 0; i < hashmap->hsize; i++)
    {
        HashMapEntry *entry = hashmap->table[i];
        while (entry != NULL)
        {
            HashMapEntry *next = entry->next;
            free(entry->key);
            free(entry);
            entry = next;
        }
    }
    free(hashmap->table);
    free(hashmap);
    hashmap = NULL;
}

void show_HashMap (HashMap *hashmap)
{
    int i;

    if(hashmap == NULL)
    {
        return;
    }

    for(i = 0; i < hashmap->hsize; i++)
    {
        printf("index %d:\n", i);
        HashMapEntry *entry = hashmap->table[i];
        while (entry != NULL)
        {
            if(entry != NULL)
            {
                printf("key: %s | value: %d\n", entry->key, entry->value);
            }
            else
            {
                printf("NULL\n");
            }
            entry = entry->next;
        }
        printf("---------------\n");
    }
}
