#!/bin/bash


DOMAIN=TAPCON.ORG
SERVERS="hdfs-1 hdfs-2"
KEYTAB=/opt/keytab
mkdir -p $KEYTAB

for n in $SERVERS; do
  #for m in hdfs yarn mapred; do
  #      kadmin.local -q "addprinc -randkey $m/$n@$DOMAIN"
  #      kadmin.local -q "xst -norandkey -k $KEYTAB/$m-$n.keytab $m/$n@$DOMAIN"
  #done
  echo
kadmin.local -q "addprinc -randkey HTTP/$n@$DOMAIN"
kadmin.local -q "xst -norandkey -k $KEYTAB/HTTP-$n.keytab HTTP/$n@$DOMAIN"
done

