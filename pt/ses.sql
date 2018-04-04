--ses.sql
@scripts/login
spool /tmp/tses.sql
SELECT 'DEF objCls="'||DECODE(status,'MOUNTED','""','(SELECT object_name||''#''||object_type FROM DBA_OBJECTS WHERE object_id=row_wait_obj#)||')||'"' FROM V$INSTANCE;
spool off;
@/tmp/tses
!rm /tmp/tses.sql
SET HEADING ON;
DEF sql_id='%'
DEF sid='%'
PROMPT >>>>>   wait 
COLUMN isid FORMAT A14;
COLUMN event FORMAT A50;
COLUMN params FORMAT A80 ;
COLUMN p2 FORMAT A20;
COLUMN obj FORMAT A40;
COLUMN clnt_spumo FORMAT A80;
SELECT sid||','||serial#||',@'||inst_id isid,wait_class||' # '||event||' # '||p1text||':'||p1||'#'||p2text||':'||p2 params,sql_id,ROUND((SYSDATE-SQL_EXEC_START)*24*60,2) mins,
 &objCls row_wait_block# obj, schemaname||'#'||program||'#'||username||'#'||machine||'#'||osuser clnt_spumo
FROM GV$SESSION WHERE status='ACTIVE' AND NVL(sql_id,'%') LIKE '&sql_id' AND sid LIKE '&sid' AND (schemaname!='SYS' OR wait_class!='Idle') /*AND event NOT LIKE 'SQL*Net message%'*/ ORDER BY sid;
PROMPT >>>>>   long ops:
COLUMN message FORMAT A100;
SELECT * FROM (SELECT message, SYSDATE+time_remaining/60/60/24 dt, ROUND(NVL(time_remaining,0)/60) mins,sql_id  FROM GV$SESSION_LONGOPS WHERE sofar!=totalwork ORDER BY 2 DESC) WHERE ROWNUM<=10;
PROMPT >>>>>   blockers:
SELECT * FROM GV$SESSION_BLOCKERS;
PROMPT >>>>>   locks:
SELECT * FROM GV$LOCK WHERE type='TX' AND block>0;
@login
