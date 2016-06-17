#!/bin/bash
# SCRIPT: mail_check_2.sh
# REV: Version 1.0
# PLATFORM: Solaris
# AUTHOR: Coenraad
# Oracle Maint Scripts
# PURPOSE: Mail Helper,
#          every 30 min.
#
#
#
##########################################################
########### DEFINE FILES AND VARIABLES HERE ##############
##########################################################

ORACLE_SID=JDEPDCONT1
ORACLE_BASE=/db/app/oracle
ORACLE_HOME=/db/app/oracle/product/12.1.0/db_1
SCRIPTDIR=/db/app/oracle/scripts/maint_scripts/

NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'
NOW=`date +"%d%M%Y_%H%M"`

export ORACLE_SID ORACLE_BASE ORACLE_HOME NLS_DATE_FORMAT NOW SCRIPTDIR

cd ${SCRIPTDIR}

exec 1>${SCRIPTDIR}/mail/PoormanDG_help_${ORACLE_SID}_${NOW}.log
exec 2>&1

${SCRIPTDIR}/PoormDG1_CHECK.sh

/usr/bin/mailx -s "`hostname` - ${ORACLE_SID} - JFPM Poorman's DG WARNING!!!" coenraad.j.lamprecht@gmail.com,bdollery@resolvesp.com,rsnyman@resolvesp.com << EOF

${ORACLE_SID} JFPM Check...
                                                                                                   
WARNING
=======
Its seems like the Oracle Replication at JFPM has a problem!
If the logs applied on STANDBY are behind more then 20 it is Critical!!!!
If >= then 5 , then it becomes a issue.                                                                                                   
`date`

`${SCRIPTDIR}/PoormDG1_CHECK.sh`
EOF

rm -f ${SCRIPTDIR}/mail/PoormanDG_help_${ORACLE_SID}_${NOW}.log

