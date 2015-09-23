#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "../tp2.h"

#define OFFSET i * cols + j;

void calcular_matriz(float *matriz, int r, float s){
    int centro = ((2*r)+2)/2;
    int aux2 = (2*s*s);
    int aux = (1/(M_PI*aux2));
    for(int i = 0; i <= ((2*r)+1); i++){
        for(int j = 0; j <= ((2*r)+1); j++){
            matriz[OFFSET] = aux * exp(-(((j-centro)*(j-centro)+(i-centro)*(i-centro))/aux2);
            printf(%.4f, matriz[OFFSET]);
        }
    }
return;
}

void blur_c(unsigned char *src, unsigned char *dst, int cols, int filas, float sigma, int radius){
    unsigned char (*src_matrix)[cols*4] = (unsigned char (*)[cols*4]) src;
    unsigned char (*dst_matrix)[cols*4] = (unsigned char (*)[cols*4]) dst;

    // Reservo memoria para la matriz de convolusion.
    float *convol_matrix = (float *)malloc(((2*radius)+1) * ((2*radius)+1) * sizeof(float));

    calcular_matriz(convol_matrix);

    free(convol_matrix);
}
