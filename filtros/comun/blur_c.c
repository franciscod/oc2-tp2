#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <assert.h>
#include "../tp2.h"

const int OFFSET_BLUE = 0;
const int OFFSET_GREEN = 1;
const int OFFSET_RED = 2;
const int OFFSET_ALPHA = 3;

#define M_PI 3.14159265358979323846

float G_sigma(int x, int y, float sigma){
    return(exp(-((x * x + y * y) / (2 * sigma * sigma))) / (2 * M_PI * sigma * sigma));
}

void imprimir_mat(float *mat, int filas, int columnas){
    for(int i = 0; i < filas; i++){
        for(int j = 0; j < columnas; j++){
            printf("%f ", mat[(i * columnas + j)]);
        }
        printf("\n");
    }
}

unsigned int calcular_pixel_c(unsigned char *src, float *conv, int cols, int convside) {
    unsigned char (*src_matrix)[cols*4] = (unsigned char (*)[cols*4]) src;
    float (*conv_matrix)[convside] = (float (*)[convside]) conv;

    float blue = 0.0;
    float green = 0.0;
    float red = 0.0;
    for(int x = 0; x <= convside; x++){
        for(int y = 0; y <= convside; y++){
            blue  += ((float) src_matrix[y][(x) * 4 + OFFSET_BLUE]) * conv_matrix[y][x];
            green += ((float) src_matrix[y][(x) * 4 + OFFSET_GREEN]) * conv_matrix[y][x];
            red   += ((float) src_matrix[y][(x) * 4 + OFFSET_RED]) * conv_matrix[y][x];
        }
    }

    unsigned int ret = 0;
    ret |= (((unsigned char) roundf(blue)) << 0);
    ret |= (((unsigned char) roundf(green)) << 8);
    ret |= (((unsigned char) roundf(red)) << 16);
    ret |= (255 << 24);
    //printf("%f %f %f %x\n", red, green, blue, ret);
    return ret;
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
	// int primero = 1;

    for(int row = radius; row < rows - radius; row++){
        for(int col = radius; col < cols - radius; col++){
            //       // Hago la sumatoria
            //       float blue = 0.0;
            //       float green = 0.0;
            //       float red = 0.0;
            //       for(int x = -radius; x <= radius; x++){
            //           for(int y = -radius; y <= radius; y++){
            //               blue  += ((float) src_matrix[row + y][(col + x) * 4 + OFFSET_BLUE]) * conv_matrix[radius - y][radius - x];
            //               green += ((float) src_matrix[row + y][(col + x) * 4 + OFFSET_GREEN]) * conv_matrix[radius - y][radius - x];
            //               red   += ((float) src_matrix[row + y][(col + x) * 4 + OFFSET_RED]) * conv_matrix[radius - y][radius - x];
            //               // printf("%f %f %f\n", (float) (src_matrix[row + y][(col + x) * 4 + OFFSET_GREEN]), conv_matrix[radius - y][radius - x], green);
            //           }
            //       }
            //       // blue = blue > 255 ? 255 : (blue < 0 ? 0 : blue);
            //       // green = green > 255 ? 255 : (green < 0 ? 0 : green);
            //       // red = red > 255 ? 255 : (red < 0 ? 0 : red);
            //       // printf("%f %f %f\n", blue, green, red);
            //       dst_matrix[row][col * 4 + OFFSET_BLUE] = (unsigned char) roundf(blue);
            //       dst_matrix[row][col * 4 + OFFSET_GREEN] = (unsigned char) roundf(green);
            //       dst_matrix[row][col * 4 + OFFSET_RED] = (unsigned char) roundf(red);
            //       dst_matrix[row][col * 4 + OFFSET_ALPHA] = 255;

			// if (!primero) continue;
			// primero = 0;
        	// printf("ESTE ES TU ENTERO PIBE %x %x %x %x\n", 255, (unsigned char) red, (unsigned char) green, (unsigned char) blue);

            // version que llama a calcular_pixel_c

            //unsigned int pix = calcular_pixel_c(&src_matrix[row-radius][(col-radius)*4], conv_matrix, cols, 2*radius+1);
            assert(&src_matrix[row-radius][(col-radius)*4] == (src + (row-radius) * cols*4 + (col-radius)*4));
            assert(&src_matrix[row-radius][(col-radius)*4] == (src + ((row-radius) * cols + (col-radius))*4));
            unsigned int pix = calcular_pixel_c(src + ((row-radius) * cols + (col-radius))*4, conv_matrix, cols, 2*radius+1);

            dst_matrix[row][col * 4 + OFFSET_BLUE] = (unsigned char) ((pix >> 0) & 0xFF);
            dst_matrix[row][col * 4 + OFFSET_GREEN] = (unsigned char) ((pix >> 8) & 0xFF);
            dst_matrix[row][col * 4 + OFFSET_RED] = (unsigned char) ((pix >> 16) & 0xFF);
            dst_matrix[row][col * 4 + OFFSET_ALPHA] = (unsigned char) ((pix >> 24) & 0xFF);
        }
    }
}
