#!/bin/bash
# SCRIPT:  linux_mail_health_final.sh 
# REV: Version 1.0
# PLATFORM: Linux
# AUTHOR: Deadpool
# Oracle Maint Scripts
# PURPOSE: Mail Health report,
#       
#
#
##########################################################
########### DEFINE FILES AND VARIABLES HERE ##############
##########################################################
MAIL_SERVER_PORT=sabsmail:25
MAIL_FROM=oracle@sabs.co.za



SCRIPTDIR=/home/oracle/scripts


NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'
NOW=`date +"%d%M%Y_%H%M"`

export ORACLE_SID ORACLE_BASE ORACLE_HOME NLS_DATE_FORMAT NOW SCRIPTDIR

cd ${SCRIPTDIR}

exec 1>${SCRIPTDIR}/mail/health_${ORACLE_SID}_${NOW}.log
exec 2>&1

${SCRIPTDIR}/health_run_daily.sh
mkdir ${SCRIPTDIR}/html_reports/
cp ${SCRIPTDIR}/*.html ${SCRIPTDIR}/html_reports/
zip -r sabs_daily_reports.zip ${SCRIPTDIR}/html_reports/
mailx -S smtp=$MAIL_SERVER_PORT  -r $MAIL_FROM -a sabs_daily_reports.zip -s "SABS Oracle Health and Replication Reports"  coenraad.j.lamprecht@gmail.com << EOF

Reports On Health of DB's are  zipped

Replication Looks as follow :

`${SCRIPTDIR}/data_gaurd_daily.sh`

Sync of Data Guard should not be out by more then 5 logs.

Enoy 
Deadpool!

EOF

rm -f ${SCRIPTDIR}/mail/health_${ORACLE_SID}_${NOW}.log
rm -f ${SCRIPTDIR}/*.html
rm -fr ${SCRIPTDIR}/html_reports/
rm -f ${SCRIPTDIR}/sabs_daily_reports.zip


