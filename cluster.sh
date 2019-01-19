#!/bin/bash


sudo sh -c "echo '/home/ubuntu/OpenFOAM  *(rw,sync,no_subtree_check)' >> /etc/exports"
sudo exportfs -ra
sudo service nfs-kernel-server start

SPIPS="$2 $3 $4"

for IP in $SPIPS ; do ssh $IP 'rm -rf ${HOME}/OpenFOAM/*' ; done
for IP in $SPIPS ; do ssh $IP 'sudo mount "$1":${HOME}/OpenFOAM ${HOME}/OpenFOAM' ; done


./pobieranie_z_s3


cd ${FOAM_RUN}



cd cluster_case

echo -e ""$1"
"$2"
"$3"
"$4"" > ./machines

fluent3DMeshToFoam RW_opt_bez_warstwy.msh
#polyDualMesh 15 -overwrite -doNotPreserveFaceZones
decomposePar
#refineMesh -overwrite




foamJob -p -screen simpleFoam

#while [ ps -p $! >/dev/null ]; #do
 # sleep 1;
#echo "waiting"
#done


reconstructPar

rm -r 60 120 180 240 300 RW_opt_bez_warstwy.msh

cd ${FOAM_RUN}
mkdir cluster_case_policzony
tar -zcvf cluster_case_policzony/cluster_case_policzony.tar.gz ${FOAM_RUN}/cluster_case



aws s3 sync ${FOAM_RUN}/cluster_policzony s3://dyskala/cluster_case_policzony


