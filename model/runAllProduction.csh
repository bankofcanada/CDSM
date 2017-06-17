#!/bin/csh/

set h = ..
set l = ../results/ns/trainingSets/myLog_MMMYY.txt

foreach d (`cat $h/results/ns/portFilesServer_MMMYY.txt`)
echo "$d"
echo "RUNNING: runThis.m for $d" >>& $l
cat << EOF > $h/model/runThis.m
warning off;
clear all;
penFactor=1;
strategyFile = '$h/dataFiles/$d.mat';
resultsFile = '$h/results/ns/trainingSets/tsBlocks/policyResults_$d.mat';
main;
EOF
matlab -nodisplay < $h/model/runThis.m >>& $l &
sleep 1
echo "COMPLETE: runThis.m FOR $d." >>& $l
rm -rf $h/model/runThis.m
end
