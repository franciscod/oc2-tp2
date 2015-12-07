$VAL build/tp2 -i asm blur img/lena24.bmp 1 1 | tee /tmp/outasm
$VAL build/tp2 -i c blur img/lena24.bmp 1 1 | tee /tmp/outc

git diff --color /tmp/outasm /tmp/outc
