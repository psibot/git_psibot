#!/bin/bash

# SCRIPT: PoormDG3_Setup.sh
# REV: Version 1.0 
# PLATFORM: Solaris 
# AUTHOR: Coenraad
# Oracle Poorman's Data Gaurd 
# PURPOSE: Oracle Move RMAN Backupsets from Primary To Standby Server , 
#          Enable  Replication
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
echo "ONLY RUN THIS IF YOU ARE SHURE THE SECOND SCRIPT COMPLETED!"
echo "ONLY RUN THIS IF YOU ARE SHURE THE SECOND SCRIPT COMPLETED!"
echo "ONLY RUN THIS IF YOU ARE SHURE THE SECOND SCRIPT COMPLETED!"
echo 
echo "NOTE: PoormDG2_Setup.sh on STANDBY server must complete before we start this step!!!"
echo 
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo -- Notice!  -- Notice! -- Notice! --
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo
echo "Hit CTL+C (to cancel) if you are not shure!"
read -p "Press [Enter] key to start next step..."

clear 
echo
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo -- Step 1. Recover STANDBY Database --
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo 
echo 
export ORACLE_SID=$ORACLE_SID
echo
   echo
  rman target / <<EOF
run{
recover database;
}
EOF
echo "Hit CTL+C (to cancel) if database did not mount!"
read -p "Press [Enter] key to start next step - IF DATABASE RECOVERED!!!.."
clear
echo
echo "    ______  ______________"
echo "   / __ ) \/ / ____/ / / /"
echo "  / __  |\  / __/ / / / / "
echo " / /_/ / / / /___/_/_/_/  "
echo "/_____/ /_/_____(_|_|_)   "
read -p "Press [Enter] key to exit..."
