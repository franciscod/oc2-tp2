#include <stdlib.h>
#include <math.h>
#include "../tp2.h"

unsigned char max(unsigned char a, unsigned char b){
	if(a>=b){return a;}else{return b;}
}

void diff_c (unsigned char *src, unsigned char *src_2, unsigned char *dst, int m, int n, int src_row_size, int src_2_row_size, int dst_row_size){
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*src_2_matrix)[src_2_row_size] = (unsigned char (*)[src_2_row_size]) src_2;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

    for (int y = 0; y < n; y++){
        for (int x = 0; x < 4*m; x+=4){
            int maximo = max(
                             max(
                                 abs(src_matrix[y][x] - src_2_matrix[y][x]),
                                 abs(src_matrix[y][x+1] - src_2_matrix[y][x+1])),
                                 abs(src_matrix[y][x+2] - src_2_matrix[y][x+2])
                                 );
            dst_matrix[y][x+0] = maximo;
            dst_matrix[y][x+1] = maximo;
            dst_matrix[y][x+2] = maximo;
            dst_matrix[y][x+3] = 255;
        }
    }
}
