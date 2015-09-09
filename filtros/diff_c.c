
#include <stdlib.h>
#include <math.h>
#include "../tp2.h"

void diff_c (
	unsigned char *src,         // Primera imagen.
	unsigned char *src_2,       // Segunda imagen
	unsigned char *dst,         // Destino
	int m,                      // Filas
	int n,                      // Columnas
	int src_row_size,           // Tama�o de imagen 1
	int src_2_row_size,         // Tama�o de imagen 2
	int dst_row_size            // Tama�o destino
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*src_2_matrix)[src_2_row_size] = (unsigned char (*)[src_2_row_size]) src_2;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

    for (i = 0; i < src_row_size; i++){
        dst_matrix[i] = src_matrix[i] - src_2_matrix[i];
    }
    for (i = 0; i < src_row_size; i+=4){
        int k = max(max(dst_matrix[i], dst_matrix[i+1]), dst_matrix[i+2]);
        dst_matrix[i] = k;
        dst_matrix[i+1] = k;
        dst_matrix[i+2] = k;
        dst_matrix[i+3] = 255;
    }
}
