#!/bin/bash
#SABS RMAN Backup
#Declare array with  elements
. /home/oracle/.bash_profile

ARRAY=(ORACLE_SID)
# get number of elements in the array
ELEMENTS=${#ARRAY[@]}

# echo each element in array 

# for loop
for (( i=0;i<$ELEMENTS;i++)); do
    clear
    echo Starting RMAN Backup
    echo ${ARRAY[${i}]}
    echo $(date)
    export ORACLE_SID=${ARRAY[${i}]}
    rman target / <<EOF
    crosscheck backupset;
    backup AS COMPRESSED BACKUPSET database plus archivelog delete input;
    delete noprompt obsolete;
    crosscheck archivelog all;
    crosscheck backupset;
    exit
EOF
done
