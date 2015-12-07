$VAL build/tp2 -i asm blur img/circulos.bmp 5 15 | tee /tmp/outasm
$VAL build/tp2 -i c blur img/circulos.bmp 5 15 | tee /tmp/outc

git diff --color /tmp/outasm /tmp/outc
