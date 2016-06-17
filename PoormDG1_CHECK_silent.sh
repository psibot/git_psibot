#!/bin/bash

# SCRIPT: PoormDG1_CHECK_silent.sh
# REV: Version 1.0
# PLATFORM: Solaris
# AUTHOR: Coenraad
# Oracle Poorman's Data Gaurd
# PURPOSE: Oracle Move RMAN Backupsets from Primary To Standby Server ,
#          TEST Replication
#
# Note : RSA public key for SSH must be genareted on both servers beforehand
#
##########################################################
########### DEFINE FILES AND VARIABLES HERE ##############
##########################################################
. /export/home/oracle/.profile
# Veriables ! ONLY CHANGE THESE!
ORACLE_OS_USR=oracle
ORACLE_SID=JDEPDCONT1
ORACLE_STANDBY=jdestandbydb
ORACLE_BASE=/db/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/12.1.0/db_1
ORACLE_SCRIPTS=/db/app/oracle/scripts/maint_scripts
##########################################################
################ BEGINNING OF MAIN #######################
##########################################################
${ORACLE_SCRIPTS}/silent1.sh > value1
${ORACLE_SCRIPTS}/silent2.sh > value2
v1=`cat value1`
v2=`cat value2`
if [ ${v2} < ${v1} ]
then
echo " Start resync!"
export ORACLE_SID=$ORACLE_SID
rman target / <<EOF
RESTORE ARCHIVELOG FROM SEQUENCE ${v1} UNTIL SEQUENCE ${v2};
EOF
 
${ORACLE_SCRIPTS}/PoormDG1_apply_auto.sh
${ORACLE_SCRIPTS}/PoormDG1_2_apply_auto.sh
read -p "Press [Enter] key to continue..."

ssh oracle@$ORACLE_STANDBY /db/app/oracle/scripts/maint_scripts/PoormDG2_auto_apply.sh
${ORACLE_SCRIPTS}/mail_check.sh

read -p "Press [Enter] key to continue..."

rm ${ORACLE_SCRIPTS}/value1
rm ${ORACLE_SCRIPTS}/value2
else
  echo "VALUES ARE EQUAL!!!"
exit 0
fi

