set pagesize 0
SELECT max(sequence#) 
FROM   v$archived_log
ORDER BY sequence#
/
exit;
