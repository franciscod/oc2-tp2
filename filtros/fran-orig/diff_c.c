/*
30 min de escribir esto, contando:
  - entender como funciona la matriz
  - como pintar los valores de cada canal
  - buscando max y finalmente escribiendola
  - iterar correctamente y/x aprovechando la estructura mejora casi al 200% la performance
*/

#include <stdlib.h>
#include <math.h>
#include "../tp2.h"

#define B 0
#define G 1
#define R 2
#define A 3

unsigned char max(unsigned char a, unsigned char b) {
	return (a>=b ? a : b);
}

void diff_c (
	unsigned char *src,
	unsigned char *src_2,
	unsigned char *dst,
	int m,
	int n,
	int src_row_size,
	int src_2_row_size,
	int dst_row_size
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*src_2_matrix)[src_2_row_size] = (unsigned char (*)[src_2_row_size]) src_2;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

	unsigned char n_inf;

	for (int y = 0; y < n; y++) {
		for (int x = 0; x < m; x++) {

			n_inf = max(	abs(src_matrix[y][x*4+R] - src_2_matrix[y][x*4+R]),
						max(
							abs(src_matrix[y][x*4+G] - src_2_matrix[y][x*4+G]),
							abs(src_matrix[y][x*4+B] - src_2_matrix[y][x*4+B])
					));

			dst_matrix[y][x*4+R] = dst_matrix[y][x*4+G] = dst_matrix[y][x*4+B] = n_inf;
			dst_matrix[y][x*4+A] = 255;
		}
	}
}
