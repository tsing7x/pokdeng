fileName=`date "+fix%m%d%H_%M.zip"`
fileName64=`date "+fix%m%d%H_%M_64.zip"`
sh $QUICK_V3_ROOT/quick/bin/compile_scripts.sh -i ./src/ -o ./$fileName -e xxtea_zip -ek PokDeng655355 -es pokdeng@boyaa2015 -b 32
sh $QUICK_V3_ROOT/quick/bin/compile_scripts.sh -i ./src/ -o ./$fileName64 -e xxtea_zip -ek PokDeng655355 -es pokdeng@boyaa2015 -b 64
