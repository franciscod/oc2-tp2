#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "../tp2.h"

const int OFFSET_BLUE = 0;
const int OFFSET_GREEN = 1;
const int OFFSET_RED = 2;
const int OFFSET_ALPHA = 3;

float G_sigma(int x, int y, float sigma){
    // printf("%f %f %f\n", (double) -((double)(x * x + y * y) / (double)(2 * (double)sigma * (double)sigma)), (double) pow(M_E, -((double)(x * x + y * y) / (double)(2 * (double)sigma * (double)sigma))), (double) (2 * M_PI * (double)sigma * (double)sigma));
    return(pow(M_E, -((x * x + y * y) / (2 * sigma * sigma))) / (2 * M_PI * sigma * sigma));
}

void blur_c(unsigned char *src, unsigned char *dst, int cols, int rows, float sigma, int radius){
    unsigned char (*src_matrix)[cols*4] = (unsigned char (*)[cols*4]) src;
    unsigned char (*dst_matrix)[cols*4] = (unsigned char (*)[cols*4]) dst;

    // Creo matriz de convolución
    float conv_matrix[2 * radius + 1][2 * radius + 1];
    for(int i = 0; i < 2 * radius + 1; i++){
        for(int j = 0; j < 2 * radius + 1; j++){
            conv_matrix[i][j] = G_sigma(radius - i, radius - j, sigma);
            // printf("%f ", conv_matrix[i][j]);
        }
        // printf("\n");
    }

    for(int row = radius; row < rows - radius; row++){
        for(int col = radius; col < cols - radius; col++){
            // Hago la sumatoria
            float blue = 0;
            float green = 0;
            float red = 0;
            for(int x = -radius; x <= radius; x++){
                for(int y = -radius; y <= radius; y++){
                    blue += (float) (src_matrix[row + y][(col + x) * 4 + OFFSET_BLUE]) * conv_matrix[radius - y][radius - x];
                    green += (float) (src_matrix[row + y][(col + x) * 4 + OFFSET_GREEN]) * conv_matrix[radius - y][radius - x];
                    red += (float) (src_matrix[row + y][(col + x) * 4 + OFFSET_RED]) * conv_matrix[radius - y][radius - x];
                    // printf("%f %f %f\n", (float) (src_matrix[row + y][(col + x) * 4 + OFFSET_GREEN]), conv_matrix[radius - y][radius - x], green);
                }
            }

            dst_matrix[row][col * 4 + OFFSET_BLUE] = floor(blue);
            dst_matrix[row][col * 4 + OFFSET_GREEN] = floor(green);
            dst_matrix[row][col * 4 + OFFSET_RED] = floor(red);
            dst_matrix[row][col * 4 + OFFSET_ALPHA] = 255;
        }
    }
}
