SET ECHO off TERMOUT off;
--SELECT 'SET SQLPROMPT "'||SUBSTR(host_name,1,DECODE(INSTR(host_name,'.'),0,1234,INSTR(host_name,'.'))-1) ||'.'||instance_name||'> "' FROM V$INSTANCE;
DEF ctx="SYS_CONTEXT('USERENV',"
DEF _EDITOR = vi 
SPOOL setPrompths.sql;
SELECT 'SET SQLPROMPT "'||&ctx'INSTANCE_NAME')||'@'||&ctx'SERVER_HOST')||'> "' FROM dual;
SPOOL off;
--host echo SET SQLPROMPT SQL@`hostname`'> '>setPrompths.sql
@setPrompths.sql
host rm setPrompths.sql
--ALTER SESSION SET NLS_DATE_FORMAT="DD-MON-RRRR::HH24-MI-SS";
COLUMN inst_id FORMAT 9;
--V$ASM_DISK
COLUMN path FORMAT A30;
COLUMN owner FORMAT A30;
SET ECHO off FEEDBACK on HEADING on LINESIZE 300 LONG 200000000 LONGCHUNKSIZE 200000000 NUMWIDTH 15 PAGESIZE 2000 SERVEROUTPUT on TAB off TERMOUT on TIME on TIMING on TRIMSPOOL on VERIFY off



