set pagesize 0
prompt CURRENT LOGS APPLIED ON STANDBY
prompt ================================
prompt
select 'Last Log applied : ' Logs,SEQUENCE#, to_char(next_time,'DD-MON-YY:HH24:MI:SS') Time
from v$archived_log
where sequence# = (select max(sequence#) from v$archived_log where applied='YES')
union
select 'Last Log received : ' Logs,SEQUENCE#, to_char(next_time,'DD-MON-YY:HH24:MI:SS') Time
from v$archived_log
where sequence# = (select max(sequence#) from v$archived_log);
exit
