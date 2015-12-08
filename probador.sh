#USO: sh probador.sh <filtro> <imagen> <parametros del filtro> <sigma del bmpdiff>
if [ $1 = "diff" ]; then
	./build/tp2 -i asm diff $2 $3
	./build/tp2 -i c diff $2 $3
	ASM=$(expr "$2.diff.ASM.bmp" | sed 's/^....//')
	C=$(expr "$2.diff.C.bmp" | sed 's/^....//')
	RET=$(./build/bmpdiff -s $ASM $C $4)
	if [ "$RET" ]; then
		echo "Diferencias:"
		echo $RET
	else
	    echo "No hay diferencias"
	fi
fi
if [ $1 = "blur" ]; then
	./build/tp2 -i asm blur $2 $3 $4
	./build/tp2 -i c blur $2 $3 $4
	ASM=$(expr "$2.blur.ASM.bmp" | sed 's/^....//')
	C=$(expr "$2.blur.C.bmp" | sed 's/^....//')
	RET=$(./build/bmpdiff -s $ASM $C $5)
	if [ "$RET" ]; then
		echo "Diferencias:"
		echo $RET
	else
	    echo "No hay diferencias"
	fi
fi
