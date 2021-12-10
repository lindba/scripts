SET ECHO OFF VERIFY OFF
COLUMN service_name FORMAT A15;
COLUMN prc_thrd FORMAT A20;
COLUMN mc FORMAT A40;
COLUMN prog_cv FORMAT A40;
COLUMN username FORMAT A30;
/*
DEF thrdCls="(CASE WHEN p.execution_type='THREAD' THEN p.sosid ELSE p.execution_type END)"
SELECT NVL(pd.name,MAX(p.pname)) name,&thrdCls||'@'||p.inst_id prc_thrd,s.machine,s.username,s.status,s.server,ROUND(SUM(pga_max_mem)/1024/1024) maxmb, ROUND(SUM(pga_max_mem)/1024/1024) allocmb,COUNT(*) c
FROM GV$PROCESS p LEFT JOIN GV$SESSION s ON p.inst_id=s.inst_id AND p.addr=s.paddr JOIN GV$PDBS pd ON pd.inst_id=s.inst_id AND pd.con_id=s.con_id
GROUP BY p.inst_id,pd.name,&thrdCls,s.machine,s.username,s.status,s.server ORDER BY 1,2,3,4,5,6;
*/
DEF thrdCls="(CASE WHEN p.execution_type='THREAD' THEN p.sosid ELSE p.execution_type END)"
--DEF 12a="NVL(pd.name,MAX(p.pname)) name,&thrdCls||'@'||p.inst_id prc_thrd,"
--DEF 12a="&thrdCls prc_thrd,"
--DEF 12a="&thrdCls||'@'||p.inst_id prc_thrd,"
--DEF 12b="JOIN GV$PDBS pd ON pd.inst_id=s.inst_id AND pd.con_id=s.con_id"
--DEF 12b="JOIN V$PDBS pd ON pd.con_id=s.con_id"
DEF 12c=",pd.name,&thrdCls"
DEF 12a=""
DEF 12b=""
DEF 12c=""
--DEF prog_cv="s.program||'#'||SUBSTR(ci.network_service_banner,-23,10)"
DEF prog_cv="MAX(s.program||'#'||client_version||(CASE WHEN ci.network_service_banner LIKE '%AES256%' THEN 'e' END))";
SELECT s.service_name,&12a s.osuser||'@'||s.machine mc, &prog_cv prog_cv,s.username,s.status,s.server,ROUND(SUM(pga_max_mem)/1024/1024) maxmb, ROUND(SUM(pga_max_mem)/1024/1024) allocmb,COUNT(*) c
FROM V$PROCESS p LEFT JOIN V$SESSION s ON p.addr=s.paddr &12b LEFT JOIN V$SESSION_CONNECT_INFO ci ON s.sid=ci.sid AND s.serial#=ci.serial#
WHERE s.username IS NOT NULL AND (('&1'='n' AND s.action LIKE 'NA_%') OR '&1'='y') GROUP BY s.service_name&12c,s.osuser||'@'||s.machine,s.username,s.status,s.server 
--WHERE s.username IS NOT NULL AND NVL(s.action,'a') LIKE DECODE('&1','n','NA_%','a') GROUP BY p.inst_id,s.service_name&12c,s.osuser||'@'||s.machine,&prog_cv,s.username,s.status,s.server 
ORDER BY 1,2,3,4,5,6;
UNDEF 1;


/*
--uncomment when needed
SELECT spid||'@'||inst_id spid,pd.name, ROUND(SUM(pga_max_mem)/1024/1024) maxmb,ROUND(SUM(pga_alloc_mem)/1024/1024) allocmb,COUNT(*) FROM GV$PROCESS LEFT JOIN GV$PDBS pd USING(con_id,inst_id) GROUP BY inst_id,spid,pd.name  HAVING COUNT(*) >1 ORDER BY 1,2,3;
! s2=0;for pid in `pgrep -f u00`; do s1=0;for s in `pmap -x $pid | grep anon | tr -s ' '| cut -d ' ' -f 4`; do s1=`expr $s1 + $s`; done; echo $pid: $s1 KB; s2=`expr $s2 + $s1`; done; echo $s2 KB;
/proc/13027/smaps
*/
