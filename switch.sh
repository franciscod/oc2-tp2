# modo de uso:
# ./switch.sh <directorio del cual traer>
# por ejemplo, para seleccionar y compilar las implementaciones en el directorio filtros/gabriel-orig/
# ./switch.sh gabriel-orig
#

BASE_PATH=./filtros/

VACIA_PATH=${BASE_PATH}vacia

SWITCH_DIR=$1 # primer parametro
SW_PATH=${BASE_PATH}${SWITCH_DIR}

# primero que nada limpia el build dir
make clean

for f in blur_c.c blur_asm.asm diff_c.c diff_asm.asm; do
	# limpia lo que habia
	rm -f $BASE_PATH/$f

	# si no esta el archivo este
	if [ ! -f $SW_PATH/$f ]; then
		# pone la implementacion vacia
		# ln -s vacia/$f filtros/$f
		cp $VACIA_PATH/$f $BASE_PATH/$f
	else
		# si esta implementado en SWITCH_DIR, lo pone
		# ln -s $SWITCH_DIR/$f filtros/$f
		cp $SW_PATH/$f $BASE_PATH/$f
	fi
done

# compila todo
make
