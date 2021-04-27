#include <stdio.h>
#include <stdlib.h>

#include "list.h"

// DEBUG
unsigned int mallocs = 0;
unsigned int frees = 0;
size_t total = 0;

void* dmalloc(size_t sz) {
	void* mem = malloc(sz);
	total += sz;
	mallocs++;
	//printf("malloc: %p\n", mem);
	return mem;
}
void dfree(void* mem) {
	frees++;
	//printf("free:   %p\n", mem);
	free(mem);
}
void checkatend() {
	printf("frees:   %d\nmallocs: %d\ntotal:   %ld bytes\n", frees, mallocs, total);
}
// END OF DEBUG

void lprint(list* l) {
	lnode* pos = l->first;
	for (unsigned int i = 0; i < l->count; i++) {
		bprint(pos->val);
		pos = pos->next;
	}
}

list* linit(unsigned int num, list_val_t val[num]) {
	if (num <= 0) exit(1);

	list*  l = dmalloc(sizeof(list));
	lnode* n = dmalloc(sizeof(lnode));
	n->val = val[0];
	l->first = n;
	l->last  = n;
	l->count = 1;

	for (unsigned int i = 1; i < num; i++)
		lappend(l, val[i]);

	return l;
}

void lfree(list* l) {
	lnode* pos = l->first;
	for (unsigned int i = 0; i < l->count; i++) {
		lnode* tmp;
		tmp = pos->next;
		dfree(pos);
		pos = tmp;
	}
	dfree(l);
}

void lappend(list* l, list_val_t val) {
	l->last->next = dmalloc(sizeof(lnode)); // create new node at the end
	l->last->next->val = val; // paste the value
	l->last = l->last->next; // move the end pointer
	l->count++;
}

void* ldel(list* l, unsigned int d) {
	if (d >= l->count) exit(1);
	lnode* todel; // the node to be deleted

	if (d == 0) { // edge case for first node
		todel = l->first;
		l->first = l->first->next;
	} else { // all other cases
		lnode* pos = l->first;
		for (unsigned int i = 0; i < (d - 1); i++)
			pos = pos->next;

		todel = pos->next;
		pos->next = todel->next;

		if (d == l->count - 1) l->last = pos;
	}

	l->count -= 1;
	void* val = todel->val;
	dfree(todel);
	return val;
}

