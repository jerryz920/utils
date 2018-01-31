cd time; gcc -O3 time.c -o jtime; cp jtime /usr/bin/; cd ..
apt-get update
apt-get install python-pip
pip install numpy
cp stat/jstat /usr/bin/;

for d in `ls`; do
  if test -d $d; then
    cd $d;
    if test -f install.sh; then
      bash install.sh
    fi
    cd ..
  fi
done
