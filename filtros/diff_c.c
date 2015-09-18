/*
30 min de escribir esto, contando:
  - entender como funciona la matriz
  - como pintar los valores de cada canal
  - buscando max y finalmente escribiendola
*/

#include <stdlib.h>
#include <math.h>
#include "../tp2.h"

#define B 0
#define G 1
#define R 2
#define A 3

#define pix(matrix, x, y, c) matrix[y][x*4+c]

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

	for (int x = 0; x < m; x++) {
		for (int y = 0; y < n; y++) {

			n_inf = max(	abs(pix(src_matrix, x, y, R) - pix(src_2_matrix, x, y, R)),
						max(
							abs(pix(src_matrix, x, y, G) - pix(src_2_matrix, x, y, G)),
							abs(pix(src_matrix, x, y, B) - pix(src_2_matrix, x, y, B))
					));

			pix(dst_matrix, x, y, R) = pix(dst_matrix, x, y, G) = pix(dst_matrix, x, y, B) = n_inf;
			pix(dst_matrix, x, y, A) = 255;
		}
	}
}
