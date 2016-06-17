#!/bin/bash

# SCRIPT: PoormDG1_test.sh
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
##########################################################
################ BEGINNING OF MAIN #######################
##########################################################
echo
echo -- Step 1. TEST PROD  Database --
echo
export ORACLE_SID=$ORACLE_SID
$ORACLE_HOME/bin/sqlplus -s '/as sysdba' <<EOF
prompt
@/db/app/oracle/scripts/maint_scripts/prod_arch.sql
EOF

ssh oracle@$ORACLE_STANDBY /db/app/oracle/scripts/maint_scripts/PoormDG2_test.sh
exit 0
