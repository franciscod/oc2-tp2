# modo de uso:
# ./switch.sh <directorio del cual traer>
# por ejemplo, para seleccionar y compilar las implementaciones en el directorio filtros/gabriel-orig/
# ./switch.sh gabriel-orig
#

SWITCH_DIR=$1 # primer parametro

# primero que nada limpia el build dir
make clean

for f in blur_c.c blur_asm.asm diff_c.c diff_asm.asm; do
	# limpia lo que habia
	rm filtros/$f

	# si no esta el archivo este
	if [ ! -f ./filtros/$SWITCH_DIR/$f ]; then
		# pone la implementacion vacia como symlink
		ln -s vacia/$f filtros/$f
	else
		# si esta, lo pone
		ln -s $SWITCH_DIR/$f filtros/$f
	fi
done

# compila todo
make
