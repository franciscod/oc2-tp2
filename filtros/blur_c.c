#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "../tp2.h"

const int OFFSET_BLUE = 0;
const int OFFSET_GREEN = 1;
const int OFFSET_RED = 2;
const int OFFSET_ALPHA = 3;

#define M_PI 3.14159265358979323846

double G_sigma(int x, int y, float sigma){
    return(exp(-((x * x + y * y) / (2 * sigma * sigma))) / (2 * M_PI * sigma * sigma));
}

void blur_c(unsigned char *src, unsigned char *dst, int cols, int rows, float sigma, int radius){
    unsigned char (*src_matrix)[cols*4] = (unsigned char (*)[cols*4]) src;
    unsigned char (*dst_matrix)[cols*4] = (unsigned char (*)[cols*4]) dst;

    // Creo matriz de convolución
    double conv_matrix[2 * radius + 1][2 * radius + 1];
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
            double blue = 0;
            double green = 0;
            double red = 0;
            for(int x = -radius; x <= radius; x++){
                for(int y = -radius; y <= radius; y++){
                    blue += (double) (src_matrix[row + y][(col + x) * 4 + OFFSET_BLUE]) * conv_matrix[radius - y][radius - x];
                    green += (double) (src_matrix[row + y][(col + x) * 4 + OFFSET_GREEN]) * conv_matrix[radius - y][radius - x];
                    red += (double) (src_matrix[row + y][(col + x) * 4 + OFFSET_RED]) * conv_matrix[radius - y][radius - x];
                    // printf("%f %f %f\n", (float) (src_matrix[row + y][(col + x) * 4 + OFFSET_GREEN]), conv_matrix[radius - y][radius - x], green);
                }
            }

            // printf("%f %f %f\n", blue, green, red);
            dst_matrix[row][col * 4 + OFFSET_BLUE] = (unsigned char) blue;
            dst_matrix[row][col * 4 + OFFSET_GREEN] = (unsigned char) green;
            dst_matrix[row][col * 4 + OFFSET_RED] = (unsigned char) red;
            dst_matrix[row][col * 4 + OFFSET_ALPHA] = 255;
        }
    }
}
