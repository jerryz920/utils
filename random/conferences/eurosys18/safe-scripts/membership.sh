IAAS_IP="152.3.145.38:444"
ATTEST_IP="152.3.145.138:4144"
echo testing membership
base=${1:-31018}
base2=$((base+100))
cbase=$((base+10))
cbase2=$((base+50))
c2base=$((cbase))
c2base2=$((cbase+6))

curl http://10.10.1.39:7777/postObjectAcl -d "{ \"principal\": \"bob\",  \"otherValues\": [\"bob:object1\", \"git://github.com/jerryz920/spark\"] }"
#curl http://10.10.1.39:7777/postObjectAcl -d "{ \"principal\": \"bob\",  \"otherValues\": [\"bob:object1\", \"git://github.com/jerryz920/docker\"] }"
curl http://10.10.1.39:7777/postImageProperty -d "{ \"principal\": \"$IAAS_IP\",  \"otherValues\": [\"membership-image-hash\", \"*\", \"git://github.com/jerryz920/docker\"]}"
curl http://10.10.1.39:7777/postImageProperty -d "{ \"principal\": \"$IAAS_IP\",  \"otherValues\": [\"membership-image-hash2\", \"*\", \"git://github.com/jerryz920/spark\"]}"

msg=`curl http://10.10.1.39:7777/postInstanceSet -d "{ \"principal\": \"$IAAS_IP\",  \"otherValues\": [\"2\", \"membership-image-hash\", \"image\", \"6.6.6.7:$base-$base2\", \"*\"] }"`
echo $msg | tee key
inst_id=`python id.py <key`
curl http://10.10.1.39:7777/updateSubjectSet -d "{ \"principal\": \"6.6.6.7:$base-$base2\",  \"otherValues\": [\"$inst_id\"] }"

msg=`curl http://10.10.1.39:7777/postInstanceSet -d "{ \"principal\": \"6.6.6.7:$base-$base2\",  \"otherValues\": [\"2\", \"membership-image-hash2\", \"image\", \"6.6.6.7:$cbase-$cbase2\", \"*\"] }"`
echo $msg | tee key
inst_id=`python id.py <key`
curl http://10.10.1.39:7777/updateSubjectSet -d "{ \"principal\": \"6.6.6.7:$cbase-$cbase2\",  \"otherValues\": [\"$inst_id\"] }"
#curl http://10.10.1.39:7777/postAttesterImage -d "{ \"principal\": \"6.6.6.7:$base-$base2\",  \"otherValues\": [\"membership-image-hash2\"]}"

msg=`curl http://10.10.1.39:7777/postInstanceSet -d "{ \"principal\": \"$IAAS_IP\",  \"otherValues\": [\"3\", \"membership-image-hash\", \"image\", \"6.6.6.8:$base-$base2\", \"*\"] }"`
echo $msg | tee key
inst_id=`python id.py <key`
curl http://10.10.1.39:7777/updateSubjectSet -d "{ \"principal\": \"6.6.6.8:$base-$base2\",  \"otherValues\": [\"$inst_id\"] }"


msg=`curl http://10.10.1.39:7777/postInstanceSet -d "{ \"principal\": \"6.6.6.8:$base-$base2\",  \"otherValues\": [\"3\", \"membership-image-hash2\", \"image\", \"6.6.6.8:$cbase-$cbase2\", \"*\"] }"`
echo $msg | tee key
inst_id=`python id.py <key`
curl http://10.10.1.39:7777/updateSubjectSet -d "{ \"principal\": \"6.6.6.8:$cbase-$cbase2\",  \"otherValues\": [\"$inst_id\"] }"


msg=`curl http://10.10.1.39:7777/postWorkerSet -d "{ \"principal\": \"6.6.6.8:$cbase-$cbase2\",  \"otherValues\": [\"cluster1\", \"6.6.6.7:$((cbase+2))\", \"*\"] }"`
echo $msg | tee key
inst_id=`python id.py <key`
msg=`curl http://10.10.1.39:7777/updateSubjectSet -d "{ \"principal\": \"6.6.6.7:$cbase-$cbase2\",  \"otherValues\": [\"$inst_id\"] }"`
echo $msg | tee key
inst_id_worker=`python id.py <key`

curl http://10.10.1.39:7777/workerAccessesObject -d "{ \"principal\": \"152.3.145.138:4144\", \"bearerRef\":\"$inst_id_worker\", \"otherValues\": [\"6.6.6.7:$((cbase+2))\", \"bob:object1\"]}"
