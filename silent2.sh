ORACLE_STANDBY=jdestandbydb
ssh oracle@$ORACLE_STANDBY /db/app/oracle/scripts/maint_scripts/PoormDG2_silent.sh
