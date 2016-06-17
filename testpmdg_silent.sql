set pagesize 0
select SEQUENCE#
from v$archived_log
where sequence# = (select max(sequence#) from v$archived_log where applied='YES')
union
select SEQUENCE#
from v$archived_log
where sequence# = (select max(sequence#) from v$archived_log);
exit
