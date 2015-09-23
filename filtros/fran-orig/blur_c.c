#include <stdlib.h>
#include <stdio.h>
#include <math.h>


#define LE_WILD_PI 3.14159265358979323846

#include "../tp2.h"

// arranque 19:31
// float


#define B 0
#define G 1
#define R 2
#define A 3

double g(float sigma, int x, int y) {
    float x2 = (float) x * x;
    float y2 = (float) y * y;
    float sigma22 = 2 * sigma * sigma;
    float num = exp(-((x2 + y2) / sigma22));
    float den = LE_WILD_PI * sigma22;
    return num/den;
}

/*

111
101
111

3 3 3 3 3 3 3
3 2 2 2 2 2 3
3 2 1 1 1 2 3
3 2 1 0 1 2 3
3 2 1 1 1 2 3
3 2 2 2 2 2 3
3 3 3 3 3 3 3

3 3 3 3 3 3 _
3 2 2 2 2 _ _
3 2 1 1 _ _ _
3 2 1 _ _ _ _
3 2 1 1 1 2 3
3 2 2 2 2 2 3
3 3 3 3 3 3 3

. . . _
. . _ _
. _ _ _
_ _ _ _

. . . 9
. . 5 8
. 2 4 7
0 1 3 6

6 7 8 9
3 4 5 8
1 2 4 7
0 1 3 6


*/

void blur_c (
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    float sigma,
    int radius)
{

    unsigned char (*src_matrix)[cols*4] = (unsigned char (*)[cols*4]) src;
    unsigned char (*dst_matrix)[cols*4] = (unsigned char (*)[cols*4]) dst;

    float tmp[filas][cols*4];
    float convol[radius+1][radius+1];

    for(int i=0; i<=radius; i++) {
        for(int j=0; j<=radius; j++) {
            convol[i][j] = g(sigma, i, j);
        }
    }

    // float tmp_tri[filas][cols*4][radius*radius+radius/2];
    // float convol_tri[radius*radius+radius/2];
    //
    // for(int i=0; i<=radius; i++) {
    //     for(int j=i; j<=radius; j++) {
    //         convol_tri[]//???
    //     }
    // }

    // bordes superior y inferior + esquinas
    for (int y = 0; y < radius; y++) {
        for (int x = 0; x < cols; x++) {
            dst_matrix[y][x*4+R] = src_matrix[y][x*4+R];
            dst_matrix[y][x*4+G] = src_matrix[y][x*4+G];
            dst_matrix[y][x*4+B] = src_matrix[y][x*4+B];
            dst_matrix[y][x*4+A] = 255;

            dst_matrix[filas - radius + y][x*4+R] = src_matrix[filas - radius + y][x*4+R];
            dst_matrix[filas - radius + y][x*4+G] = src_matrix[filas - radius + y][x*4+G];
            dst_matrix[filas - radius + y][x*4+B] = src_matrix[filas - radius + y][x*4+B];
            dst_matrix[filas - radius + y][x*4+A] = 255;
        }
    }

    // bordes izquierdo y derecho, sin esquinas
    for (int y = radius; y < (filas - radius); y++) {
        for (int x = 0; x < radius; x++) {
            dst_matrix[y][x*4+R] = src_matrix[y][x*4+R];
            dst_matrix[y][x*4+G] = src_matrix[y][x*4+G];
            dst_matrix[y][x*4+B] = src_matrix[y][x*4+B];
            dst_matrix[y][x*4+A] = 255;

            dst_matrix[y][(cols - radius + x)*4+R] = src_matrix[y][(cols - radius + x)*4+R];
            dst_matrix[y][(cols - radius + x)*4+G] = src_matrix[y][(cols - radius + x)*4+G];
            dst_matrix[y][(cols - radius + x)*4+B] = src_matrix[y][(cols - radius + x)*4+B];
            dst_matrix[y][(cols - radius + x)*4+A] = 255;
        }
    }



    for (int y = radius; y < filas-radius; y++) {
        for (int x = radius; x < cols-radius; x++) {
            tmp[y][x*4+R] = 0;
            tmp[y][x*4+G] = 0;
            tmp[y][x*4+B] = 0;
        }
    }


    for (int y = radius; y < filas-radius; y++) {
        for (int x = radius; x < cols-radius; x++) {
            for (int i = -radius; i <= radius; i++) {
                for (int j = -radius; j <= radius; j++) {
                    tmp[y][x*4+R] += src_matrix[y+i][(x+j)*4+R] * convol[abs(i)][abs(j)];
                    tmp[y][x*4+G] += src_matrix[y+i][(x+j)*4+G] * convol[abs(i)][abs(j)];
                    tmp[y][x*4+B] += src_matrix[y+i][(x+j)*4+B] * convol[abs(i)][abs(j)];
                }
            }
        }
    }

    for (int y = radius; y < filas-radius; y++) {
        for (int x = radius; x < cols-radius; x++) {
                dst_matrix[y][x*4+R] = (int) tmp[y][x*4+R];
                dst_matrix[y][x*4+G] = (int) tmp[y][x*4+G];
                dst_matrix[y][x*4+B] = (int) tmp[y][x*4+B];
                dst_matrix[y][x*4+A] = 255;
        }
    }



}
