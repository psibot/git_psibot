--Single database checks
--<head>
--<meta http-equiv="Content-Type" content="text/html; charset=WINDOWS-1252">
--<meta name="generator" content="SQL*Plus 12.1.0">
--<style type='text/css'> 
--	body {font:6pt Century Gothic, Trebuchet MS, verdana,arial,sans-serif; color:black; background:White;} 
--	p {font:6pt Century Gothic, Trebuchet MS, verdana,arial,sans-serif; color:black; background:White;} 
--	table,tr,td {font:6pt Century Gothic, Trebuchet MS, verdana,arial,sans-serif; color:Black; background:##F5FAFF; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px;} 
--	th {font:bold 6pt Century Gothic, Trebuchet MS, verdana,arial,sans-serif; color:#336699; background:#C8E3FF; padding:0px 0px 0px 0px;}
--	h1 {font:8pt Century Gothic, Trebuchet MS, verdana,arial,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;-
--} h2 {font:bold 6pt Century Gothic, Trebuchet MS, verdana,arial,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;} 
--	a {font:6pt Century Gothic, Trebuchet MS, verdana,arial,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}
--</style><title>SQL*Plus Report</title>
--</head>
set echo off
set feedback off
set pagesize 0

SET MARKUP HTML ON SPOOL ON PREFORMAT OFF ENTMAP OFF

prompt <html>

prompt <head>

prompt </head>

column timecol new_value timestamp 
column spool_ext new_value suffix 
select to_char(sysdate,'Mondd_hhmi') timecol, 
'.html' spool_ext from sys.dual; 
column output new_value dbname 
select value || '_' output 
from v$parameter where name = 'db_name'; 
spool Daily_Health_&&dbname&&suffix

prompt <BR>
prompt <H2><U> DB Information In Detail </H2></U>
prompt
 
select 'Name:'||name from v$database;
select   'Uptime:'||STARTUP_TIME,
         trunc(SYSDATE-(STARTUP_TIME) ) || ' day(s), ' ||
         trunc(24*((SYSDATE-STARTUP_TIME) - trunc(SYSDATE-STARTUP_TIME)))||' hour(s), ' ||
         mod(trunc(1440*((SYSDATE-STARTUP_TIME) - trunc(SYSDATE-STARTUP_TIME))), 60) ||' minute(s), ' ||
         mod(trunc(86400*((SYSDATE-STARTUP_TIME) - trunc(SYSDATE-STARTUP_TIME))), 60) ||' seconds'
from     sys.v_$instance;

prompt
prompt <BR>
prompt <H2><U> DB Cache </H2></U>
prompt
col pct_hit format 999.99
select   round((sum(decode(name, 'consistent gets',value, 0)) + 
            sum(decode(name, 'db block gets',value, 0)) - 
            sum(decode(name, 'physical reads',value, 0))) / 
         (sum(decode(name, 'consistent gets',value, 0)) + 
         sum(decode(name, 'db block gets',value, 0))) * 100,2) pct_hit
from     sys.v_$sysstat
having round((sum(decode(name, 'consistent gets',value, 0)) + 
            sum(decode(name, 'db block gets',value, 0)) - 
            sum(decode(name, 'physical reads',value, 0))) / 
         (sum(decode(name, 'consistent gets',value, 0)) + 
         sum(decode(name, 'db block gets',value, 0))) * 100,2)<90;

set pagesize 24
 
prompt <BR>
prompt <H2><U> Chained Rows </H2></U>
prompt
col owner format a15
col table_name format a25
select * from
(select   OWNER,
         TABLE_NAME,
         nvl(CHAIN_CNT,0) rows_chained,
         nvl(NUM_ROWS,0) num_rows,
         round((CHAIN_CNT/NUM_ROWS)*100,2) pct_chained
from     dba_tables
where    owner not in ('SYS','SYSTEM','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','PH','SCOTT','OE')
and      nvl(CHAIN_CNT,0) > 0
order by (CHAIN_CNT/NUM_ROWS) desc)
where rownum < 10;


prompt <BR>
prompt <H2><U> Segment Adviser </H2></U>
prompt
SET HEADING OFF
col owner format a15
col table_name format a25

select tablespace_name, segment_name, segment_type, partition_name,
recommendations, c1 from
table(dbms_space.asa_recommendations('FALSE', 'FALSE', 'FALSE'));
SET HEADING ON

prompt
prompt
prompt <H2><U> Unused Indexes </U></H2>
prompt
prompt This is related to broken or unusable indexes.
prompt 
prompt * Indexes in broken state.

column owner format a8

select 	index_name,
	substr(owner,1,8) owner,
	table_name,
	status
from 	dba_indexes
where 	status = 'UNUSABLE'
/

prompt <BR>
prompt <H2><U> Blocking Sessions </H2></U>
prompt
col owner format a15
col table_name format a25

select * from DBA_WAITERS;

prompt <BR>
prompt <H2><U>Oracle Database Alerts</H2></U>
prompt
col owner format a15
col table_name format a25
SET HEADING OFF
prompt 
prompt <H2><U>ALert history</H2></U>
prompt 
select z.REASON, Z.CREATION_TIME from DBA_ALERT_HISTORY z
WHERE Z.CREATION_TIME > SYSDATE -1 
order by Z.CREATION_TIME desc;


Prompt <H2><U>Alerts outstanding</H2></U> 
prompt 
select A.REASON,a.CREATION_TIME  from DBA_OUTSTANDING_ALERTS a;
prompt <BR>
prompt <H2><U>Invalid Objects </H2></U>
col owner format a15
col object_type format a15       
col object_name format a25       
col status format a10       
select   OWNER,
OBJECT_TYPE,
OBJECT_NAME,
STATUS
from     dba_objects
where    STATUS = 'INVALID'
and owner not in ('SYS','SYSTEM','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','PH','SCOTT','OE')
order by OWNER, OBJECT_TYPE, OBJECT_NAME;


prompt <BR>
prompt <H2><U> DB Analyze Detail </H2></U>
set head off feedback off serverout on

declare

tdate		varchar2(20);

tdate2		varchar2(20);

idate		varchar2(20);

idate2		varchar2(20);

dname		varchar2(20);



begin



  dbms_output.enable(20000);



    select	max(to_char(last_analyzed,'DD-MON-YY')) into tdate

    from	dba_tables

   ---- where	owner not in ('AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','DBSNMP','MTSSYS','OSE$HTTP$ADMIN','OUTLN','SYS','SYSTEM','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','CTXSYS','HR','MDSYS','OE','OEM','OLAPSYS','ORDPLUGINS','ORDSYS','PM','RMAN','SCOTT','SH','WKPROXY','WKSYS','WMSYS','XDB','ADAMS','BLAKE','CLARK','IBX','MDSYS','ODM','ODM_MTR','QS_ADM','QS_CB');
     where	owner  in ('PRODDTA','PRODCTL');


    select	min(to_char(last_analyzed,'DD-MON-YY')) into tdate2

    from	dba_tables

    ----where	owner not in ('AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','DBSNMP','MTSSYS','OSE$HTTP$ADMIN','OUTLN','SYS','SYSTEM','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','CTXSYS','HR','MDSYS','OE','OEM','OLAPSYS','ORDPLUGINS','ORDSYS','PM','RMAN','SCOTT','SH','WKPROXY','WKSYS','WMSYS','XDB','ADAMS','BLAKE','CLARK','IBX','MDSYS','ODM','ODM_MTR','QS_ADM','QS_CB');
    where	owner  in ('PRODDTA','PRODCTL');


    select	max(to_char(last_analyzed,'DD-MON-YY')) into idate

    from	dba_indexes

    ----where	owner not in ('AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','DBSNMP','MTSSYS','OSE$HTTP$ADMIN','OUTLN','SYS','SYSTEM','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','CTXSYS','HR','MDSYS','OE','OEM','OLAPSYS','ORDPLUGINS','ORDSYS','PM','RMAN','SCOTT','SH','WKPROXY','WKSYS','WMSYS','XDB','ADAMS','BLAKE','CLARK','IBX','MDSYS','ODM','ODM_MTR','QS_ADM','QS_CB');
    where	owner  in ('PRODDTA','PRODCTL');



    select	min(to_char(last_analyzed,'DD-MON-YY')) into idate2

    from	dba_indexes

    ----where	owner not in ('AURORA$JIS$UTILITY$','AURORA$ORB$UNAUTHENTICATED','DBSNMP','MTSSYS','OSE$HTTP$ADMIN','OUTLN','SYS','SYSTEM','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','CTXSYS','HR','MDSYS','OE','OEM','OLAPSYS','ORDPLUGINS','ORDSYS','PM','RMAN','SCOTT','SH','WKPROXY','WKSYS','WMSYS','XDB','ADAMS','BLAKE','CLARK','IBX','MDSYS','ODM','ODM_MTR','QS_ADM','QS_CB');
    where	owner  in ('PRODDTA','PRODCTL');


    select name into dname from v$database;





  dbms_output.put_line('                                             ');

  dbms_output.put_line(' Tables (analyzed objects) :     '||rpad(tdate,16)||'');

  dbms_output.put_line('                                             ');

  dbms_output.put_line(' Tables (analyzed objects) :     '||rpad(tdate2,16)||'');

  dbms_output.put_line('                                              ');

  dbms_output.put_line(' Indexes (analyzed objects):     '||rpad(idate,16)||'');

  dbms_output.put_line('                                             ');

  dbms_output.put_line(' Indexes (analyzed objects):     '||rpad(idate2,16)||'');

  dbms_output.put_line('                                              ');



end;

/


prompt 
prompt <H2><U>  RMAN Backups for Database </U></H2>
prompt
prompt The output will only be seen on PD systems!!!
prompt
set line 250 pagesize 300
select
SESSION_KEY, INPUT_TYPE, STATUS,
to_char(START_TIME,'mm/dd/yy hh24:mi') start_time,
to_char(END_TIME,'mm/dd/yy hh24:mi')   end_time,
round(elapsed_seconds/3600)                   hrs
from V$RMAN_BACKUP_JOB_DETAILS
order by session_key
/


prompt 
prompt <H2><U>  Oracle Datapump Info  </U></H2>
prompt
prompt
set line 250 pagesize 300
select A.OPNAME,A.TARGET_DESC,a.message,A.LAST_UPDATE_TIME from V$SESSION_LONGOPS a
where target_desc  = 'EXPORT'
/

prompt 
prompt <H2><U> Health Monitor </U></H2>
prompt
prompt
set line 250 pagesize 300
set heading on
SELECT run_id, name, check_name, run_mode, src_incident FROM v$hm_run;

prompt SCR_INCIDENT must be 0 , IF NOT
prompt The next example queries the V$HM_FINDING view to obtain finding details 
prompt SELECT type, description FROM v$hm_finding WHERE run_id = ???
prompt IF ANY!!!!!! 

prompt 
prompt <H2><U> Tunning Database SGA/PGA </U></H2>
prompt
prompt
prompt
set pagesize 0;
SELECT 'SGA MAX Size in MB:   '|| trunc(SUM(VALUE)/1024/1024, 2) "SGA_MAX_MB" FROM V$SGA;

set pagesize 50;
set line 200;
column "SGA Pool"format a33;
col "m_bytes" format 999999.99;
select pool "SGA Pool", m_bytes from ( select  pool, to_char( trunc(sum(bytes)/1024/1024,2), '99999.99' ) as M_bytes
    from v$sgastat
    where pool is not null   group  by pool
    union
    select name as pool, to_char( trunc(bytes/1024/1024,3), '99999.99' ) as M_bytes
    from v$sgastat
    where pool is null  order     by 2 desc
    ) UNION ALL
    select    'TOTAL' as pool, to_char( trunc(sum(bytes)/1024/1024,3), '99999.99' ) from v$sgastat;

Select round(tot.bytes  /1024/1024 ,2)  sga_total, round(used.bytes /1024/1024 ,2)  used_mb, round(free.bytes /1024/1024 ,2)  free_mb
from (select sum(bytes) bytes  from v$sgastat where  name != 'free memory') used,    
(select sum(bytes) bytes from  v$sgastat  where  name = 'free memory') free, 
(select sum(bytes) bytes from v$sgastat) tot;

select pool,  round(sgasize/1024/1024,2) "SGA_TARGET",  
round(bytes/1024/1024,2) "FREE_MB", 
round(bytes/sgasize*100, 2) "%FREE"
from  (select sum(bytes) sgasize from sys.v_$sgastat) s, sys.v_$sgastat f
where  f.name = 'free memory';
prompt
prompt 
prompt <H2><U> Tunning Shared Pool Size </U></H2>
prompt
prompt
prompt
col "Data Dict. Gets" heading Data_Dict.|Gets;
col "Data Dict. Cache Misses" heading Dict._Cache|Misses;
col "Data Dict Cache Hit Ratio" heading Dict._Cache|Hit_Ratio;
col "% Missed" heading Missed|%;
SELECT SUM(gets)   "Data Dict. Gets", SUM(getmisses)  "Data Dict. Cache Misses"
  , TRUNC((1-(sum(getmisses)/SUM(gets)))*100, 2) "Data Dict Cache Hit Ratio"
  , TRUNC(SUM(getmisses)*100/SUM(gets), 2)  "% Missed"
FROM  v$rowcache;

prompt
Prompt* The Dict. Cache Hit% shuold be > 90% and misses% should be < 15%. If not consider increase SHARED_POOL_SIZE.

col "Cache Misses" heading Cache|Misses;
col "Library Cache Hit Ratio" heading Lib._Cache|Hit_Ratio;
col "% Missed" heading Missed|%;
SELECT SUM(pins)     "Executions", SUM(reloads)  "Cache Misses"
  , TRUNC((1-(SUM(reloads)/SUM(pins)))*100, 2) "Library Cache Hit Ratio"
  , ROUND(SUM(reloads)*100/SUM(pins))       "% Missed"        
FROM  v$librarycache;
prompt
Prompt* The Lib. Cache Hit% shuold be > 90% and misses% should be < 1%. If not consider increase SHARED_POOL_SIZE.

set pagesize 25;
col "Tot SQL since startup" format a25;
col "SQL executing now" format a17;
SELECT  TO_CHAR(SUM(executions)) "Tot SQL since startup", TO_CHAR(SUM(users_executing)) "SQL executing now"
FROM  v$sqlarea;

prompt
set pagesize 0;
select 'Cursor_Space_for_Time:  '|| value "Cursor_Space_for_Time"
from v$parameter  where name = 'cursor_space_for_time';

set pagesize 25;
col "Namespace" heading name|space;
col "Hit Ratio" heading Hit|Ratio;
col "Pin Hit Ratio" heading Pin_Hit|Ratio;
col "Invalidations" heading invali|dations;

SELECT  namespace  "Namespace", TRUNC(gethitratio*100) "Hit Ratio", 
TRUNC(pinhitratio*100) "Pin Hit Ratio", reloads "Reloads", invalidations  "Invalidations"
FROM  v$librarycache;

prompt            
prompt* GETHITRATIO and PINHITRATIO should be more than 90%.
prompt* If RELOADS > 0 then'cursor_space_for_time' Parameter do not set to 'TRUE'
prompt* More of Invalid object in namespace will cause more reloads.

set line 200;
col "NAME" format a30;
col "VALUE" format a12;
select p.name "NAME", a.free_space, p.value "VALUE", trunc(a.free_space/p.value, 2) "FREE%", requests, request_misses req_misses
from v$parameter p, v$shared_pool_reserved a
where p.name = 'shared_pool_reserved_size';

prompt
Prompt* %FREE should be > 0.5, request_failures,request_misses=0 or near 0. If not consider increase SHARED_POOL_RESERVED_SIZE and SHARED_POOL_SIZE.
prompt 
prompt <H2><U> Tunning Buffer Cache </U></H2>
prompt
prompt
prompt
SELECT  TRUNC( ( 1 - ( SUM(decode(name,'physical reads',value,0)) / ( SUM(DECODE(name,'db block gets',value,0))  
+ (SUM(DECODE(name,'consistent gets',value,0))) )) ) * 100  ) "Buffer Hit Ratio"
FROM v$sysstat;
prompt
prompt* The Buffer Cache Hit% should be >90%. If not and the shared pool hit ratio is good consider increase DB_CACHE_SIZE.

set line 200;
col event format a20;
select event, total_waits, time_waited
  from  v$system_event
    where event in ('buffer busy waits');
select s.segment_name, s.segment_type, s.freelists, w.wait_time, w.seconds_in_wait, w.state
    from dba_segments s, v$session_wait w
    where  w.event = 'buffer busy waits'
    AND w.p1 = s.header_file  AND  w.p2 = s.header_block;

prompt
prompt* Check for waits to find a free buffer in the buffer cache and Check if the I/O system is slow.
prompt* Consider increase the size of the buffer cache if it is too small. Consider increase the number of DBWR process if the buffer cache is properly sized.

prompt 
prompt <H2><U> Tunning Redolog Buffer </U></H2>
prompt
prompt
prompt
col "redolog space request" heading redolog_space|request;
col "redolog space wait time" heading redolog_space|wait_time;
col "Redolog space ratio"  heading redolog_space|ratio;
Select e. value "redolog space request", s.value "redolog space wait time", Round(e.value/s.value,2) "Redolog space ratio" 
From v$sysstat s, v$sysstat e
Where s.name = 'redo log space requests'
and e.name = 'redo entries';

prompt
prompt * If the ratio of redolog space is less than 5000 then increase the size of redolog buffer until this ratio stop falling.
prompt * There should be no log buffer space waits. Consider making logfile bigger or move the logfile to faster disk.

col "redo_buff_alloc_retries" heading redo_buffer|alloc_retries;
col "redo_entries" heading redo|entries;
col "pct_buff_alloc_retries" heading pct_buffer|alloc_retries;
 select    v1.value as "redo_buff_alloc_retries", v2.value as "redo_entries",
        trunc(v1.value/v2.value,4) as "pct_buff_alloc_retries"
    from     v$sysstat v1, v$sysstat v2
    where    v1.name = 'redo buffer allocation retries'
    and    v2.name = 'redo entries';

column latch_name format a20
select name latch_name, gets, misses, immediate_gets "Immed Gets", immediate_misses "Immed Misses", trunc((misses/decode(gets,0,1,gets))*100,2) Ratio1,
       trunc(immediate_misses/decode(immediate_misses+  immediate_gets,0,1, immediate_misses+immediate_gets)*100,2) Ratio2
from v$latch
where name like 'redo%';
prompt
prompt All ratios should be <= 1% if not then decrease the value of log_small_entry_max_size in init.ora

col event format a30;
select * from v$system_event
where event like 'log%';
prompt
Prompt* If Avg_wait_time is minor ignore it otherwise check the log buffer size w.r.t transaction rate and memory size.

prompt 
prompt <H2><U> Tunning PGA Aggregate Target </U></H2>
prompt
prompt
set pagesize 600;
set line 200;
column PGA_Component format a40;
column value format 999999999999;
select name "PGA_Component", value from v$pgastat;

Select count(*) "Total No. of Process" from v$process;

set line 200;
column "PGA Target" format a40;
column VALUE_MB format 9999999999.99
SELECT NAME "PGA Target", VALUE/1024/1024 VALUE_MB
FROM   V$PGASTAT
WHERE NAME IN ('aggregate PGA target parameter',
'total PGA allocated',
'total PGA inuse')
union
SELECT NAME, VALUE
FROM   V$PGASTAT
WHERE NAME IN ('over allocation count');

set line 200;
column "PGA_Work_Pass" format a40;
column "PER" format 999;
select  name "PGA_Work_Pass", cnt, decode(total, 0, 0, round(cnt*100/total)) per
from (select name, value cnt, (sum(value) over()) total
from v$sysstat where name like 'workarea exec%'
);

prompt
Prompt* DBA Must increase PGA_AGG_TARGET when "Multipass" > 0 and Reduce when "Optimal" executions 100%.

prompt 
prompt <H2><U> Tunning SORT Area Size </U></H2>
prompt
prompt
col name format a20;
select name,  value from v$sysstat
where name like 'sorts%';

prompt 
prompt <H2><U> Tablespace/CRD File Information  </U></H2>
prompt
prompt
col "Database Size" format a15;
col "Free space" format a15;
select round(sum(used.bytes) / 1024 / 1024/1024 ) || ' GB' "Database Size",
round(free.p / 1024 / 1024/1024) || ' GB' "Free space"
from (select bytes from v$datafile
union all select bytes from v$tempfile
union all select bytes from v$log) used,
(select sum(bytes) as p from dba_free_space) free
group by free.p;


SELECT  a.tablespace_name tablespace_name,
       ROUND(a.bytes_alloc / 1024 / 1024, 2) megs_alloc,
--       ROUND(NVL(b.bytes_free, 0) / 1024 / 1024, 2) megs_free,
       ROUND((a.bytes_alloc - NVL(b.bytes_free, 0)) / 1024 / 1024, 2) megs_used,
       ROUND((NVL(b.bytes_free, 0) / a.bytes_alloc) * 100,2) Pct_Free,
       (case when ROUND((NVL(b.bytes_free, 0) / a.bytes_alloc) * 100,2)<=0 
                                                then 'Immediate action required!'
             when ROUND((NVL(b.bytes_free, 0) / a.bytes_alloc) * 100,2)<5  
                                                then 'Critical (<5% free)'
             when ROUND((NVL(b.bytes_free, 0) / a.bytes_alloc) * 100,2)<15 
                                                then 'Warning (<15% free)'
             when ROUND((NVL(b.bytes_free, 0) / a.bytes_alloc) * 100,2)<25 
                                                then 'Warning (<25% free)'
             when ROUND((NVL(b.bytes_free, 0) / a.bytes_alloc) * 100,2)>60 
                                                then 'Waste of space? (>60% free)'
             else 'OK'
             end) msg
FROM  ( SELECT  f.tablespace_name,
               SUM(f.bytes) bytes_alloc,
               SUM(DECODE(f.autoextensible, 'YES',f.maxbytes,'NO', f.bytes)) maxbytes
        FROM DBA_DATA_FILES f
        GROUP BY tablespace_name) a,
      ( SELECT  f.tablespace_name,
               SUM(f.bytes)  bytes_free
        FROM DBA_FREE_SPACE f
        GROUP BY tablespace_name) b
WHERE a.tablespace_name = b.tablespace_name (+)
UNION
SELECT h.tablespace_name,
       ROUND(SUM(h.bytes_free + h.bytes_used) / 1048576, 2),
--       ROUND(SUM((h.bytes_free + h.bytes_used) - NVL(p.bytes_used, 0)) / 1048576, 2),
       ROUND(SUM(NVL(p.bytes_used, 0))/ 1048576, 2),
       ROUND((SUM((h.bytes_free + h.bytes_used) - NVL(p.bytes_used, 0)) / SUM(h.bytes_used + h.bytes_free)) * 100,2),
      (case when ROUND((SUM((h.bytes_free + h.bytes_used) - NVL(p.bytes_used, 0)) / SUM(h.bytes_used + h.bytes_free)) * 100,2)<=0 then 'Immediate action required!'
            when ROUND((SUM((h.bytes_free + h.bytes_used) - NVL(p.bytes_used, 0)) / SUM(h.bytes_used + h.bytes_free)) * 100,2)<5  then 'Critical (<5% free)'
            when ROUND((SUM((h.bytes_free + h.bytes_used) - NVL(p.bytes_used, 0)) / SUM(h.bytes_used + h.bytes_free)) * 100,2)<15 then 'Warning (<15% free)'
            when ROUND((SUM((h.bytes_free + h.bytes_used) - NVL(p.bytes_used, 0)) / SUM(h.bytes_used + h.bytes_free)) * 100,2)<25 then 'Warning (<25% free)'
            when ROUND((SUM((h.bytes_free + h.bytes_used) - NVL(p.bytes_used, 0)) / SUM(h.bytes_used + h.bytes_free)) * 100,2)>60 then 'Waste of space? (>60% free)'
            else 'OK'
            end) msg
FROM   sys.V_$TEMP_SPACE_HEADER h, sys.V_$TEMP_EXTENT_POOL p
WHERE  p.file_id(+) = h.file_id
AND    p.tablespace_name(+) = h.tablespace_name
GROUP BY h.tablespace_name
ORDER BY 1;


set linesize 200
col file_name format a50 heading "Datafile Name"
col allocated_mb format 999999.99;
col used_mob format 999999.99;
col free_mb format 999999.99;
col tablespace_name format a20;
SELECT SUBSTR (df.NAME, 1, 40) file_name, dfs. tablespace_name, df.bytes / 1024 / 1024 allocated_mb,
         ((df.bytes / 1024 / 1024) - NVL (SUM (dfs.bytes) / 1024 / 1024, 0))
               used_mb,  NVL (SUM (dfs.bytes) / 1024 / 1024, 0) free_mb, c.autoextensible
    FROM v$datafile df, dba_free_space dfs, DBA_DATA_FILES c
   WHERE df.file# = dfs.file_id(+) AND  df.file# = c.FILE_ID
GROUP BY dfs.file_id, df.NAME, df.file#, df.bytes, dfs.tablespace_name, c.autoextensible
ORDER BY file_name;

SELECT TO_CHAR(creation_time, 'RRRR Month') "Year/Month", 
round(SUM(bytes)/1024/1024/1024) "Datafile Growth Rate in GB" 
FROM sys.v_$datafile 
WHERE creation_time < sysdate
GROUP BY TO_CHAR(creation_time, 'RRRR Month');

TTI off

prompt 
prompt <H2><U> Report Tablespace < 10% free space </U></H2>
prompt
prompt
set pagesize 300;
set linesize 100;
column tablespace_name format a15 heading Tablespace;
column sumb format 999,999,999;
column extents format 9999;
column bytes format 999,999,999,999;
column largest format 999,999,999,999;
column Tot_Size format 999,999 Heading "Total Size(Mb)";
column Tot_Free format 999,999,999 heading "Total Free(Kb)";
column Pct_Free format 999.99 heading "% Free";
column Max_Free format 999,999,999 heading "Max Free(Kb)";
column Min_Add format 999,999,999 heading "Min space add (MB)";
select a.tablespace_name,sum(a.tots/1048576) Tot_Size,
sum(a.sumb/1024) Tot_Free, sum(a.sumb)*100/sum(a.tots) Pct_Free,
ceil((((sum(a.tots) * 15) - (sum(a.sumb)*100))/85 )/1048576) Min_Add
from (select tablespace_name,0 tots,sum(bytes) sumb
from sys.dba_free_space a
group by tablespace_name
union
select tablespace_name,sum(bytes) tots,0 from
sys.dba_data_files
group by tablespace_name) a
group by a.tablespace_name
having sum(a.sumb)*100/sum(a.tots) < 10
order by pct_free;

col owner format a15;
SELECT owner, count(*), tablespace_name
FROM dba_segments
WHERE tablespace_name = 'SYSTEM' AND owner NOT IN ('SYS','SYSTEM','CSMIG','OUTLN')
Group by owner, tablespace_name;

set pagesize 0;
prompt
SELECT   '+ '||count(*)||' NON-SYSTEM objects detected in SYSTEM tablespace with '||
                   'total size:  '||NVL(round(sum(bytes)/1024/1024,2),0)||'MB' "NON-SYSTEM objects"
FROM  dba_segments
WHERE  tablespace_name = 'SYSTEM' AND owner not in ('SYS','SYSTEM','CSMIG','OUTLN');

set pagesize 50;
col name  format A60 heading "Control Files";
select name from   sys.v_$controlfile;

prompt
set pagesize 0;
select (case
         when count(1) <2 then '+ At least 2 controlfiles are recommended'
         when count(1) >=2 and count(1) <=3 then '+ '||count(1)||' mirrors for controlfile detected. - OK' 
         else '+ More than 3 controlfiles might have additional overhead. Check the wait events.'
       end)
from v$controlfile;

set pagesize 0;
col msg format a79;
select 
(case when value <45 then '+ ! "control_file_record_keep_time='||value||'" to low. Set to at least 45'
else '+ "control_file_record_keep_time='||value||'"  - OK.'
end) msg
from v$parameter where name = 'control_file_record_keep_time';

set pagesize 50;
select segment_name, owner, tablespace_name, status from dba_rollback_segs;

prompt
set pagesize 0;
select 'The average of rollback segment waits/gets is '||  
   round((sum(waits) / sum(gets)) * 100,2)||'%'  
From    v$rollstat;

set pagesize 50;
SELECT TO_CHAR(SUM(value), '999,999,999,999,999') "Total Requests"
FROM  v$sysstat 
WHERE name IN ('db block gets','consistent gets');

set pagesize 50;
SELECT class  "Class", count  "Count"
FROM   v$waitstat 
WHERE  class IN (   'free list', 'system undo header', 'system undo block', 'undo header', 'undo block') 
GROUP BY   class, count;
prompt
prompt* If these are < 1% of Total Number of request for data then extra rollback segment are needed.

prompt 
prompt <H2><U> Checking the recycle Bin </U></H2>
prompt
prompt * Object in recycle bin can be purged.
prompt 
---
SELECT OWNER, SUM(SPACE) AS TOTAL_BLOCKS FROM DBA_RECYCLEBIN 
GROUP BY OWNER
ORDER BY OWNER;

prompt 
prompt <H2><U> Major wait events </U></H2>
prompt
prompt * We can check the wait events details with the help of below queries:
prompt
---
---SELECT s.saddr, s.SID, s.serial#, s.audsid, s.paddr, s.user#, s.username,
---s.command, s.ownerid, s.taddr, s.lockwait, s.status, s.server,
---s.schema#, s.schemaname, s.osuser, s.process, s.machine, s.terminal,
---UPPER (s.program) program, s.TYPE, s.sql_address, s.sql_hash_value,
---s.sql_id, s.sql_child_number, s.sql_exec_start, s.sql_exec_id,
---s.prev_sql_addr, s.prev_hash_value, s.prev_sql_id,
---s.prev_child_number, s.prev_exec_start, s.prev_exec_id,
---s.plsql_entry_object_id, s.plsql_entry_subprogram_id,
---s.plsql_object_id, s.plsql_subprogram_id, s.module, s.module_hash,
---s.action, s.action_hash, s.client_info, s.fixed_table_sequence,
---s.row_wait_obj#, s.row_wait_file#, s.row_wait_block#,
---s.row_wait_row#, s.logon_time, s.last_call_et, s.pdml_enabled,
---s.failover_type, s.failover_method, s.failed_over,
---s.resource_consumer_group, s.pdml_status, s.pddl_status, s.pq_status,
---s.current_queue_duration, s.client_identifier,
---s.blocking_session_status, s.blocking_instance, s.blocking_session,
---s.seq#, s.event#, s.event, s.p1text, s.p1, s.p1raw, s.p2text, s.p2,
---s.p2raw, s.p3text, s.p3, s.p3raw, s.wait_class_id, s.wait_class#,
---s.wait_class, s.wait_time, s.seconds_in_wait, s.state,
---s.wait_time_micro, s.time_remaining_micro,
---s.time_since_last_wait_micro, s.service_name, s.sql_trace,
---s.sql_trace_waits, s.sql_trace_binds, s.sql_trace_plan_stats,
---s.session_edition_id, s.creator_addr, s.creator_serial#
---FROM v$session s
---WHERE ( (s.username IS NOT NULL)
---AND (NVL (s.osuser, 'x') <> 'SYSTEM')
---AND (s.TYPE <> 'BACKGROUND') AND STATUS='ACTIVE')
--ORDER BY "PROGRAM";

SELECT s.saddr, s.SID, s.serial#, s.audsid, s.paddr, s.user#, s.username,
s.command, s.ownerid, s.taddr, s.lockwait, s.status, s.server,
s.schema#, s.schemaname, s.osuser, s.process, s.machine, s.terminal
FROM v$session s
WHERE ( (s.username IS NOT NULL)
AND (NVL (s.osuser, 'x') <> 'SYSTEM')
AND (s.TYPE <> 'BACKGROUND') AND STATUS='ACTIVE')
ORDER BY "PROGRAM";



prompt
prompt * The following query provides clues about whether Oracle has been waiting for library cache activities:
prompt
---
Select sid, event, p1raw, seconds_in_wait, wait_time
From v$session_wait
Where event = 'library cache pin'
And state = 'WAITING';
prompt
prompt * The below Query gives details of Users sessions wait time and state:
prompt
---
SELECT NVL (s.username, '(oracle)') AS username, s.SID, s.serial#, sw.event,
sw.wait_time, sw.seconds_in_wait, sw.state
FROM v$session_wait sw, v$session s
WHERE s.SID = sw.SID
ORDER BY sw.seconds_in_wait DESC;
prompt 
prompt <H2><U>  Long running Jobs </U></H2>
prompt
prompt * We can find out long running jobs with the help of the below query:
prompt
---
col username for a20 
col message for a50 
col remaining for 9999 
select username,to_char(start_time, 'hh24:mi:ss dd/mm/yy') started,
time_remaining remaining, message 
from v$session_longops 
where time_remaining = 0 
order by start_time desc;

prompt
prompt * Script to Identify  LONG RUNNING statements:
prompt
---
col opname format a20
col target format a15
col units format a10
col time_remaining format 99990 heading Remaining[s]
col bps format 9990.99 heading [Units/s]
col fertig format 90.99 heading "complete[%]"
select sid,opname,target,sofar,totalwork,units,(totalwork-sofar)/time_remaining bps,time_remaining,sofar/totalwork*100 fertig
from v$session_longops
where time_remaining > 0;
 
---
set feedback on
set pagesize 0
set echo off

spool off

exit


