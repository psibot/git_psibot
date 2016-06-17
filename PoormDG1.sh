#!/bin/bash

# SCRIPT: PoormDG1_Setup.sh
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
ORACLE_PRIMARY=$hostname
ORACLE_STANDBY=jdestandbydb
ORACLE_STBY_CTL_FILE=stbycf.ctl
ORACLE_OS_USR=oracle
ORACLE_SID=JDEPDCONT1
ORACLE_RMAN_LOC=/logs/oracle/JDEPDCONT1/rman
ORACLE_RMAN_REMOTE_LOC=/logs/oracle/JDEPDCONT1/rman


##########################################################
################ BEGINNING OF MAIN #######################
##########################################################
clear 
echo
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo -- Step 1. Create Standby Controlfile and Pfile FROM PROD --
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo 
date 
echo 
export ORACLE_SID=$ORACLE_SID
echo
   sqlplus -s  '/as sysdba' <<EOF
prompt Creating Standby Controlfile on PROD
ALTER DATABASE CREATE STANDBY CONTROLFILE AS '/logs/oracle/JDEPDCONT1/rman/stbycf.ctl';
exit
EOF
echo 
echo Step 1 Complete ! Files Created !
echo --------------------------------
echo 
echo "Hit CTL+C (to cancel)  if the files was not created on os (ls command)"

ls -al $ORACLE_RMAN_LOC/$ORACLE_STBY_CTL_FILE


read -p "Press [Enter] key to start next step..."
clear 
echo
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo -- Step 2. Copy Standby Controlfile TO STADNBY --
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo 
echo Start Remote Copy!
echo ------------------
cd $ORACLE_RMAN_LOC/
echo 
echo Location Set!
echo -------------
rsync -e ssh -Pazv $ORACLE_STBY_CTL_FILE $ORACLE_OS_USR@$ORACLE_STANDBY:$ORACLE_RMAN_REMOTE_LOC
echo "Hit CTL+C (to cancel)  if the files was not copied to romote location"
read -p "Press [Enter] key to start next step..."
clear 
echo
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo -- Step 3. Remote Startup of STANDBY  --
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo 
echo - THIS MUST BE DONE MANUALLY! -
echo - On STANDBY server login to oracle and startup pfile - 
echo - Run the following commands console on STANDBY server -
echo 
echo - export ORACLE_SID=$ORACLE_SID
echo -  sqlplus "/as sysdba"
echo - "SQL> startup nomount"
echo - "SQL> exit;"
echo - "rman target /"
echo - "RMAN>  RESTORE STANDBY CONTROLFILE FROM '/logs/oracle/JDEPDCONT1/rman/stbycf.ctl';"
echo - "RMAN>  exit;"
echo - sqlplus "/as sysdba"
echo - ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=MANUAL;
echo - ALTER DATABASE ADD LOGFILE ('/db/app/oracle/oradata/JDEPDCONT1/onlinelog/online_redo01.log') SIZE 50M;
echo - ALTER DATABASE ADD LOGFILE ('/db/app/oracle/oradata/JDEPDCONT1/onlinelog/online_redo02.log') SIZE 50M;
echo - ALTER DATABASE ADD LOGFILE ('/db/app/oracle/oradata/JDEPDCONT1/onlinelog/online_redo03.log') SIZE 50M;
echo - ALTER SYSTEM SET STANDBY_FILE_MANAGEMENT=AUTO;
echo - ALTER DATABASE ADD STANDBY LOGFILE '/db/app/oracle/oradata/JDEPDCONT1/onlinelog/redo0101.log' SIZE 50M;
echo - ALTER DATABASE ADD STANDBY LOGFILE '/db/app/oracle/fast_recovery_area/JDEPDCONT1/onlinelog/redo0102.log' SIZE 50M;
echo - ALTER DATABASE ADD STANDBY LOGFILE '/db/app/oracle/oradata/JDEPDCONT1/onlinelog/redo0202.log' SIZE 50M;
echo - ALTER DATABASE ADD STANDBY LOGFILE '/db/app/oracle/fast_recovery_area/JDEPDCONT1/onlinelog/redo0202.log' SIZE 50M;
echo - ALTER DATABASE ADD STANDBY LOGFILE '/db/app/oracle/oradata/JDEPDCONT1/onlinelog/redo0301.log' SIZE 50M;
echo - ALTER DATABASE ADD STANDBY LOGFILE '/db/app/oracle/fast_recovery_area/JDEPDCONT1/onlinelog/redo0302.log' SIZE 50M;
echo - shudown abort;
echo - startup nomount;
echo - exit

echo 
echo "Hit CTL+C (to cancel) After this was executed remotely "
read -p "Press [Enter] key to start next step..."
clear 
clear 
echo
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo -- Step 4.RMAN COPY BACKUPSETS FROM PROD TO STANDBY --
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo
echo RMAN Backupset Sync from PROD to STANDBY
echo 
echo  
cd $ORACLE_RMAN_LOC
pwd
echo 
read -p "Press [Enter] key to start next step..."
echo
echo "The copy will start , this will take time so please be patient"
echo
rsync -aPvz * $ORACLE_OS_USR@$ORACLE_STANDBY:$ORACLE_RMAN_REMOTE_LOC
echo 
echo "Hit CTL+C (to cancel) After this was executed remotely "
read -p "Press [Enter] key to start next step..."
echo 
echo "End of first script, Login on STANDBY server and run the second script"
echo "PoormDG2_Setup.sh"
read -p "Press [Enter] key to start next step..."
clear
echo "REMEBER!!!!"
echo "End of first script, Login on STANDBY server and run the second script"
echo "PoormDG2_Setup.sh"
echo "    ______  ______________"
echo "   / __ ) \/ / ____/ / / /"
echo "  / __  |\  / __/ / / / / "
echo " / /_/ / / / /___/_/_/_/  "
echo "/_____/ /_/_____(_|_|_)   "
read -p "Press [Enter] key to exit..."
                        
#End of script

