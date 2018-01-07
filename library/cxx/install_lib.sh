
exe=`readlink -f $0`
path=`dirname $exe`

cd $path

#recursive_copy_h() {
#  local d="$1"
#  local dest="$2"
#  for f in `ls $d`; do
#    if [ -d $d/$f ]; then
#      echo mkdir -p $dest/$d/$f
#      recursive_copy_h "$d/$f" "$dest"
#    elif [ -f "$d/$f" ] && [[ $f = *.h ]]; then
#      echo cp "$d/$f"  "$dest/$d"
#    fi
#  done
#}
#
## install utils
#mkdir -p $HOME/include/jutils
#mkdir -p $HOME/lib
#recursive_copy_h include $HOME/include/jutils


mkdir build
cd build
cmake ..
make -j 4
sudo make install
