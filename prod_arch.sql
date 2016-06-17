set pagesize 0
prompt CURRENT PROD LOG
prompt ================
prompt
SELECT max(sequence#) as CURRENT_LOG_NUMBER
FROM   v$archived_log
ORDER BY sequence#;
