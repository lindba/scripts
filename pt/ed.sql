--1094934.1
SET NUMFORMAT 9999999999.99

VAR v VARCHAR2(2000);
EXEC FOR s IN (SELECT DISTINCT schema||',' s FROM DBA_REGISTRY) LOOP :v:=:v||s.s; END LOOP;
EXEC FOR s IN (SELECT DISTINCT other_schemas||',' s FROM DBA_REGISTRY WHERE other_schemas IS NOT NULL)  LOOP :v:=:v||s.s; END LOOP;
EXEC :v:=:v||'ANONYMOUS,EXFSYS,PUBLIC,AURORA,MDSYS,REPADMIN,$JIS,ODM,SYS,$UTILITY,ODM_MTR,SYSMAN,$AURORA,OLAPSYS,SYSTEM,$ORB,ORDPLUGINS,TRACESVR,$UNAUTHENTICATED,ORDSYS,WKPROXY,-
 CTXSYS,OSE$HTTP$ADMIN,WKSYS,DBSNMP,OUTLN,WMSYS,DMSYS,PERFSTAT,XDB,DSSYS';
DEF whusrs=" INSTR(:v,owner)=0"
--size of big tab
DEF sbt=50


SELECT a.ksppinm "Parameter", b.ksppstvl "Session Value", c.ksppstvl "Instance Value" FROM x$ksppi a, x$ksppcv b, x$ksppsv c
WHERE a.indx = b.indx AND a.indx = c.indx AND 
((a.ksppinm ='_partition_large_extents' AND UPPER(b.ksppstvl)!='TRUE')
OR (a.ksppinm ='_index_partition_large_extents' AND UPPER(b.ksppstvl)!='FALSE')
);

-- Tablespace creation
SELECT * FROM DBA_TABLESPACES WHERE EXTENT_MANAGEMENT!='LOCAL' 
 OR ((allocation_type!='SYSTEM' OR SEGMENT_SPACE_MANAGEMENT!='AUTO') AND contents='PERMANENT' AND tablespace_name NOT IN ('SYSTEM','SYSAUX'));

-- How many tablespaces should you use?
PROMPT multiple BFTs avoid file header block contention(gc buffer busy) during || load 
SELECT segment_name, SUM(bytes)/1024/1024/1024 gb FROM DBA_SEGMENTS WHERE &whusrs GROUP BY segment_name HAVING SUM(bytes)/1024/1024/1024>&sbt AND COUNT(*)!=COUNT(DISTINCT tablespace_name);

--Setting extent size using INITIAL and Next in the storage clause of non-partitioned table create statement 
PROMPT INITIAL & NEXT of large segs should be >=8MB
SELECT segment_name, MIN(LEAST(initial_extent,next_extent)/1024) mb, COUNT(*), SUM(extents) exts FROM DBA_SEGMENTS WHERE &whusrs AND LEAST(initial_extent,next_extent)<8*1024*1024 
 GROUP BY segment_name HAVING SUM(bytes)/1024/1024/1024>&sbt;

PROMPT char data types, bug# 9502734,9479565
SELECT owner,COUNT(*) FROM DBA_TAB_COLUMNS WHERE &whusrs AND data_type='CHAR' GROUP BY owner;

--skipped: data loading

--How to pick the number of hash partitions
PROMPT #_hash prtns = 2* #_cpus, each hash prtn >=16MB(modified to 1GB)
VAR ncpu NUMBER;
EXEC SELECT SUM(value) INTO :ncpu FROM GV$OSSTAT WHERE stat_name='NUM_CPU_CORES';
SELECT * FROM (SELECT segment_name, prtn_sz/1024/1024/1024 prtn_gb, 2*:ncpu hash_prtns, cur_prtns,cur_avg_prtn_gb  FROM 
(SELECT segment_name, SUM(bytes) sz, SUM(bytes)/(2*:ncpu) prtn_sz, COUNT(*) cur_prtns , AVG(bytes)/1024/1024/1024 cur_avg_prtn_gb 
 FROM DBA_SEGMENTS WHERE &whusrs GROUP BY segment_name HAVING SUM(bytes)/1024/1024/1024>&sbt)) WHERE prtn_gb>=1;
 
PROMPT prtn-wise joins: both tabs should be prtned on same col with same prtning method & same #_prtns

--Parallel Query
PROMPT !|| for <64MB tabs
SELECT owner, COUNT(*) FROM DBA_TABLES WHERE &whusrs AND (degree||instances LIKE '%DEFAULT%') 
AND (owner,table_name) IN (SELECT owner,segment_name FROM DBA_SEGMENTS GROUP BY owner,segment_name HAVING SUM(bytes)<64*1024*1024) GROUP BY owner;
SELECT owner, COUNT(*) FROM DBA_TABLES WHERE &whusrs AND (degree||instances NOT LIKE '%DEFAULT%')
AND (owner,table_name) IN (SELECT owner,segment_name FROM DBA_SEGMENTS GROUP BY owner,segment_name HAVING SUM(bytes)/1024/1024/1024>=&sbt) GROUP BY owner;

-- When to gather dictionary statistics 
PROMPT stats
PROMPT after loading, collect tab stats
PROMPT after loading & running representative workload: "EXEC DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;"
PROMPT "EXEC DBMS_STATS.SET_GLOBAL_PREFS('INCREMENTAL','TRUE');" 
PROMPT "EXEC DBMS_STATS.SET_GLOBAL_PREFS('DEGREE','128');" 
SELECT q'{EXEC DBMS_STATS.GATHER_SCHEMA_STATS('}'||username||q'{');'}' FROM DBA_USERS WHERE INSTR(:v,username)=0;

-- Initialization Parameters Settings 
SELECT * FROM GV$PARAMETER WHERE name IN ('compatible') AND RPAD(REPLACE(value,'.'),8,'0')<112010;



--storageSwUsrGuide.pdf > chp: monitoring & tuning ora exadata storage server s/w > optimizing perf 

--about fast disk scan rates
PROMPT au_size should be >=4MB
SELECT * FROM V$ASM_DISKGROUP WHERE allocation_unit_size<4*1024*1024;
