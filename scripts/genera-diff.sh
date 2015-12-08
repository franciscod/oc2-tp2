./switch.sh comun
./build/tp2 -i  c  diff img/scene0.bmp img/scene400.bmp -t 500 | tail -1 | sed "s/.*://" > data/diff_c.txt
./build/tp2 -i asm diff img/scene0.bmp img/scene400.bmp -t 500 | tail -1 | sed "s/.*://" > data/diff_asm.txt

python ./scripts/figura_ciclos.py diff.png "Filtro Diff" diff_c diff_asm
