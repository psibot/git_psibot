#!/bin/bash
# SCRIPT: mail_check.sh
# REV: Version 1.0
# PLATFORM: Solaris
# AUTHOR: Coenraad
# Oracle Maint Scripts
# PURPOSE: Mail replication report,
#          Twice a day.
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

exec 1>${SCRIPTDIR}/mail/PoormanDG_${ORACLE_SID}_${NOW}.log
exec 2>&1

${SCRIPTDIR}/PoormDG1_CHECK.sh

/usr/bin/mailx -s "`hostname` - ${ORACLE_SID} - JFPM Poorman's DG Check" coenraad.j.lamprecht@gmail.com,bdollery@resolvesp.com,rsnyman@resolvesp.com,pjansenvanvuuren@resolvesp.com << EOF

${ORACLE_SID} JFPM Check...
                                                                                                   
Poorman's Data Gaurd Report
===========================
This is a report that get mailed twice a day.
Regarding the replication at JFPM
* Logs applied on STANDBY should not fall behind > 5 on PRODUCTION
                                                                                                   
`date`

`${SCRIPTDIR}/PoormDG1_CHECK.sh`
EOF

rm -f ${SCRIPTDIR}/mail/PoormanDG_${ORACLE_SID}_${NOW}.log
