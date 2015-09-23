#define _GNU_SOURCE

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "../tp2.h"

void blur_c(unsigned char *src, unsigned char *dst, int cols, int filas, float sigma, int radius){
    unsigned char (*src_matrix)[cols*4] = (unsigned char (*)[cols*4]) src;
    unsigned char (*dst_matrix)[cols*4] = (unsigned char (*)[cols*4]) dst;

    double convol_matrix[2*radius+1][2*radius+1];

    double aux2 = (2*sigma*sigma);
    double aux = (double)(1/(M_PI*aux2));
    for(int j = 0; j < 2*radius+1; j++){
        for(int i = 0; i < 2*radius+1; i++){
            matriz[j][i] = (double) (aux * exp(-(j*j+i*i)/aux2));
            printf("%.4f ", matriz[0][0]);
        }
        printf("\n");
    }

}
