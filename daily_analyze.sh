#!/bin/bash
#Lafarge Analyze 
#Declare array with  elements
. /home/oracle/.bash_profile

ARRAY=(ORACLE_SID)
# get number of elements in the array
ELEMENTS=${#ARRAY[@]}

# echo each element in array 

# for loop
for (( i=0;i<$ELEMENTS;i++)); do
    clear
    echo START AT:
    $date
    echo Starting ANALYZE
    echo ${ARRAY[${i}]}
    echo $(date)
    export ORACLE_SID=${ARRAY[${i}]}
    sqlplus '/as sysdba' <<EOF
set heading off
set pagesize 0
set linesize 300 
spool analyze.sql
select 'exec DBMS_STATS.GATHER_SCHEMA_STATS(OWNNAME=>'''||username||''',CASCADE =>TRUE,OPTIONS=>''GATHER'');' from dba_users
where username not in  ('SYS','SYSTEM','SYSAUX')
and account_status = 'OPEN';
spool off
set echo on
@analyze.sql
exit 
EOF
done
