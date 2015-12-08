#include <stdlib.h>
#include <math.h>
#include "../tp2.h"

#define B 0
#define G 1
#define R 2
#define A 3
#define CANALES 4
unsigned char max(unsigned char a, unsigned char b) {
	return (a>=b ? a : b);
}


void diff_c (unsigned char *src, unsigned char *src_2, unsigned char *dst, int m, int n, int src_row_size, int src_2_row_size, int dst_row_size){
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*src_2_matrix)[src_2_row_size] = (unsigned char (*)[src_2_row_size]) src_2;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

    for (int y = 0; y < n; y++){
        for (int x = 0; x < CANALES*m; x+=CANALES){

            int maximo = max(max(
                             abs(src_matrix[y][x+B] - src_2_matrix[y][x+B]),
                             abs(src_matrix[y][x+G] - src_2_matrix[y][x+G])),
                             abs(src_matrix[y][x+R] - src_2_matrix[y][x+R]));

            dst_matrix[y][x+B] = maximo;
            dst_matrix[y][x+G] = maximo;
            dst_matrix[y][x+R] = maximo;
            dst_matrix[y][x+A] = 255;
        }
    }
}
