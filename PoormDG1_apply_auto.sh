#!/bin/bash

# SCRIPT: PoormDG1_apply_auto.sh
# REV: Version 1.0 
# PLATFORM: Solaris 
# AUTHOR: Coenraad
# Oracle Poorman's Data Gaurd 
# PURPOSE: Oracle Move Archivelogs from Primary To Stanby Server , 
#          This script can run 5 min from cron.
#            
# Note : RSA public key for SSH must be genareted on both servers beforehand
# 
##########################################################
########### DEFINE FILES AND VARIABLES HERE ##############
##########################################################
. /export/home/oracle/.profile
# Veriables ! ONLY CHANGE THESE!
ORACLE_BASE=/db/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/12.1.0/db_1
ORACLE_PRIMARY=$hostname
ORACLE_STANDBY=jdestandbydb
ORACLE_OS_USR=oracle
ORACLE_SID=JDEPDCONT1
ORACLE_ARC_LOGS=arc
ORACLE_ARCH_LOC=/logs/oracle/JDEPDCONT1/archivelogs
ORACLE_ARCH_REMOTE_LOC=/logs/oracle/JDEPDCONT1_STBY/archivelogs


##########################################################
################ BEGINNING OF MAIN #######################
##########################################################
echo
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo -- Step 1. Copy Archivelogs TO STADNBY --
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo
cd $ORACLE_ARCH_LOC
rsync -aPz *.$ORACLE_ARC_LOGS $ORACLE_OS_USR@$ORACLE_STANDBY:$ORACLE_ARCH_REMOTE_LOC
exit 0

