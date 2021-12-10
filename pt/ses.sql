--ses.sql
@scripts/login
--DEF ct=ke
--DEF fcCls1=" LEFT JOIN dtbp&ct..smtt_sms_log l ON s.sid=l.sid AND s.serial#=l.sno LEFT JOIN dtbp&ct..smtb_current_users u USING (sequence_no)"
--DEF fcCls2="u.home_branch||u.user_id"
DEF fcCls1=""
DEF fcCls2="'fc'"
spool /tmp/tses.sql
 SELECT 'DEF objCls="'||DECODE(status,'MOUNTED','','(SELECT object_name||''#''||object_type FROM DBA_OBJECTS WHERE object_id=row_wait_obj# AND object_name NOT LIKE ''QRTZ_%'')')||'"' FROM V$INSTANCE;
spool off;
@/tmp/tses
!rm /tmp/tses.sql
SET HEADING ON;
DEF sql_id='%'
DEF sid='%'
PROMPT >>>>>   wait 
COLUMN wt FORMAT A200;
DEF s="||'%'||"
PROMPT wt="obj_params_sid_ser_mc_spid_sql_id_executions_mins_prg_usrdb_sch_sch_usros_action_fc"
SELECT REGEXP_REPLACE(REPLACE(event&s.obj&s.params&s.sid||','||serial#||'@'||mc||'.'||spid&s.sql_id&s.executions&s.mins&s.prg&s.REPLACE(usrdb||'>'||sch,sch||'>')&s.usros&s.action&s.LISTAGG(fc, '_')  WITHIN GROUP (ORDER BY fc), -
 ' ','_'),'(%){1,}', ' ') wt FROM( SELECT s.sid,s.serial#,p.spid,s.event,s.p1text||':'||s.p1&s.s.p2text||':'||s.p2 params,sql_id,sa.executions,ROUND((SYSDATE-s.sql_exec_start)*24*60,2)||'min' mins,
 &objCls obj, s.schemaname sch,SUBSTR(LOWER(s.program),1,5) prg,s.username usrdb,s.machine mc,s.osuser usros,s.action, &fcCls2 fc
 --&objCls obj, s.schemaname sch,SUBSTR(LOWER(s.program),1,5) prg,s.username usrdb,TRIM(SUBSTR(s.machine,1,INSTR(s.machine,'.'))) mc,s.osuser usros,s.action, &fcCls2 fc
FROM V$SESSION s JOIN V$PROCESS p ON s.paddr=p.addr LEFT JOIN V$SQLAREA sa USING (sql_id) &fcCls1
WHERE s.status='ACTIVE' AND NVL(sql_id,'%') LIKE '&sql_id' AND s.sid LIKE '&sid' AND s.wait_class!='Idle' AND event NOT LIKE 'SQL*Net message%' /*AND (service_name!='SYS$BACKGROUND' OR s.program LIKE '%LGWR%')*/) 
GROUP BY sch,event,obj,mc,params,sid,serial#,spid,sql_id,executions,mins,prg,sid,serial#,spid,usrdb,usros,action ORDER BY NVL(REPLACE(mins,'min'),0) DESC;
PROMPT >>>>>   long ops:
COLUMN message FORMAT A100;
SELECT * FROM (SELECT message, SYSDATE+time_remaining/60/60/24 dt, ROUND(NVL(time_remaining,0)/60) mins,sql_id  FROM V$SESSION_LONGOPS WHERE sofar!=totalwork ORDER BY 2 DESC) WHERE ROWNUM<=10;
PROMPT >>>>>   blockers:
SELECT * FROM V$SESSION_BLOCKERS;
PROMPT >>>>>   locks:
--t SELECT * FROM V$LOCK WHERE type='TX' AND block>0;
PROMPT >>>>>  active work areas:
SELECT sid,sql_id,sql_exec_start,ROUND(work_area_size/1024/1024,2) wa_mb, ROUND(tempseg_size/1024/1024/1024,2) tmp_gb FROM V$SQL_WORKAREA_ACTIVE;
@login
--spool off;
--!vi --cmd "set nowrap" /tmp/tses.lst



--tmp
/*
COLUMN ispid FORMAT A20;
COLUMN event FORMAT A50;
COLUMN mins FORMAT 99.99;
COLUMN params FORMAT A60 ;
COLUMN p2 FORMAT A20;
COLUMN obj FORMAT A40;
SELECT ispid&sp.params&sp.sql_id&sp.mins&sp.obj&sp.clnt_spumo&sp.LISTAGG(fc, '_')  WITHIN GROUP (ORDER BY fc) clnt_spumo FROM(
SELECT s.sid||','||s.serial#||','||p.spid ispid,s.event&sp.s.p1text||':'||s.p1&sp.s.p2text||':'||s.p2 params,s.sql_id,ROUND((SYSDATE-s.sql_exec_start)*24*60,2) mins,
 &objCls obj, 'sch:'||s.schemaname&sp.REPLACE(s.program,' ')&sp.s.username&sp.s.machine&sp.s.osuser&sp.s.action clnt_spumo, &fcCls2 fc
FROM V$SESSION s JOIN V$PROCESS p ON s.paddr=p.addr &fcCls1
WHERE s.status='ACTIVE' AND NVL(s.sql_id,'%') LIKE '&sql_id' AND s.sid LIKE '&sid' AND s.wait_class!='Idle' AND event NOT LIKE 'SQL*Net message%') GROUP BY ispid,params,sql_id,mins,obj,clnt_spumo ORDER BY ispid;



*/
