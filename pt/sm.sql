@scripts/login
DEF sql_id='&1'
SELECT sql_fulltext FROM V$SQLAREA WHERE sql_id='&sql_id';
SELECT plan_table_output FROM TABLE (DBMS_XPLAN.display_cursor( sql_id=>'&sql_id', format => 'TYPICAL'));
COL bind FORMAT A40;
SELECT DISTINCT name||'->'||value_string bind FROM V$SQL_BIND_CAPTURE WHERE sql_id='&sql_id';
@login

