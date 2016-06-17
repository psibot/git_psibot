#!/bin/bash

# SCRIPT: PoormDG2_Setup.sh
# REV: Version 1.0 
# PLATFORM: Solaris 
# AUTHOR: Coenraad
# Oracle Poorman's Data Gaurd 
# PURPOSE: Oracle Move RMAN Backupsets from Primary To Stanby Server , 
#          Create and Start a new standby Oracle Instance, 
#            
# Note : RSA public key for SSH must be genareted on both servers beforehand
# 
##########################################################
########### DEFINE FILES AND VARIABLES HERE ##############
##########################################################

# Veriables ! ONLY CHANGE THESE!
ORACLE_OS_USR=oracle
ORACLE_SID=JDEPDCONT1

##########################################################
################ BEGINNING OF MAIN #######################
##########################################################
clear 
echo
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo -- Notice!  -- Notice! -- Notice! --
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo 
date
echo 
echo "ONLY RUN THIS IF YOU ARE SHURE THE FIRST SCRIPT COMPLETED!"
echo "ONLY RUN THIS IF YOU ARE SHURE THE FIRST SCRIPT COMPLETED!"
echo "ONLY RUN THIS IF YOU ARE SHURE THE FIRST SCRIPT COMPLETED!"
echo 
echo "NOTE: PoormDG1_Setup.sh on PROD server must complete before we start this step!!!"
echo 
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo -- Notice!  -- Notice! -- Notice! --
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo
echo "Hit CTL+C (to cancel) if you are not shure!"
read -p "Press [Enter] key to start next step..."

clear 
echo
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo -- Step 1. Mount and Crossheck STANDBY Database --
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo 
echo 
export ORACLE_SID=$ORACLE_SID
echo
   sqlplus -s '/as sysdba' <<EOF
set echo on
prompt Alter STANDBY DB to MOUNT!
alter database mount standby database;
exit
EOF
echo "Hit CTL+C (to cancel) if database did not mount!"
read -p "Press [Enter] key to start next step - IF DATABASE ALTERED!!!.."
clear
echo 
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo -- Notice!  -- Notice! -- Notice! --
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo 
echo RMAN CROSSCHECK OF BACKUPSET!
echo ------------------------------
echo 
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo -- Notice!  -- Notice! -- Notice! --
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo
echo "Only run restore if crosscheck is done,"
echo "and all backupsets are AVAILABLE!"
echo 
echo "Hit CTL+C (to cancel) to cancel! "
read -p "Press [Enter] key to start next step..."
   rman target / <<EOF
run{
crosscheck backupset;
}
EOF
echo "Hit CTL+C (to cancel) if backupsets are missing!"
read -p "Press [Enter] key to start next step..."

clear 
echo
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo -- Step 2. Restore  STANDBY Database --
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo 
echo RMAN Restore STARTS at:
date
echo
 rman target / <<EOF
run{
restore database;
}
EOF
echo 
echo RMAN Restore STOPS at:
date
echo
echo "Hit CTL+C (to cancel) if RMAN failed!"
read -p "Press [Enter] key to start next step..."
clear
echo "REMEBER!!!!"
echo "End of second script, Login on STANDBY server and run the third script"
echo "PoormDG3_Setup.sh"
echo "    ______  ______________"
echo "   / __ ) \/ / ____/ / / /"
echo "  / __  |\  / __/ / / / / "
echo " / /_/ / / / /___/_/_/_/  "
echo "/_____/ /_/_____(_|_|_)   "
read -p "Press [Enter] key to exit..."
