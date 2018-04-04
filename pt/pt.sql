
----- freqly used



----- proactive health check
VAR v VARCHAR2(2000);
EXEC FOR s IN (SELECT DISTINCT schema||',' s FROM DBA_REGISTRY) LOOP :v:=:v||s.s; END LOOP;
EXEC FOR s IN (SELECT DISTINCT other_schemas||',' s FROM DBA_REGISTRY WHERE other_schemas IS NOT NULL)  LOOP :v:=:v||s.s; END LOOP;
EXEC :v:=:v||'ANONYMOUS,EXFSYS,PUBLIC,AURORA,MDSYS,REPADMIN,$JIS,ODM,SYS,$UTILITY,ODM_MTR,SYSMAN,$AURORA,OLAPSYS,SYSTEM,$ORB,ORDPLUGINS,TRACESVR,$UNAUTHENTICATED,ORDSYS,WKPROXY,-
 CTXSYS,OSE$HTTP$ADMIN,WKSYS,DBSNMP,OUTLN,WMSYS,DMSYS,PERFSTAT,XDB,DSSYS';
DEF whusrs=" INSTR(:v,owner)=0"

--1
PROMPT --V$ROWCACHE
SELECT * FROM (SELECT * FROM V$ROWCACHE ORDER BY modifications DESC NULL LAST) WHERE ROWNUM<=10;
--2
PROMPT --session_cached_cursors
SELECT 100*(SELECT value FROM V$SYSSTAT WHERE name='session cursor cache hits') / (SELECT value FROM V$SYSSTAT WHERE name='parse count (total)') cursor_cache_hit_pc FROM dual;
SELECT value, COUNT(*) FROM V$SESSTAT WHERE statistic# IN (SELECT statistic# FROM V$STATNAME WHERE name='session cursor cache count') GROUP BY value;
--3
PROMPT --hot segs
DEF st='logical reads'
DEF st='physical writes'
SELECT * FROM (SELECT inst_id,owner,object_name,subobject_name,object_type,tablespace_name,value  FROM GV$SEGMENT_STATISTICS WHERE statistic_name IN ('&st') AND &whusrs 
ORDER BY value DESC) WHERE ROWNUM<=30;
--3a
PROMPT -- ctring factor of hot segs
#add#
--4
PROMPT --advisor
SELECT command, COUNT(*) c FROM DBA_ADVISOR_ACTIONS GROUP BY command ORDER BY c DESC;
--5
PROMPT --sysmetric
SELECT inst_id,metric_name, ROUND(AVG(value),2) value FROM GV$SYSMETRIC_HISTORY GROUP BY inst_id,metric_name ORDER BY 2,1;
--6
PROMPT --os
SELECT * FROM GV$OSSTAT;
SELECT * FROM GV$ASM_DISK_IOSTAT;
--7
PROMPT --wait
SELECT * FROM GV$WAITSTAT;
SELECT * FROM (SELECT event_name, SUM(WAIT_TIME_MILLI) wm  FROM DBA_HIST_EVENT_HISTOGRAM WHERE wait_class!='Idle' GROUP BY event_name HAVING SUM(wait_time_milli)>1000 ORDER BY wm DESC NULLS LAST ) 
WHERE ROWNUM<=10;
--8
PROMPT --histogram
SELECT owner, SUM(DECODE(num_buckets,1,1,0)) no_hg, SUM(CASE WHEN num_distinct-num_buckets<=100 THEN 1 ELSE 0 END) mv2fh FROM DBA_TAB_COL_STATISTICS WHERE (num_buckets=1 OR num_distinct-num_buckets<=100) AND &whusrs GROUP BY owner;
--9
PROMPT --sys_time_model
SELECT * FROM (SELECT stat_name, ROUND(value/POWER(10,-6),2) secs FROM V$SYS_TIME_MODEL ORDER BY 2 DESC) WHERE ROWNUM<=10;
--10
PROMPT --parsing
PROMPT --similar sql
SELECT inst_id, plan_hash_value, COUNT(*) FROM GV$SQLSTATS GROUP BY inst_id, plan_hash_value HAVING COUNT(*)>1;
SELECT instance_id,sid,100*prs.value/execn.value pe FROM 
 (SELECT instance_id,sid, value FROM GV$SESSTAT s JOIN GV$STATNAME n GROUP BY (instance_id,sid,statistic#) WHERE name IN ('parse count (hard)')) prs JOIN
 (SELECT instance_id,sid, value FROM GV$SESSTAT s JOIN GV$STATNAME n GROUP BY (instance_id,sid,statistic#) WHERE name IN ('execute count')) execn USING (instance_id,sid) WHERE prs.value/execn.value<0.5;

--11,AWR
--DEF dy=2
VAR bit VARCHAR2(25);
VAR eit VARCHAR2(25);
EXEC :bit:='31-AUG-2016-02-50-00'; :eit:='31-AUG-2016-05-05-00'
DEF bitc="TO_DATE(:bit,'DD-MON-RRRR::HH24-MI-SS')"
DEF eitc="TO_DATE(:eit,'DD-MON-RRRR::HH24-MI-SS')"
DEF hs=HS
--DEF fdt=10-MAY-2016
--DEF mc=" IN ('kepsvvcfap2.dtbank.net','kepsvvcfap3.dtbank.net')"
spool /tmp/tawr.sql
 SELECT 'DEF ow=DTBP'||UPPER(SUBSTR(name,-2)) FROM V$DATABASE;
spool off;
@/tmp/tawr.sql
!rm /tmp/tawr.sql
--IC tuning
--tmp EXEC SELECT start_time, end_time INTO :bit, :eit FROM &ow..aetb_eoc_programs_history WHERE eoc_batch = 'ICEOD' AND eod_date = '&fdt' AND error_code IS NULL AND branch_code LIKE '001';

VAR tot NUMBER;
--11a
VAR bs NUMBER;
VAR es NUMBER;
VAR dbid NUMBER;
EXEC SELECT MIN(snap_id), MAX(snap_id) INTO :bs,:es FROM &hs._HIST_SNAPSHOT WHERE  begin_interval_time >= &bitc AND  end_interval_time <= &eitc;
EXEC SELECT dbid INTO :dbid FROM V$DATABASE;
--EXEC SELECT MIN(snap_id) INTO :bs FROM &hs._HIST_SNAPSHOT WHERE begin_interval_time >= SYSDATE-&dy;
--tmp DEF snp=" WHERE snap_id BETWEEN :bs AND :es  AND dbid=:dbid";
DEF snp=" JOIN &hs._HIST_SNAPSHOT snp USING (snap_id) WHERE begin_interval_time >= &bitc AND  end_interval_time <= &eitc"
--11b
PROMPT --top 5 timed events
DEF ev1=" FROM &hs._HIST_SYSTEM_EVENT ev"
DEF ev2=" AND wait_class !='Idle'";
EXEC SELECT SUM(time_waited_micro_fg) INTO :tot &ev1&snp&ev2
DEF evSel1=" FROM (SELECT event_name, ROUND(100*SUM(time_waited_micro_fg)/:tot,2) wpc FROM &hs._HIST_SYSTEM_EVENT ev "
DEF evSel2=" AND wait_class !='Idle'  GROUP BY event_name ORDER BY wpc DESC) ev WHERE ROWNUM<=5";
SELECT ev.* &evSel1&snp&evSel2;
COLUMN obj FORMAT A40
SELECT ash.* FROM (SELECT machine,event, (SELECT object_name FROM &hs._OBJECTS WHERE object_id=current_obj#)obj, sql_id,top_level_sql_id, MAX(TIME_WAITED) tw, MAX(st.elapsed_time_delta) el
FROM &hs._HIST_ACTIVE_SESS_HISTORY LEFT JOIN &hs._HIST_SQLSTAT st USING(snap_id,sql_id) &snp AND event IN (SELECT ev.event_name &evSel1&snp&evSel2) GROUP BY machine,event, current_obj#,sql_id,top_level_sql_id ORDER BY tw DESC) ash WHERE ROWNUM<=15; 

--tmp
SELECT * FROM (SELECT obj.object_name,MAX(physical_reads_direct_delta),MAX(logical_reads_delta) FROM &hs._HIST_SEG_STAT seg JOIN DBA_OBJECTS obj ON obj.object_id=seg.dataobj# &snp AND obj.owner='&ow' GROUP BY obj.object_name ORDER BY 2 DESC,3 DESC) WHERE ROWNUM<=5;
SELECT * FROM (SELECT sql_id,SUM(iowait_delta)/POWER(10,6) iw,SUM(elapsed_time_delta)/POWER(10,6) et, SUM(executions_delta) FROM &hs._HIST_SQLSTAT &snp GROUP BY sql_id ORDER BY et DESC,iw DESC) s WHERE ROWNUM<=5 ;
SELECT sql_text FROM &hs._HIST_SQLTEXT WHERE sql_id='&sqlid';

--11c
PROMPT db load
DEF stats=" stat_name In ('db block changes','session logical reads','CPU used by this session')"
--SELECT snp.begin_interval_time,snp.end_interval_time, s1.stat_name,(SELECT s1.value-s2.value FROM &hs._HIST_SYSSTAT s2 WHERE s2.snap_id=s1.snap_id-1 AND s1.stat_name=s2.stat_name ) dv 
SELECT s1.stat_name,TRUNC(snp.begin_interval_time) dt, MAX(s1.value)-MIN(s1.value) val FROM &hs._HIST_SYSSTAT s1 &snp AND &stats GROUP BY s1.stat_name,TRUNC(snp.begin_interval_time)
ORDER BY s1.stat_name,dt;

--11d
PROMPT ADDM analysis
DEF stats=" stat_name In ('db block changes','session logical reads','CPU used by this session')"
column message format A100;
SELECT f.message, SUM(f.impact),r.type FROM DBA_ADVISOR_FINDINGS f JOIN DBA_ADVISOR_RECOMMENDATIONS r  USING (task_id,finding_id)
 WHERE r.rank=1 AND r.type NOT IN ('SQL Tuning', 'Application Analysis') AND f.type='PROBLEM' AND task_id IN (SELECT task_id FROM DBA_ADVISOR_TASKS WHERE execution_start>=&bitc AND execution_end<=&eitc)
GROUP BY f.message,r.type ORDER BY SUM(f.impact);

--11e, AWR repo even in SE2
/* -- setup
DEF tbs=" TABLESPACE mon"
CREATE TABLE HS_HIST_ACTIVE_SESS_HISTORY &tbs AS SELECT 1 snapshot_id, 1 dbid, t.* FROM V$ACTIVE_SESSION_HISTORY t WHERE 2>4;
CREATE TABLE HS_HIST_SEG_STAT &tbs AS SELECT 1 snapshot_id, 1 dbid,t.* FROM V$SEGSTAT t WHERE 2>4;
CREATE TABLE HS_HIST_SNAPSHOT (snap_id NUMBER, dbid NUMBER, begin_interval_time DATE, end_interval_time DATE)&tbs ;
CREATE TABLE HS_HIST_SQLSTAT &tbs AS SELECT 1 snapshot_id, 1 dbid,t.* FROM V$SQL t WHERE 2>4;
CREATE TABLE HS_HIST_SQLTEXT &tbs AS SELECT 1 snapshot_id, 1 dbid,t.sql_id,t.sql_fulltext FROM V$SQL t WHERE 2>4;
CREATE TABLE HS_HIST_SYSSTAT &tbs AS SELECT 1 snapshot_id, 1 dbid,t.* FROM V$SYSSTAT t WHERE 2>4;
CREATE TABLE HS_HIST_SYSTEM_EVENT &tbs AS SELECT 1 snapshot_id, 1 dbid,t.* FROM  V$SYSTEM_EVENT t WHERE 2>4;
*/
./hk/db@itfs1/db/awrCapSe2.sh

/*
--11c
DEF rw='write'
PROMPT --top 5 segs
DEF ev="FROM DBA_HIST_SEG_STAT &snp ";
COLUMN obj FORMAT A20;
EXEC SELECT SUM(physical_&rw.s_total) INTO :tot &ev
SELECT (SELECT owner||'#'||DECODE(object_type,'LOB',(SELECT l.table_name||'.'||l.column_name FROM DBA_LOBS l WHERE segment_name=obj.object_name),obj.object_name)object_name FROM DBA_OBJECTS obj WHERE object_id=ev.obj#) obj, wpc 
 FROM (SELECT obj#,ROUND(100*SUM(physical_&rw.s_total)/:tot,2) wpc &ev GROUP BY obj# ORDER BY wpc DESC)ev WHERE ROWNUM<=5;
--11d
PROMPT --top 5 sqls by execn
DEF ev="FROM DBA_HIST_SQLSTAT &snp ";
EXEC SELECT SUM(elapsed_time_total) INTO :tot FROM(SELECT MAX(elapsed_time_total) elapsed_time_total &ev GROUP BY sql_id) ;
SELECT (SELECT sql_text FROM DBA_HIST_SQLTEXT txt WHERE txt.sql_id=sqd.sql_id AND ROWNUM<=1) sql_text, wpc FROM (SELECT sql_id,ROUND(100*MAX(elapsed_time_total)/:tot,2) wpc &ev GROUP BY sql_id ORDER BY wpc DESC) sqd WHERE ROWNUM<=5;
*/

--12
PROMPT -- plsql optimization
COLUMN owner FORMAT A20;
COLUMN plsql_code_type FORMAT A20;
SELECT owner,plsql_code_type,plsql_optimize_level,COUNT(*) FROM DBA_PLSQL_OBJECT_SETTINGS GROUP BY owner,plsql_code_type,plsql_optimize_level ORDER BY 1,2;

--13 
PROMPT -- opt stats
--13a
PROMPT -- sys stats
SET CMDSEP on
   DEF sep="||' '||"; PROMPT wl => workload, sreadtim|mreadtim|mbrc => bfc sync( delay for io, latch contention, task switching) ; SET CMDSEP off;
   DECLARE status VARCHAR2(20); dstart DATE; dstop DATE; pvalue NUMBER; TYPE typaram IS VARRAY(9) OF VARCHAR2(50);
    lparam typaram :=typaram('iotfrspeed','ioseektim','sreadtim','mreadtim','cpuspeed','cpuspeednw','mbrc','maxthr','slavethr');
    lpValDesc typaram :=typaram('bytes/ms !wl','ms !wl','ms wl bfc sync','ms wl bfc sync','millionsCycles/s wl(plsql ref)','millionsCycles/s !wl','bls wl bfc sync','bytes/s','bytes/s wl');
   BEGIN FOR i IN lparam.FIRST..lparam.LAST LOOP DBMS_STATS.get_system_stats (status=>status, dstart=>dstart, dstop=>dstop, pname=>lparam(i), pvalue=>pvalue); DBMS_OUTPUT.put_line(status &sep dstart &sep dstop &sep lparam(i) &sep pvalue &sep lpValDesc(i));
   END LOOP; END;
/

--14



