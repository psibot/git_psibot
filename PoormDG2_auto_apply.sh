#!/bin/bash

# SCRIPT: PoormDG_auto_apply.sh
# REV: Version 1.0 
# PLATFORM: Solaris 
# AUTHOR: Coenraad
# Oracle Poorman's Data Gaurd 
# PURPOSE: Oracle Move RMAN Backupsets from Primary To Standby Server , 
#          Apply Replication run every 30 min from cron.
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
ORACLE_BASE=/db/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/12.1.0/db_1

##########################################################
################ BEGINNING OF MAIN #######################
##########################################################
echo
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo -- Step 1. Apply Changes STANDBY Database --
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo
date
export ORACLE_SID=$ORACLE_SID
$ORACLE_HOME/bin/rman target / <<EOF
run{
recover database;
}
EOF
exit 0

