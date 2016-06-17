#!/bin/bash

# SCRIPT: resync_manual_miss.sh
# REV: Version 1.0 
# PLATFORM: Solaris 
# AUTHOR: Coenraad
# Oracle Poorman's Data Gaurd 
# PURPOSE: RESYNC OF MISSING LOGFILES
#            
# Note : RSA public key for SSH must be genareted on both servers beforehand
# 
##########################################################
########### DEFINE FILES AND VARIABLES HERE ##############
##########################################################

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
echo -- Step 1. RESTORE MISSING LOG FILES      --
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo 
echo "Please LOGS seq# from: "
read val1
echo "Please LOGS seq# to: "
read val2
echo RESTORE ARCHIVELOG FROM SEQUENCE ${val1} UNTIL SEQUENCE ${val2}; > cmdfile.txt
export ORACLE_SID=$ORACLE_SID
$ORACLE_HOME/bin/rman target=/  @cmdfile.txt
exit 0
