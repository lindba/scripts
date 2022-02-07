HAProxy is not :
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% IMP1
%%%%%%%%%%%%%% prod db (tuning)
#optr stats: ~ t7a: gather {tab|ind|sch|db|sys|fixed obj(dyn perf tabs)} stats. rep objs affected by gather stats. vw: stats of tab,col,ind; hist(+running,hs) of (stats ops, tasks(task ∴ tgt obj ∈ parent op)); stats prefs of tabs; tab modified since last stats-gathering. 
  full stats colln.  pkg: set|get pref(eg stale%, uses pref (!i/p param))  
 ~ S41, P: tabs often deleted or truncated & rebuilt ∴ del stats (to use dyn samp) or gather representative stats -> lk stats.   l:optimizer_dynamic_sampling>=2     
   P: gather sys & fixed obj stats when db has representative activity. sys stats: i/o, cpu perf. auto stats colln does !gather sys stats. auto gathers essential sys stats at 1st inst startup. 
 ~ t7b: drop, crt stat tab; exp, imp tab, ind, sch stats; lk, unlk, del tab stats.       ~ t7d: (enable, disable | run) auto optr stats colln job (at windows | imdtly). autotask vw: task, job hist, task(stats, seg adv, sql tune adv) windows.   
 ~ t26i, ip: optr uses dyn stats auto when needed. adaptive stats (ip) = true + ∃ SPD ∴ optr uses dyn stats(dsa) -> dsa ∈ SPD store, for queryO.
 ~ t7e: vw: hist of tab stats modifications(expt: +gather).  proc: report comparing tab stats bet 2 past timestamps; report stats ops bet 2 timestamps; get|alter stats hist retention val; get timestamp of oldest available stats; 
   purge stats bef a timestamp; get sys stat; res db, dict, fixed obj, sch, sys, tab stats as of given timestamp; set (tab | col stats(hg) | ind) stats, gather/set/vw processing rate(cpu (+, group by, HJ, NL), io random, io seq, m/m).
 ~ S41, algo of auto sample sz: f(hash), faster than sampling, rds all rows, -- deterministic stats (accurate as 100% sample).  ~S41: crnt(!=degree=dop) stats colln =f(job queue ps ip). ip ∴ max #-job_slaves/inst for execution of DBMS_JOB & scheduler jobs.
 ~ S53,t7h: ip use pending stats. DBMS_STATS: get|set prefs to auto publish, publish|del|exp pending stats.  vw: tab,col,ind pending stats.
 ~ S107,extn: optr uses col gr stats for equality preds, inlist preds, & for estimating GROUP BY cardinality.  t7i: crt|drop extn(col grp or expr). pref: SPD can trigger creation of col gr stats f(usage of cols in preds).
    t7l: col stats vw join extn vw on col.       ~S67: expr stats store (ESS) = {stats about expr evaluation} ∈ SGA & disk. ESS stats vw.  l: DBA_EXPRESSION_STATISTICS
#~ t8: ses tracing. tkprof. trcsess consolidates trace o/p from selected trace fls. ses ip: trace fl identifier. set events for tracing ORA err.  #~t9a: move (tab|LOB col) upd ind. rebuild ind. ~S106: rebuilding existing ind ∴ existing ind is data src.  #t9b: sqlt
#S81:~seg shrink: DML allowed during data movement; crnt DML blocked for short time when space deallocated; inds remain usable; reclaims unused space<>HWM. space deallocation...only > HWM. 
 ~ t15c: tab or ind shrink(+dependent). ~t15f,pkg: space usage by tab or ind.  ~ t15g: allocate tab ext.  
 ~ t15b: P: alert: pkg. vw: info, hist. P,pkg: rep, implement, script, filter(skipped) stats advisor task.  ~ t15p: > advisor: pkg. vw: task, param, log, progress, finding, recommendation, action, obj.
 ~ t15d,vw: sys metric, os stat; iostat of fl, nw, fn (ARCH,RMAN etc); usage of some sys rsrcs(eg ps,ses,txn)(expt: !rows in pdb); io stats of fls, tmp fls; hg(time bkt) ∀ sync single bl rds for dfs; {sys|ses-wide time for diff ops}
#S14:~ #-CPUs=8 + real time =1min ∴ cpu time =8mins.  ~disk queue lengths > 2 or disk svc times > 20-30ms ∴ overly active io sys.  hs,ol5: svctm(ms), avgqu-sz cols in iostat -kx 2, sol: svc_t(ms), wt(queue length) in iostat -Mx 2
#~ t32a, undo vw: stats f(time interval), effective retention(ur), US, ext, US stat. ip: ur, concurrent txns/US.  ~for autoextend undo tbs, auto tunes ur period (>=ip) f(undo requirement). for fixed-sz undo... (!=f(ip) unless ur guaranteed) =f(undo tbs sz & usage hist). 
#~ OR: switch logs <=1 ∀ 20 min. ~ t32b: vw: monitors rec io, log hist. ip: ckpt timeout|interval, mttr tgt.
 ~ t32c: P: DML on GTT does !gen redo. its undo gens redo.  expt: tmp tbs is NOLOGGING.   P: enable tmp undo(ip) ∴ tmp undo log (for GTT or tmp tab transformations) + permanent undo log (for persistent objs). ip set ∴ can!  be changed for entire ses. enabled 
   bdft on stdby. undo stored in tmp tbs does !gen redo ∴ ∃ DML on GTTs on active DG.
#S42: ~t33a: thread ckpts: db wrs to disk all bfrs modified by redo in a specific thread bef cst db shutdown, fg ckpt, RLF switch, begin user-managed db bkp. RLF switch forced ∴ begins ckpt + returns ctrl imdtly, !when ckpt is complete. 
   expt:(archive curr RLF | switch RLF) ∴ switches both|curr threads.  db ckpt = {thread ckpt ∀ inst}.  ~t33b: tbs & df ckpts: db wrs all bfrs modified by redo, to disk -> tbs (ro, offline normal), shrink df, begin user-managed tbs bkp etc.  tbs ckpt ={df ckpt}
 ~ incr ckpt is a type of thread ckpt partly to avoid wring large #-bls at RLF switches. dbwn checks for work ∀ <=3 secs. when dbwn wrs dirty bfrs, ckpt wrs ckpt position to cf, !to df hdrs.  ~ckptO ⊃ {inst & media rec ckpt, ckpt when objs are dropped or truncated}. 
#S43: ~ lt is simple, low-level coordinator of multiuser acs to shared data structures(eg deallocation of m/m while being acsed), objs & fls.      
  P: typically, 1 lt protects >1 objs in SGA. eg bps use a sp lt to allocate m/m from sp to crt data structures, that serializes acs to prevent 2 pses from trying to inspect or modify sp simultaneously. -> psO may need to acs sp areas (eg lc for parsing). here, ps 
     lt only lc, not entire sp.     P: lt available ∴ 1st ses(!queue) to req lt obtains it. ps repeatedly reqs lt in loop ∴ lt spinning. ps releases CPU before renewing lt req ∴ lt sleeping.
  P: typically, lt acquired for very short time for data structure. db may use 1000s of ltes to upd 1 emp's salary. lt implementation (eg whether & how long ps wts for lt) = f(os).   P: lt(!mutex) can be bottleneck when pses attempt to acs protected obj crntly.        
  P: mutex consumes less m/m than lt.         P: in shared mode, mutex permits crnt ref by >1 sess.         #~ t34a: ind monitoring.  vw: ind usage.     ~mutual exclusion obj (mutex) is low-level coordinator of crnt acs to obj. mutex (unlike lt) protects 1 obj.
 ~ internal lks: higher-level, more complex mechanisms than ltes & mutexes, serve diff purposes.       > DD cc lk: very short duration, on entries being modified or used. DDL|parse complete ∴ exclusive|shared lk released.
   > fl & log mgmt lk: cf (1 ps at a time can change), RLF(use & archiving), df for long ( to mount db in shared or exclusive mode).      > tbs (online or offline ∀ insts), US( wr: (inst,US)=(1:many)) lk.
#~ t35a,vw: lk, lk type, lk & lt, lkd obj, enq stat, lt, blocker & blocked ses + event, ses(addr of lk wting for, fl#|bl#|row# being lkd). dbl wt class ∴ crnt insert at same pt of ind. eg, seq# generators for key vals. implement ASSM, global hash prtned ind.
 ~ S43:: ∃ row lk(TX) ∀ row modified by INSERT, UPDATE, DELETE, MERGE, or SELECT ... FOR UPDATE(SFU).  tab lks(TM): P: row|subshare(RS|SS) ∴ rows lkd to upd.   P: row|subexclusive(RX|SX), generally ∴ rows updd or SFU issued. others can +,-, upd,lk rows ∈ $tab.
   P: share(S) ∴ !SFU, upds allowed if 1 txn holds S.  P: share row|subexclusive(SRX|SSX) ∴ !SFU, !upd allowed. 1 txn at a time can SSX tab.   P: exclusive(X).     ~ t35b, DDL wts for ip time in DML lk queue.  ~t35c,script: lk wait-for graph in tree structure format.
#~ t36a: hip: desired work area(wa) sz, m/m for pl/sql local vars (=!f(pga tgt)).  ~ t36b, ip: tgt|limit aggregate pga ∀ svr pses. local/pt/pga.sql: pmap
 ~ t36c,vw: wa, active wa, wa hg (excn f(wa sz)), pga tgt advice hg (adv f(wa sz)), sql plan, sql bind val, sql plan stats, sql plan stats all. l > sql mon.  #t36d: compare plans.   #expt: revoke exec on proc hangs if proc is executing.  
#~ t10a: identify migrated & chained rows. ~t10c: P:inserted row(eg LONG,LONG RAW) >> dbl ∴ row = chain of bls. 255-cols/row-piece. P:rowA(updd)+... > bl ∴ rowA goes to new bl, (assuming rowA<=bl). orig row piece ⊃ { pointer to new bl}. !rowid change. 
#~ t10d: tab: keep|dft bfc.  #~ S44: parent|child cr f( ( | ∀ sql ∈) embedded plsql blk).  ~t10f,vw: open cr.  #~ t10e,ip: invalid cr(ic) -> cr gets random time period(tp) -> tp expired -> query accesses ic -> hard parse(only now).     #t38a: vw: ses wt, ses wt hist.
#S14, wt events:
 ~ ses can! pin bfr in bfc as sesO, (#t38b) has pinned it, (#t38c) is rdg it from disk.  ~ t38f: wr bfr by normal aging.  ~ t38g: complete dbwr ios.   ~ t38h: wr fl hdrs
 ~ t38i: P: bfr gets suspended. eg, ro fl (ie bfrs are !linked to lk elements) became rw ∴ bfrs are invalidated.  P: wr full dirty queue.  P: 'free bfr inspected' -> !free bfr -> wt 1 sec -> try to get bfr again (f(context)). 
 ~ t38j: lk to load lc obj. ~ t38k: S|X lc obj lk(also to locate lc obj).  ~ t38l: load heap to m/m. to modify or examine obj: lk -> lc pin. vw: lc lk. ~ t38m: wr from log bfr to RLF.
 ~ t38n: ses commits(or rolls back) -> ses posts lgwr to wr ses's redo to RLF -> lgwr wrs -> lgwr posts ses.  wt time = wring + posts. low avg wt time + high #-wts ∴(may) freq commit. high avg wt time ∴ check ses wts for lgwr, may be slow io.  
 ~ t38o, RLF: updating hdr, adding member, incrementing seq#.       ~t38p, lt: sp, bfc lru chain, bfc chain(for searching, adding, removing bfr from bfc, hot bl), DD, misc. vw: ses wt (lt addr, lt#, #-times ps slept wting for lt), lt stats, lt name, bfc.
 ~ t38q, reply from bp.  ~t38r: sqlnet break/reset to {clnt|dblink}, (mesg|more data) from|to clnt|dblink.  ~t38s: RLF switch. ~t38t: RLF switch( ckpt for next RLF incomplete).  ~t38u: curr RLF ∀ open thread to be archd.  
 ~ t38v: RLF switch (arch needed).  ~ 'log bfr space'.   ~ t38w: 1 bl read into 1 SGA bfr eg. ind scan. >1 bl read into >1 discontinuous SGA bfrs eg. ind fast full scan, FTS.   ~t38x: df || rd: during reco, bfr prefetching.  
 ~ 'DP rd' (1 or >1 bl read into PGA, bypassing SGA),'DP rd temp': t38w is !AIO.  cause: tmp seg usage, svr ps faster than io sys.  
 ~ 'DP rd','DP wr': AIO from/to df. to complte all outstanding AIO or ∃ !slot to store outstanding load req (load req ={io}). ~'DP wr','DP wr tmp': wr bfrs directly from PGA (cf dbwn wring from bfc) eg.sort on disk,DPI,some LOB op.
 ~ t39a,enq:  P,t39b: to serialize space allocation beyond HWM. soln: manual allocation of ext. P,t39c: mostly where foreign key constrained cols are not indd.  P,Q,t39d: ses1 updg/-g $row, ses2 wants to upd/- $row.   
    Q,t39e: !free ITL(interested txn list) slot in bl, !free space to add it.  soln: increase initrans.  
    Q,t39f: ∃ unique ind. 2 sess inserting same key, 2nd ses wts for ORA-0001.    Q,t39g: wtg for a PREPARED txn.    Q,t39h: ind bl split -> insert into ind wts.   ~t39l: sesA holds X mutex pin on $cr -> sesB requests S mutex pin on $cr.
 ~ idle wt events: P,t39i: pmon trying to sleep.  P,t39j: bp wtg for IPC mesg (to do work) from fg ps.  P,t39k: smon, pipe, SSA.  ~ t29a, vw: bl contention stats; ses,sys event; event hg( #-wts = f(wt time)); event name; sys wt class
#stats: ~ t40a,vw: stat name, sys|ses stat.   ~ t40b: bfc hit ratio.  ~ t40c: #- cst bl rd reqs.  ~ t40d: #- curr bl reqs.  ~ t40e: total #-dbls rd from disk(a. |b.into bfc|c.bypass bfc). a>b+c ∴ rds into ps priv bfrs ∈ a.
 ~ t40g: #-retries to allocate space in redo bfr. reason: lgwr fallen behind, log switch.   ~t40h: #-redo entries in redo bfr.  ~t40i: #-sorts w/ >=1|0 disk wr. ~t40j,vw: sort seg, tmp seg usage, seg stats.  ~ t40k: #-times rollback entries applied for cst bl rd.
 ~ t40l: CPU time used by this ses, by !user (recursive) calls. ~t40n: dbwr lru scans to wr bfrs (eg for ckpt)  ~t40o: ckpts completed by bp, by dbwr(>bp). fg ∴ user-requested.  ~t40r: hard|total #-parses.    
 ~ t40p:  #-bfrs|#-dirty-bfrs skipped from end of LRU queue by user ps to find reusable bfr. diff = #-busy bfrs. ~t40q: cpu|elapsed time in parsing.   ~t40s: #-recursive calls at user & sys level. ora gens internal SQL to change internal tab.  
 ~ t40t: #-reqs for disk space of switched RLF.  ~ t40u: #-bytes wasted in wring incompletely full redo bls to commit txns, to wr db bfr, to switch logs.  ~t40v: sum (dirty LRU queue length after every wr completion).   
 ~t40w: #-rows rd w/ rowid. #-times chained or migrated row rd.  ~ t40x: #-scans of long|short tabs. tab, CACHE|NOCACHE: FTS bls are placed at MRU|LRU end of LRU list
#~ t27b: branch bls: |0..40|...|200..250|  |0..10|...|32..40|  leaf bls: <-|32,rowid|32,rowid|...|40,rowid|->  ~t27c: hints to skip all query transformations,(eg OR-expansion, vw merging, subquery unnesting, star transformation,mvw rewr).
 ~ t21a,b: mvw.  ~ global tab hints: vw.tabAlias1.tabAlias2.     ~ S38: ind bl body|row-hdr !| stores entries in key order. hs: higher PCTFREE for OLTP inds to avoid split bl. details in MOS
#~ t27a, vw: ctrg factor(∴ind entries in a leaf bl tend to point to rows in same dbls or not).  ip: use of invisible inds. 
#S45: ~ basic m/m structures={SGA,PGA,s/w code areas} 
 ~ user global area(UGA)={ses var(eg logon info),OLAP page pool}. UGA sup{pkg vars' val}. bdft, pkg vars are unique to & persist for life of ses. UGA is available for entire ses. so UGA ∈ large pool (in sp if !large pool) in SSA + ∈ PGA in dedicated svr.
 ~ PGA={sql work area{sort area,hash area,btm merge area},ses m/m,priv sql area{persistent area,runtime area}}.  P: runtime(r) area ={query execn state info(eg #-rows retrieved so far in FTS)}.  
   P: persistent(p) area ={bind var val}. DML-stmt|cr closed ∴ r|p area freed.  P: HJ uses hash area to build hash tab from its left i/p.  ~all SGA comps except redo log bfr & fixed SGA bfr allocate & deallocate space in granules(contiguous m/m).   
 ~ ref, redo strand(rs): log bfr sz =f(#-rss). #-rss = max(2,#-cpus/16), default rs sz = 2MB. hip: rs sz. expt, RLF=100MB: (log bfr, ALF sz): (90M,54.6M),(5M(dft),93.1M),(10M,90.6M|80.6M),(30M,81.6M|70.3M). ref 1356604.1. 
 ~ bfr states: unused: never used or currently unused; clean: used + now ⊃s read-cst vrsn of bl as of a pt in time. db can pin the bl & reuse it.  dirty: 
 ~ bfr acs mode: pinned or free (unpinned). pinned bfr !aged out while ses acss it. >1 sess can! modify pinned bfr at same time(?).
 ~ t27f, bfr replacement algo: P: LRU list has pointers to dirty & !dirty bfrs, has hot & cold ends. for crncy, ∃ >1 LRUs.
   P, ip(tgt % of bfc for auto big tab caching(btc)) >0:  btc < all tabs to be scanned ∴ only most freq acsd tabs ccd + DP rd for rest. bfc-btc for insert, upd, & random acs. btc uses temperature & obj-based algo to track medium & big tabs. ccs very small tabs, 
   but !tracks in btc. vw: param, active obj.    ~ S72,t27g,force full db caching: enable,disable,vw. objs ∈ bfc when acsd. info ∈ cf.
 ~ eg: uncommitted txn updd 2 rows in a bl -> modification stmt retrieves the bl w/ uncommitted rows -> query in separate ses requests the bl -> undo used to crt rd-cst vrsn of this bl. hs:∴ ∃ >1 rd-cst copy of same bl (! curr bl) in bfc.  
 ~ logical io = io in bfc. cc miss ∴ phy io from disk into m/m + logical io.  ~ #-free bfrs < internal trld + clean bfrs reqd ∴ svr ps signal dbwn to wr. dirty bfrs reach cold end of LRU ∴ db moves them off LRU to wr queue. dbwn multibl wrs to disk, if possible.
 ~ bfr on LRU list pinned + its touch# ++d >3 secs ago ∴ touch# ++ || !. db does !phyly move bls in m/m, changes pointer on list.     ~ db inserts bfrs(rd from disk) into middle of LRU list. 
 ~ sp: P,lc areas: shared sql={parse tree, execn plan}(removed by LRU), (plsql & java) (exec form), ctrl structure (eg lk & lc handle), priv sql(SSA)}.  t27e,vw: obj ∈ lc.   P,dd/row cc ={data as rows(!bfrs)}.  P,resvd pool.
 ~ large pool: ⊃ {UGA for SSA, bfr for RMAN i/o slaves}, !LRU   ~java pool   ~streams pool    ~fixed SGA (internal housekeeping area) ⊃ {info f(state of db & inst) for bkg ps, info shared bet pss(eg lk info)}
 ~ s/w code areas in m/m store code that is being run or can be run. some db tools (eg ora forms, sql*plus) on some os can be installed shared(to reduce m/m usage). >1 db insts in same m/c can use same db code area with diff dbs.
 ~ t26m: sga tgt(ip, total sz of all sga comps) > 0 ∴ bfc, sp, large pool, java pool, streams pool auto szd; log bfr, bfcO(eg keep, recycle, & bl-szO), fixed sga & internal allocationo are manually szd.  
 ~ t26n,vw: granule sz.    ~12.2: set ip (pga limit, sga min sz, sga tgt, max iops/mbps(t26s)) in curr ⊃r. see ref for limit of m/m ips.  ~t26t,lin expt: !lock sga ∴ sga ∈ cc in free o/p
 ~ t26o,lin: sz of /dev/shm = sz of m/m tgt ip. m/m tgt can! be used w/ lock sga or w/ huge pages.  ~expt,lin: m/m tgt!=0 ∴ shm seg = 4K. same !in hpux. ~t26p,kernel param,ip: use large page in lin.  ~t26q,ip: lk entire sga into phy m/m.
#S50: ~ CDB={root,seed,PDBs}  root={obj$,..} PDB={obj$(for metadata of emp), emp, ..}. obj$ in PDB ⊃s metadata links to obj$ in root. obj$ is eg. each PDB uses an obj link to point to data (eg AWR data) in root. ~t24f,vw: pdb
 ~ t24g: common user(c##usr) at root can perform cross-⊃r ops(eg grant of common priv to c##usr, entire CDB reco). may grant local role or priv to c##usrOrRole. c##usr,root: cdb vw ∴ all pdbs.
   1511619.1: ∃ c##usr in pdb1 -> pdb1 plugged to cdb -> close pdb1 -> crt c##usr in cdb -> open pdb1.  ~t24p: rename user.  ~db inst: {CDB$ROOT={system,sysaux,undo,temp,RLF}, cfs, PDBi={system,sysaux,temp,pdbitbs} }   ~t24h: bkp|res root, pdb.   
 ~ t24n: rename pdb.  ~t24o: enable/disable PDB force [!]logging. force logging: CDB > PDB.   ~appln ⊃r is special type of PDB ={appln root, application PDBs}  ~12.2,local/shared undo: see in db props vw, shared <-> local(t24q),
 ~ t24a: set ⊃r in ses. ip: enable pdb. crt db w/ enable pdb cls.  ~t24b: P: unplug pdb1 into p1.xml.  P: crt pdb2 (CPDB) -> TTS !cdb.   P: >=12.1 !cdb, gen p1.xml.  P: CPDB = f({pdb1[@pdb1Link]|!Cdb@dbLink}, refresh mode, !data). pdb1Link --> pdb1Root/pdb1. 
   P: mount or unplug pdb1 > drop pdb1 w/|w/o dfs.  P: CPDB f({CLONE|NOCOPY}, p1.xml, fl name convert). ∃ pdb1a, crtd w/ fls in p1.xml ∴ use CLONE to gen unique(in cdb) DBID, GUID etc.  P: pdb2 f(max sz, path pfx).  P: pdb1 & pdb2 must have same endianness. 
 ~ S90: P,t24e,in pdb: flush sp, bc, ckpt, kill ses.  P: PDB-specific param vals !∈ text pfile.  P: PDB p1hs crtd ∴ dft svc p1hs crtd. you can! customize svc p1hs, crt svc for that. t24j: stop svc p1hs. P: w/o ora restart or GI: set ⊃r > DBMS_SERVICE (!srvctl) 
 ~ t24c: P: vw ∴ pdb svc.  P: pdb open|close;  ~12.2.proxy PDB: -- acs to PDB1 in rem/same CDB.  ~12.2,t24r: refreshing pdb.                   # t45a: sharding.
#S51 ~ t26a: vw: m/m dyn comps, curr or !curr resz ops, m/m tgt advice, bfc advice, bfr pool, bfr pool stats, sz of sga comps
 ~ P: DD cc or lc miss is more expensive than bfc miss.     P: literal vals, ! bind vars ∴ good col sly estimates. ∴ use literals for low-crncy, high-resrc sqls in OLAP.      
   P: steps to use same shared sql or plsql area:   a.text hashed. ∃ !matching hash val ∴ hard parse.   b.text (+ space, case & comment) matched. stmts differ only in literals + cr_sharing=FORCE. d.refer same objs  e.bind vars match in name, datatype & length.  
    f.identical ses env, eg. same optn goal.  ~t26f, pkg: sp keep, vw: reserved sp.  ~t26c,vw: stats on (shared sql area, lc), m/m for lc(+java) objs, stats for DD activity, sp & java pool advice.  
 ~ t26e: repeated parse call ∴ ses $cr ∈ ses cr cc(scc). ip: scc sz. ∴ !reopen of $cr. stats: scc count, scc hits, parse calls.  ~for large contiguous allocations in sp: checks free space ∈ unreserved pool(urp) -> ...rp -> attempts to free enough m/m to retry urp & rp.  
 ~ t26b,vw: mismatch in literals.   ~ force cr sharing: P: ! in DSS.   P: star transformation !supported.  P: can reduce m/m usage, lt contention, lc miss.  P:can fasten parses.  P,expt,BM: sp usage 90% -> 10%.    l: cr_sharing={EXACT|FORCE}
 ~ S92: optimal work area ⊃ {i/p data, auxiliary m/m structures}. in 1-pass(<optimal)|>1-pass (<<i/p data) work area, ∃ extra|>1 pass(s) over part of i/p data.  ~t26h,stats: #-{optimal|1pass|>1pass} execns.  ~S92: in auto PGA mgmt *_area_sz ips ignored.      
 ~ t26g,PGA vw: max AUTO work area, cc hit %.     ~ vw: ps m/m   l: V$PROCESS_MEMORY.     
 ~ multithreaded excn(MPMT): P,t26l: os authn !supported.  ip1,lsnr param: false|true ∴ lsnr |(-- con -> con broker(Nnnn) that ) spawns dedicated svr. false ∴ !MPMT.  know os thread id.  bug 16429602 m/m leak. hip: 1 ps/inst.
   P,12.2,t26r: prespawns fg ps in diff req pools. (pool,type of ps)=(1:1). vw: ps pool. pool pkg: start,stop,cfg(param: #-ps spawned (in startup | bef con-storm) in batches; #-ps in batch(bc); count after which batch spawned).
#S76, ext mergesort: ~ 1-pass merge sorting of 900MB data w/ 100MB RAM: rd 100MB data into RAM. sort by some method. wr sorted data to disk. repeat above until all data sorted in 100 MB chunks(say sc). 
 rd 1st 10 MB ∀ sc (call i/p bfr) in RAM + allocate remaining 10 MB for o/p bfr. perform 9-way merging + store result in o/p bfr. full o/p bfr ∴ wr it to final sorted fl. empty i/p bfr ∴ fill it with next 10 MB of its sc. empty sc ∴ exclude its i/p bfr from merging.
 ~ ratio of i/p data to RAM is large ∴  >1-pass sorting. eg, merge 1st half of sc, then halfO -> merge 2 sc.   ~#add# http://en.wikipedia.org/wiki/Merge_sort.  #S49: pagg|swapg: (moving portions of|copying entire) appln or ps to secry storage to free real m/m.
#t26u,ip: max #-bls rd in 1 io. although ∃ large dft val, optr will !favor large ios if this ip !set. high ip ∴ optr prefers FTS over ind. max val = ((max io sz of OS)/bl sz).  
#~ S38,S18,t28a: ASSM: manages free space of segs in tbs w/ btm. spreads inserts among bls to avoid crncy issues.   
 ~ S18: LMT for exts: ∃ a btm in df hdr to track free & used space in df body. each bit corresponds to a gr of bls. space allocated or freed ∴ db changes btm vals. tracks adjacent free space.
#S5,reverse key ind:  2 hex bytes of key C1,15 -> 15,C1. col order kept.  !ind range scan sometimes.                          l: CREATE INDEX &ind ON &tab (&col1,&col2) REVERSE; 
#~ t30a,vw: db feature usage stats, db options & features. enable|disable option.  1317265.1: options_packs_usage_statistics.sql(local/lic.sql)  ~S2: predefined user a/cs   ~t13i,ip: enable optr feature vrsn.
#~ t30b: assume %ge(ip) of ind bls in bfc. higher val ∴ prefer NL (over HJ or sort-merge joins) & inds using IN-list iterators (over indO or FTS).   ~t30c,hs: cost of ind acs path = %ge(ip) of cost of normal path.
#~ t4a: capture spb, load plan from cr cc to spb -> drop, port.  P,S52: SMB={log of sqlids(SQLLOG$), plan hist(including spb), spf, sql patches} ∈ sysaux tbs. t4d: SMB vw: curr cfg. SMB pkg (exp,imp).
   P,S52: optr can use enabled plan. db auto enables all plans in plan hist. disable plan.  P: plan hist = {[!]accepted plan(ap)}.  P: fixed plan = preferred ap(s) in spb.   P,t4c: display plans in spb.
#~ S57: spf ={corrections for cardinality & sly estimates discovered during auto sql tuning}.  ~S58: spf is implemented w/ hints(h). h !∴ particular plan. h correct optr estimates. eg TABLE_STATS hint for missing or stale stats.  #add#,direct nfs: c/w inst guide for lin
#S7: ~ conventional INSERT: db reuses free space in tab & maintains referential integrity constraints. so it must always log.
 ~ DP insert(DPI): appends data after HWM. data wren directly into df, bypassing bfc. free space in existing data !reused, referential integrity constraints ignored. ensures atomicity of txn.  
 ~ t42a: append hints to activate serial DPI.  ~ in serial DPI 1 ps inserts data beyond curr HWM of tab seg. COMMIT -> HWM updd.      ~ 1 ps for serial DPI maintain ind at end of DPI on tabs.          
 ~ lks tab X during DPI.  ~ t42b: in DPI w/o logging, inserts data w/o redo or undo logging. logs small #-bl range invalidation redo records(irr) + periodically upds cf w/ most recent direct wr info (ip: disable this). during reco, irr mark range of bls as logically 
   corrupt.  expt,local/pt/ptExpt.txt,1: CTAS gens more redo, undo than DPI.                   #S86,S26: >1 RLF|cf + 1 unusable RLF|cf ∴ inst !| fails. RLF by expt.
#!SE: persistent m/m(PMEM) flstore(PMF): S86: can store df,RLF,cf. query: PMEM--!bfc-->. direct byte acs to bls in PMEM. df ∈ PMEM ∴ PMEM bls mapped to bfc. DML modifications, rd consistency, faster acs for hot dbl ∴ PMEM-->bfc.  
 S84: inst started ∴ PMF visible. for perf OR: store RLF in DAX-aware EXT4/XFS. io to PMEM w/ m/m copy (!traditional os calls). t24c,ip = ('$mntPt','$bkgFl'). $bkgFl ∈ ext4/xfs(-o dax) ~t24d: crt,(un)mount f($mntPt,$bkgFl),drop,vw PMF.
%%%%%%%%%%%%%% bkp(tuning)
#S25,RMAN tuning: ~ ∀ channel:  rd phase: disk -> i/p bfrs.    copy phase: i/p bfrs -> o/p bfrs + additional processing on bls.   wr phase: o/p bfrs -> storage media.
 ~ rd phase   P: level of multiplexing(lm) = #-i/p fls simultaneously rd & then wtn into same bkp piece = min(max open fls param, #-fls/set param, #-fls-rd/channel)        l: lm= LEAST(MAXOPENFILES,FILESPERSET,#-fls read ∀ channel). 
 ~ copy phase   P, validation: check for corruption,!cpu-intensive.           P, binary cmprsn: cpu-intensive.  expt: very slow.      P, encrn: can be cpu-intensive.
 ~#skp# wr phase for sbt:       P: set tape io slaves ip. RMAN allocates tape bfrs(tpb) from large pool.  l,ip: backup_tape_io_slaves=true
   P: sync|async tape io:    a) channel ps(cp) wrs bls to tpb.        b) cp mesgs tape slave ps(tsp) to process tpb. cp|tsp executes media mgr code that processes tpb + internalizes it for further processing & storage by media mgr. 
    c) as tsp wrs cp rds data from dfs to tpbs.     d) media mgr code mesgs cp|tsp if completed wring.    e) tsp requests new tpb | cp initiates a new task.
  P: bkp perf to tape =f(nw throughput, native transfer rate, media mgr compression(mmc)). use mmc if efficient, !RMAN binary compression(rbc). use rbc to bkp over nw to media mgr. don't use both mmc & rbc.
    Q: when bfr of fixed-speed & streaming tape drive empties, quickly moving tape overshoots. drive rewinds tape to locate pt where it stopped wring. so use multiple speed tape drive. 
    Q,nt66a: phy tape bl sz = amount of data wren by media mgmt s/w to tape in 1 wr = f(media mgmt s/w). in general, larger tape bl sz ∴ faster bkp. 
 ~ vw: bkp (a)sync io, ses long ops. l:V$BACKUP_SYNC_IO,V$BACKUP_ASYNC_IO.      ~ bkp validation ∴ rd|wr bottlenecks
#1326686.1:_file_sz_increase_increment, for exadata rman disk bkp.
%%%%%%%%%%%%%% ora storage(tuning)
# nt15a, orion o/p: cmd; small|large io sz; wr%; duration ∀ data pt; max|min (large MBPS|small IOPS|small latency) at #-small|#-large outstanding ios.
# nt15b, fio: f(predictable random io patterns(a), reduce gettimeofday calls(b), #- in-flight ios(c), total io sz ∀ thread(d), rd %ge in workload(e))   #add#: OCI BV perf.
#S9: P: stripe depth = sz of stripe.    ~ small bl-sz(ip): for small rows with many random acs. large bl-sz(ip): bl hdr space overhead is low; read more rows in 1 io; increase contention on ind leaf bl in OLTP.
%%%%%%%%%%%%%% ora nw(tuning)
#~ S23, ora net(ON): places data in session data unit(SDU) -> nw transfer it.
 ~ S15: P: nt43a, ON sends each SDU when filled, flushed, or when appln tries to rd data. SDU sz limit does !apply to bulk data transfers (eg secureFiles LOB, redo transport svc). 
  P:nt43b: send|recv bfr sz >= nw bw * round trip time(use ping). supported for TCP, TCPS & SDPs. S24: trcasst ∴ mesg sz. l: trcasst -od -s Output  P: sar ∴ nw stats (s1). P: SDP: most of mesgg burden on NIC (!cpu).
  P,nt43d: inbound con timeout for clnt in listener.ora(tl,to complete its con req to lsnr after nw con) & svr sqlnet.ora(ts,to con to db svr & provide authn info). tl<ts. logged in listener.log & sqlnet.log. P:demilitarized zone(DMZ)
  P,nt43e: lsnr queue sz = #-crnt con reqs that lsnr can accept on a TCP/IP or IPC listening endpt (protocol addr).  # nt43g, sqlplus easy con, cmd line args of sql/rman fl, rollback & exit on sql err.     ~ nt43c: cfg sqldev web.
#t18a, db resident con pool(DRCP): ~1st req recvd from clnt -> P, SSA: dispatcher places req on common queue -> available SSP picks up req -> dispatcher manages communication bet clnt & SSP.
   DRCP,+S31: clnt cons to con broker ps(Nnnn) -> con becomes active ->  broker hands off con to compatible pooled svr ps(lnnn,psp) -> psp performs nw communication directly on clnt con & processes reqs -> req served. -> clnt 
   releases psp into pool -> con returned to broker for monitoring. !psp available ∴ broker crts one. pool reached max sz ∴ clnt req ∈ wait queue until psp available. expt: sqlplus con inactive ∴ psp allocated
 ~ pkg: start,stop,cfg pool.   ~ vw: pool con|cfg info.     ~ ses m/m is allocated from PGA in DRCP.   ~ #-clnt cons = c, pool size = ps. m/m used for dedicated|SSP|DRCP = (c|c|ps)*mses + (c|#-SSP|ps*)msvr) + | |c*35KB.
 ~ ip: use dedicated optimization(#-cons to broker < max pool sz ∴ DRCP behaves like dedicated svr), min/max auth svrs (auth user cons). vw: auth svr stats.
 ~ #skip#if m/m reqd ∀ ses = mses, m/m requd ∀ svr ps = msvr, pool sz = ps,  #-SSPs = ss, #-clnt cons = c, then m/m used = c*(mses+msvr)(dediacted), = c*mses+ss*msvr (shared svr), = ps*(mses+msvr)+c*35KB(DRCP).
 ~t18b,dispatcher vw: dispatcher, cfg, stats.   ~t18c,vw: msg queue stats in SSA.  ~ #!fndIn12.2#S50, SSA: not all user info stored in UGA. so shared svr often bound to user ses.    #add# DRIVING_SITE hints for db link
%%%%%%%%%%%%%% arch(tuning)
#S18: PCTFREE = min %-dbl reserved as free space for upds to existing rows. 
#S31:  ~ for threaded execn, dbw, pmon, psp, & vktm run as os ps + bpsO run as os threads.
 ~P,ref+S26: when an inst starts, lsnr regn ps (lreg) registers info about inst, svcs, handlers, endpt with lsnr. lsnr !running ∴ lreg periodically attempts to contact it.  P: lk ps(lckn) handles reqs for rsrcs except dbls (eg lc & row cc reqs).    
 ~P: S26: ckpt signals dbwn to wr bls to disk. on completion ckpt upds cf & df hdrs with ckpt info (eg ckpt pos, SCN, loc in RLF to begin reco). ref: ckpt checks ∀ 3 sec to see whether amount of m/m > pga_aggregate_limit ip, + if so, takes action.
  P: cleanup main ps(clmn) periodically cleans up dead ps, killed ses|txn|nw-con, idle ses, detached txn|nw-con that have exceeded their idle timeout. cleanup slave ps(clnn).  P: pmon periodically scans for abnormally-died ps -> pmon coordinates cleanup w/ clmn & clnn.
  P: ps mgr (pman) monitors, spawns, stops disp & SSP, con broker & pooled svr pss for db resident con pool, job queue ps, restartable bg ps.  P: diag (dia0) detects & resolves hangs & deadlocks.  P: gen task execn ps (gen0) performs reqd tasks including SQL & DML.
  P: m/m mgr(mman) reszs m/m comps on inst.  P: ps spawner(psp0) spawns bps after inst startup.   P: virtual keeper of time (vktm) publishes 2 sets of time: wall clock time using secs interval + higher resolution time (!wall clock time) for interval measurements. 
 ~ db: P: ip #-dbwr, auto adjusted f(#-cpu, #-processor gr). dbw0-9,dbwa-z,bw36-99.  l: db_wrr_processes.  P: disk & tape io slave ps (ip,innn) spawned on behalf of dbwr, lgwr(expt: hip=2*dbwr-ip), or an RMAN bkp ses. l,ip:dbwr_io_slaves,_lgwr_io_slaves.
   P: S26: lgwr wrs sequentially all redo entries copied into bfr since last wr when  Q: user commits  Q: redo log switch  Q: >3 secs of last lgwr wr  Q: redo log bfr is 1/3rd full or ⊃s 1MB data. 
    Q: dbwn discovers !wrn redo $rec ( f($bfr dbwn wring)) -> it signals lgwr to wr $rec -> lgwr completes -> dbwn wrs $bfr.  lgwr continues wring to acsible fls in a grp.   P: on >1CPU sys, lgwr crts log wrr workers(lgnn).
   P, S26: smon performs sys-level cleanup including:   Q: inst reco, if needed, at inst startup. Q: rec terminated txns (skipped during inst rec due to fl-read or tbs offline errors), when tbs or fl is online.    
    Q: cleaning up unused tmp segs (eg, tmp allocated exts of failed ind crtn). ref: Q: crts & manages tmp tbs metadata.  Q: maintains undo tbs by onlining, offlining, & shrinking USs f(undo usage). Q: cleans transient & incst DD.
   smon is resilient to internal & ext errors raised during bg activities. smon checks regularly whether it is needed. psO calls smon if they need it.    P: resetlogs ps(rlnn) are spawned to clear RLFs + are terminated after RLFs are cleared & ses does! persist.
  P: data pump master(dmnn) handles all clnt interactions & communication, establishes all job contexts, coordinates all workers.  P:data pump worker(dwnn) performs tasks assigned by master (eg loading & unloading of metadata & data).
  P: small fraction of SGA is allocated at inst startup. SGA allocator(sann) allocates rest of SGA in small chunks.  P: job coordinator ps (cjq0) & job queue slave ps (jnnn).  
  P: space mgmt coordinator|slave (smco|wnnn): smco(eg): proactive space allocation & reclamation. wnnn: preallocates space in LMT & securefiles segs f(space usage growth analysis), reclaims space from dropped segs.
  P: ora fl svr bg ps (ofsd)|..ps thread(ofnn): ofsd listens for new fl sys reqs, mgmt (eg (u)mount, export) & io reqs, ofnn execs them.  P: local recr ps (reco) attempts to con to rem dbs at intervals + auto commit/rollback of local portion of pending distributed txns.
  P: ⊃r ps for threads(unnn)= {smon,cjq0, ...}, n=f(active db ps), 1 unnn/NUMA-node
#S32: disk wr of commited dirty bfr ->|<- commit. txn committed ∴   ~commit SCN gend. internal txn tab f(undo tbs) ⊃ { txn has committed, txn SCN }.  ~ lgwr wrs remaining log bfr entries & txn SCN to RLF. this atomic event is commit.  ~releases lks on rows & tabs.
 ~ -s savepts.  ~ !ses modifying committed dirty bfr ∴ db (!later SELECT) removes lk-related txn info from bls. this cleanout (so, a query) gens redo -> wrs bls at next ckpt.   ~ marks txn complete.
#S14,rd consistency: ~ delayed bl cleanout: commit -> modified bl !necessarily updd w/ commit SCN  -> done when bl rd or updd. db rolls back txn tab to get commit SCN.    #t25c,ip: (batch logging & !wt (to flush redo to RLF)) for commit; disable logging.  
# t12: tab=f(in-db archiving) ∴ hidden col(a) crtd in tab.  >set a = active|archived f(row)  >ses param to control visibility.
##add# Quality of Service Management User's Guide, skipped for now as enabling QoS in db needs EM
%%%%%%%%%%%%%% dev(tuning)
# sqlplus auto trace ∴ execn plan + stats. fetches(!display) query data from server.   l: SET AUTOTRACE TRACEONLY;      # #add# orasrp tool for sql tracing    #set def off ∴ & allowed in sql 
#~ t22: plsql native compilation, plsql optr level.  1556284.1: plsql native cc ∈ tmpfs (/dev/shm) (hs: w/ MPMT)
#~ t20, ctr: n bls reserved (rs) to store all rows w/ same ctr key or hash val. S12:all rows for ctr key val > rs ∴ chained bls. ctr ind pts to beginning of chain. ctr key val & rows ∈ each chained bl. S33:tabs in hash ctr need more space ∴ overflow bls reqd.
# ~t6c: WITH in SELECT: materialize, inline hints.     ~S68: queries w/ same query block(qb) >1 times (sqb) ∴ db can store qb results in tmp tabs in PGA. less PGA ∴ tmp segs used. 
   sqb|sort: a) (cr closed | row src !active) ∴  m/m & tmp segs released.    b) data can !| move b/w m/m & tmp segs.  t6g: FTS emp -> LOAD AS SELECT (cr duration m/m) (tmp1)    a. FTS tmp1 -> vw    a. FTS tmp1 -> vw   a-> UNION-ALL -> tmp tab transformation
# t46a, priv tmp tab(PTT): ∈ m/m, tmp tbs. commit -> data (& defn) deld -> ses end -> defn deld.           #t47a: +,-hints of sql f(sqlid)
# t15h, scalable seq: P: 6 digit offset(do) = ((inst id % 100) + 100) + (ses id % 1000)). P,extend: seq val = x(dft 6) do || y digit(<=max val).     P,noextend,+expt: n digit max val ∴ 6 do || n-6 digit seq#.    P, OR: do! specify order.
##skip#,t15h, scalable seq: P, extend: seq val = x (dft 6= ((inst id % 100) + 100) + (ses id % 1000)) digit offset || y digit(<=max val).     P, noextend,+expt: n digit max val ∴ 6 digit offset || n-6 digit seq#.  
~~~~~~~~~~
sql tuning (full) 
#S57: ~ better throughput ∴ using lesser rsrcs to process all rows.     
~S62: P: sql -> syntax check(a) -> semantic check(b) ->  shared pool check(c) --------> optn(d) -> row src generation(e) -> execn(f)
                 |<---------------------parsing----------------------|------>| hard parse                                          ^
                                                                     |--------------------------soft parse-------------------------|
        Q: parsing: separating pieces of sql into a data structure to be processed by routineO. appln issues sql ∴ it makes parse call. parse call opens or crts cr (ie, handle for ses-specific priv sql area).
         R,b: eg nonexistent tab,col.   R,c: stmt hash val is sql id. DDL is always hard parsed.   R,d: db never optimizes DDL unless DML(eg subquery) ∈ it.   R,e: produces iterative execn plan ie a binary prog.
      P,#!fnd19#: vw lists all hints. l:V$SQL_HINT
#S67:
~ optn(d): parser ----------> query transformer --------> estimator --------> plan generator --------> row src generator
                                   dictionary ---stats------>|<-------------------| 
  > estimator: sly = %ge of rows in row set that query selects. cardinality = estimated #-rows returned by each op in execn plan. MOS: cardinality hints /*+ CARDINALITY (t_func 25) */. cost.
~ auto reoptn: P: optr may enable monitoring for stats feedback(sf) for: tabs w/o stats, >1 conjunctive or disjunctive filter preds on tab, preds w/ complex operators for which optr can! accurately compute sly estimates. 1st execn -> estimated & actual(ac) cardinalities 
  differ a lot ∴ optr stores ac for later use -> optr crts SPD -> disables monitoring for sf.  ~t15e: plan from cr cc gives estimated & actual cardinalities. hint usage rep: P: unresolved hint ∴ query bl !∈ "query bl name / obj alias (id by op id)" section of plan o/p.
  ~ #!fnd19#S68: query stats (!tab) f(type of aggrn, accuracy of stats, type of query(!eg WHERE -> aggr), ! query ∈ txn). VW_SQT_* vw ∈ plan.
#S68:
~ P,t15n: OR expansion: OR -> UNION ALL (eg to use ind).  P: vw merging: vw -> join. P: prd pushing: from ⊃g query bl into vw query bl.  P: subquery unnesting -> join. 
  P,join factorization: t1,t2,t3 AP/FP UNION ALL t1,t2,t4 AP/FP (t2xt3(c3),t2xt4(c4)) -> t1 JOIN (t2,t3 AP/FP UNION ALL t2,t4 AP/FP)vw.  AP:t1.c1=t2.c1(+) ∴ t2 JOIN (..)vw
#S38:
~ below (HWM|low HWM): (formatted & unformatted|formatted) bls. FTS: db rds all bls upto low HWM -> rds seg btm to know formatted & safe to rd bls bet HWM & low HWM. S108: bls bet HWM & low HWM are full ∴  HWM->right + low HWM->old HWM.
~ bdft, tab is organized as heap, ie db places rows where they fit best.  ~ ind !used: P: char-col=1 ∴ TO_NUMBER(char-col)=1.  P: COUNT(*) + null ∈ indd col + completely(hs:>=1 col?) null key can! ∈ B-tree ind.  ~#!fnd19# db auto (! when cc set for tab) cc|!cc FTS bls. 
~ t37a: batched tab acs by ind rowid ∴ get few rowids from ind -> acs rows in bl order to improve ctring factor. 
#S30: ~join method: driving (outer) & driven-to (inner) row src(rs).  P: NL: ∀ outer row matching 1-tab prds, all inner rows matching join prd retrieved. process >1 phy io reqs w/ 1 vector(ie array) io.
  P: HJ: Q: a. build hash tab(ht) = f(smaller rs, join key, deterministic hash fn) in m/m. -> b. scan larger rs -> c. probe ht to find joining rows. ht in PGA ∴ can access rows w/o latch ∴ !repeated latch & !bl rds in bfc. 
   Q: ht !fit in PGA: (a)largest ht prtn ∈ disk. (c) ht slot# on disk ∴ stores this row in tmp tbs w/ prtning scheme of smaller rs.     Q: hints to use HJ. l: /*+ USE_HASH(l h) */  Q: #add# expt: HJ bfrd ∴ tmp seg used.
   Q: hash-fn(join key) = slot# in hash tab array. entire row of smaller rs ∈ slot. hash collision(ie same slot# of >1 join keys) ∴ puts records for all join keys in same slot, using linked list. 
  P: sort merge join(SMJ): choose SMJ over HJ for large rss if !equijoin(eg inequality), sort reqd by opO. sort rs#1|2 |! f(ind). SMJ (unlike NL) like HJ in PGA...bfc. less m/m ∴ rd once(HJ >once) each rs from disk. 
   a. IFS -> tab acs by ind rowid. a. FTS -> sort join. a -> merge join. ind on join col, select !join col.  hints. l: /*+ USE_MERGE(d e) */.                   P: bfr sort ∴ copying scanned bls from SGA to PGA + (hs) sorting.
 ~ P: semi join(IN,EXISTS)|antijoin(!IN,!EXISTS): stops processing 2nd data set at 1st match. 
    FROM dept d WHERE did NOT IN (SELECT did FROM emp e). hs: [NOT] IN (NULL) fails. a: FTS d -> IRS ied (AP: did=did) -> NL ANTI SNA. a -> FTS e (FP: did IS NULL) -> FILTER (FP: IS NULL)   ANTI (S)NA ∴ (single) null-aware antijoin.
 ~ P, bloom filter(BF): val !∈ set. Q: useful when R: m/m for {filter/data in dataset} is small  R: most data expected to fail membership test.  Q: t15i,vw: rows filtered out & tested by active BF. 
    Q: fi is hash fn. f1(17)=5, f2(17)=3, f3(17)=5 ∴ e{0,0,1,0,1,0,0,0}. fi(22) ∴ e{1,0,1,0,1,0,0,0}. so e3=1 + e5=1 !∴ 17 ∈ e; e3=0 or e5=0 ∴ 17 !∈ e.     Q,t15j: a. FTS dim -> BF crt(on HJ col). a. FTS fact -> BF use. a -> HJ.
 ~ P,band join: FROM e1,e2, e1.s ∈ [e2.s-100, e2.s+100];   FTS e1 -> SJ -> FTS e2 -> SJ(a) -> MJ   a: acs(int-fn(e1.s)>=e2.s-100) fltr((e1.s<=e2.s+100 AND int-fn(e1.s)>=e2.s-100)), e2 sort DESC. (a) fails ∴ e2 scan stops.
 ~#skp# P,band join: FROM e1,e2, e1.s ∈ [e2.s-100, e2.s+100];   FTS e1 -> SJ -> FTS e2 -> SJ(a) -> fltr(b) -> MJ   a: acs(int-fn(e1.s)>=e2.s-100) fltr((int-fn(e1.s)>=e2.s-100))  b: fltr((e1.s<=e2.s+100)    (a) fails ∴ e2 scan stops.
#S71: ~ GTT: ∃ tab-level pref for shared or ses-specific stats. sesA: gather & use ses stats. sesB: use shared stats. stats vw ∴ ses + shared stats.  
 ~ gathers tab & ind stats auto during CTAS, insert into &tab ... select w/ DPI (if t16a). !addl tab scan.  t15l: hints to [!]gather stats. #add# _optimizer_gather_stats_on_load=false 
 ~ ∃ cardinality misestimate ∴ crts SPD. during sql compilation, examines corresponding query for missing col gr(cg1) + if t16b  ∴ next DBMS_STATS call crts cg1.
   insufficient stats corresponding to SPD ∴ uses dyn stats. SPD is defined on query expr(eg query minus select list). V$SQL.is_reoptimizable.  ∃ extn -> state of SPD = usable -> SQL executed -> state of SPD = superseded. 
 ~ t15o: vw: SPD, SPD obj, extn. S53,SPD proc: flush from m/m to sysaux tbs, drop.
# S1: ~ a. DBMS_STATS ($tab,method_optr = dft) -> b. user queries $tab -> c. DBMS_STATS, now queries SYS.COL_USAGE$ to get cols needing hgs f(previous query workload) -> b -> c.  
 ~ in freq & hybrid hgs, endpt#(ep) = cumulative freq of all vals in curr & prev bkts. endpt val(ev) = max(vals in bkt).  hs,t7e: endpt ∴ bkt.          ~hs: hg in asc order of vals.
 ~ popular val is ev of >1 bkts. for fh, epd = endpt# of curr bkt - endpt# of prev bkt. ev for which, epd>1 is popular val. cardinality of popular val = (#-rows in tab) * ( #-endpts spanned by this val / total #-endpts). 
   cardinality of !popular val = (#-rows in tab)*density. density = f(#-bkts, NDV) = [0,1]. density~=1 ∴ optr expects many rows to return by prd on this col.   ~sometimes to reduce total #-bkts, optr compresses >1 bkts (hs: w/ popular val) into 1 bkt.  
 ~ in a fh, each distinct col val corresponds to 1 bkt, distinct val:bkt=(>1:1).  top fh is a fh that ignores !popular statistically insignificant vals. db crts fh when NDV <= #-bkts (nb).
 ~ db crts top fh when NDV > nb +  %ge of rows occupied by top nb freq vals >= (1-(1/nb))*100 (hs: left rows < avg #-rows/bkt ) + gather stats w/ auto sample sz. ~ hh distrs vals so that no val occupies >1 bkt + stores evrc.  evrc = #-times ev is repeated.  
 ~ db crts hh when NDV > nb + criteria for top fh do !apply + gather stats w/ auto sample sz.   ~vw: tab hg, tab & col stats.         l: DBA_TAB_STATISTICS.stattype_locked, DBMS_STATS pplts DBA_TAB_HISTOGRAMS. DBA_TAB_COL_STATISTICS
# S55: ~> S102: bind peeking: optr notes bind val during hard parse. adaptive cr sharing(ACS) != f(cr sharing ip). cr is bind-sensitive(bs) if ∃ bind peeking + ∃ hg on col having bind val(sctd) + bind is used in range prd.  
  dept:(child#,execns,bfr-gets,bs,bind-aware(ba),shareable(sh)): 9:(0,1,56,Y,N,Y,ind), 10:(0,2,1010,Y,N,Y,ind), 10:(0,2,1010,Y,N,N,ind),(1,1,1522,Y,Y,Y,FTS)^, 9:(0,2,1010,Y,N,N,ind),(1,1,1522,Y,Y,Y,FTS),(2,1,7,Y,Y,Y,ind)^.  
  for child#0, ba=N ∴ age out of shared SQL area.  ^: ∃ hard parse + gens new plan(pln1) & new cr. pln1 = plan used by an existing cr ∴ merges these 2 crs. 
  t44a,vw: hg(execn count =f(sqlid)), sly ranges ∀ predicate f(bind var) if sly was used to check ACS, cumulative execn stats used by ACS.    l: V$SQL ⊃ {is_bind_sensitive,is_bind_aware,is_shareable},Y/N
#S38: ~ ind skip scan: ndvs in leading cols of ind determines #-logical subinds.  ~ P,ind full scan: eliminates sort op. does 1 bl rd.    P,ind fast full scan (FFS): >1 bl rds of ind bls in unsorted order, as they exist on disk.    
 ~ ctr scan: retrieve all rows having same ctr key from tab stored in indexed ctr.  ~hash scan: obtains hash val(hv) by applying hash fn to ctr key specified by stmt -> scans dbls ⊃g rows w/ hv. 
%%%%%%%%%%%%%% expt(tuning)
# t1(f1,f2) -> t1f1(pk,f1) + t1f2(pk,f2) ∴ query runs faster for f1=v1. mvw t1f1.    #crt ind on cols ∴ hash grp by $cols faster.
%%%%%%%%%%%%%% lin(tuning)
#~ lt1a: show (multipath topology, blk devs(lsblk), blk dev attrs(blkid)). lsblk ∴ SSD.   ~lt1b: HBA cons host sys to storage devs. HBA is fibre channel ifc card.  ~lt1c: queue depth(qd) = #-||-io-ops on LUN <= storage ctrlr’s max queue depth. iostat ∴ avg queue length.
#~numa: P,lt2a: >1 processor req same data ∴ moves data bet m/m banks ∴ slow.   P,lt2b: auto numa bal moves ( tasks (thread or ps) closer to m/m they are acsg | appln data to m/m closer to tasks that ref it ).
  P,lt2c: show (available nodes, (m/m stats for ps|thread)/(numa node), topology). P,lt2d: pin a db to a numa node w/ cgrp. ip: cgrp. get cgrp of a pst. expt: enable numa ip ∴ pss distributed across numa nodes ∴ hs: disable numa ip.
  P,lt2j: limit m/m usage of prog w/ cgrp.   P,lt2e,taskset: set processor affinity of a pst.  
  P: namespace local/l/lin/ns.sh: br0(nsh, veth)<-->nsc > assign ip,rt to nsc > bind mount nsRoot:nsMntPt(nsm), proc,sys,dev,pts,run:$nsm/ > ns(unshare (mount,uts(hostname,domainname),ipc(sem set, shm seg),pid, root=$nsm)). !privd unshare. set hostname. pivot_root.
  P: namespace local/l/lin/ns1|2.sh. ns1: br0(nsh, veth)<-->nsc > assign ip,rt to nsc > bind mount nsRoot to nsMntPt > ns(unshare (mount,uts(hostname,domainname),ipc(sem set, shm seg),pid)). !privd unshare. set hostname.  ns2: bind mount proc,sys,dev,pts,run >pivot_root 
  P: #add# lsns -p $pid, nsenter --pid=/proc/$pid/ns/pid <full unshare cmd> /bin/bash;  or  ip netns exec des <full unshare cmd> /bin/bash;  nsenter -t $tgtPsId -a --root=$nsm;
 ~ lt2k: P,bridge: supports STP, VLAN filter, mcast snooping. P: bond!=team. P,VLAN: sw cond to host should handle VLAN tags(eg by setting sw port to trunk mode).  P,MACVLAN: >1 ifcs w/ diff L2 ie mac <--> eth0. macvlan types: bridge, passthru (VM -- direct --> eth1),...
   P,veth: namespace.  P,VXLAN: 24-bit VXLAN nw id(VNI) allows up to 2^24 VLANs. VXLAN encapsulates L2 frames w/ VXLAN hdr into UDP-IP pkt.   P,MACVTAP: char dev /dev/tapX crtd for direct use by KVM.   P: expt mcast.
 ~ perf thread & core: expt: 2 psts run slow|fast on 2 threads in same|diff cores. hs: do disable MT in bios.
 ~ huge page(hp), os admin ref > chp hugepages:  os kernel must continually upd its pg tab w/ pg lifecycle (dirty, free, mapped to a ps etc) ∀ 4 KB pg ∈ SGA. 
   w/ hp: P: os pg tab (virt m/m to phy m/m mapping) is smaller. P: kernel monitors lifecycle of fewer pgs.  P: pgs are !swapped out.  P: contiguous pgs are preallocated + can be used only for sys V shared m/m (eg SGA).  P: large pg sz ∴ less bookkeeping work for kernel. 
   lt2f: cfg hp in os & db.  translation lookaside bfr(TLB) = cc of page tab.  lt2g: TLB sz.     lt2i: 1G hp, don't use.  transparent|std hps m/m allocated (dynamically during runtime | at startup). lt2h,transparent hp: check if enabled, disable.             
#lt4a: set max java heap sz.    #lt5a: iostat, sar(nw stat)     #~ lt6a: /proc/cpuinfo, HPC processors, dmidecode, inxi(also weather).  ~lt6b: disable cpu.    
#~ lt3a: flush cc, show m/m utilzn, show pages of $fl in m/m, DIO w/ dd.  ~pmap: show m/m map of a ps. local/pt/pga.sql. #add#smaps    #lnt3b: m/m, cpu utiln of psts.       #lnt3c: pstree, forest(ps).     #lnt3d: pid of child ps.      
%%%%%%%%%%%%%% lin(non-tuning)
#~ lnt1a: list HBA WWN#, speed, scanning added fc luns.     #~lnt2a: add swap.    #~lnt3a: sysresv: show, remove ipc rsrcs. ipcs, ipcrm(kill ps), ipcmk(make), (expt) details of segs allocated/inst,.  #add#153961.1
#~ lnt4a: nw bonding. ~lnt4b: netmask to cidr,ipcalc.  #print: /data/.hs/chintangsha/linBin/prn.    # ~lnt8a: ghostscript ( (text,pdf(pswd) -> pdf(pswd)), merge, split pdf).  ~lnt8b: text to html.  #lnt9a: NFS setup, mount OCI FSS, obj store to onP -> expdp.
# lnt10b,udev: reload rules, debug logging.  #lnt10c,sys log: journalctl(svc,ps,live, deletes > 7 days), show, boot,diff locs, selinux.  #lnt10d: boot into multi-user or graphical mode.  
# lnt10e,selinux: see status, see ctx of fl, allow from audit log, get selinux cmds to fix error, auto relabel at next boot. #add# auditd
# lnt11a: strace ps, strings, to see fls linked w/ executable.  #consolidate: /sys/firmware/efi ∴ EFI used   #lnt10a,systemctl svc: list, list dependencies.
# ssh:  ~lnt29a: ssh w/ keepalive, host key.  ~lnt29b, issue: perf(DNS, MTU), user equiv. ~lnt29c: expect script for ssh.  ~lnt29d,pem: gen priv, pub key, fingerprint. pem/rsa rsa pub key.  ~lnt29e: (reverse)port fwdg.  ~lnt29p: ssh options for OCI console acs  
  ~lnt29f: w/ http proxy, jmp svr(A--kB,kC-->B--kC-->C), add priv key to auth agent. cfgFl={alias, ip, usr, priv key fl}.  ~lnt29g: putty key <-> openssh priv key.  ~lnt29k: allow usr  ~lnt29n: cmprs  ~lnt29o: ssh con sharing.  ~#add# mosh, sshfs  ~lnt29q: webssh
# lnt29l, path max transmission unit(MTU) discovery (PMTUD): ~ src(mtus) --> rtr(mtur-egress<mtus, drops pkt)  -- ICMP type 3 code 4 mesg (fragn needed + don't frag(DF) set) + max pkt sz(sz1) allowed through its egress ifc 
  --> src sets pkt sz < sz1. ICMP types & codes. ~ rtr should honor PMTUD. ~ pkt={src, dest ip, payload of data}.  ~ during initial 3-way handshake bet 2 hosts, each sends max seg sz (MSS) (<MTU) for how large its payload can be. tcpdump ∴ MSS.
  ~ ping f(DF(!even local), pktSz, iface), tcpdump ∴ frag#, DF flag  ~ rt f(MSS)        # lnt29m: kernel param desc.  # lnt11b: script(spool), scriptreplay.  #lnt29h: shell timeout.     #lnt29i: last logins, max #-logins/usr.   
# lnt29j, watch: exec prog periodically, showing o/p fullscreen.  #lnt12a,b: cfg vnc,x2go.  # lnt13a: ntp clnt cfg.  #lnt14a: crontab, remind cfg, notify.  #lnt16a: boot into single user mode w/o pswd. #lnt16b,OCI: mesg -> serial console.
# lnt15a: change host name(hostnamectl). netstat.ss. bw usage per ps. nmap: open/filtered(by fw)/closed(!appln listening) ports & svc running in remote host, ips in nw, nmap w/ traceroute, detect ip fwdg (hope: traceroute !detect hops w/ ip fwdg). 
  nc: bw available bet 2 svrs w/ netcat.    #add# virt rtg & fwdg (VRF): https://www.kernel.org/doc/Documentation/networking/vrf.txt
# lnt15b: ethtool: show speed,driver of eth0. trickle: limit bw of ps/eth0. lspci -v ∴ driver used.  #lnt15c: +,-, get (local) rt; traceroute f(port), mtr (ASN,>1path rtg), netcat.  #lnt15d: nw udev rules.  #mount -o loop,ro  $iso /cdrom   
# run.sh: on boot svc  # mailx: dtb/hk/monitor/mLog.sh     #lnt17a, sudo: w/o pswd, preserve env, env var ∴ calling user.
# lnt18a, logical vol: crt, extend, shrink; mdadm raid.   #lnt18b, btrfs: mkfs(f(raid level), show, usage, resz, add/remove dev, balance, scrub(rd data & metadata bls, verify checksums -> auto repair crpted bls), crptn, check, cmprs, 
  !COW, wipe, snapshot & incr bkp (to remote svr),  disk usage of snapshots, list subvols, show details of subvol, defrag (breaks ref-links), label, rec ⊃ bl, res.  filefrag. kernel 5.10 improved fsync.   mos: 1625097.1 
  #add# db bkp COW: https://btrfs.wiki.kernel.org/index.php/Incremental_Backup  reflink: https://btrfs.wiki.kernel.org/index.php/UseCases. cf lvm: https://blog.pythian.com/btrfs-performance-compared-lvmext4-regards-database-workloads/
  #add# stratis+XFS: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_file_systems/managing-layered-local-storage-with-stratis_managing-file-systems
# lnt18i: lvm snapshot.   #lnt18j, xfs: repair, label.  #lnt18h,bl cc: dmsetup, bcache(unstable).  #lnt18c: bkp & res hdd.   #lnt18d: kvm or native -> xen. gen|list intramfs.   #lnt18e: rsync #add# fpsync (||)  #lnt18g: drbd.  
# shred -uz $fl ∴ overwrite $fl w/ zeros + rm.  # lnt18f: scp w/ cmprsn. script: speed of copy.   # lnt21a: xhost/xauth + display.    #proxy server: squid, dbt/squid/squid.conf.   #lnt19a: list PCI,USB devs(driver,path); get/set hdd params; get scsi id of hdd.  
# lnt20a: ip cmd: set/add ip, up/down link, show up links, show neighbour, know ip is dynamic/static, crt/del veth, rt, bonding, bridge. disable ipv6 in local/crtDb.sql.
   tcpdump, whois, nw perf(iperf3 o/p bw, qperf latency) /sys/class/net/$if/, ip addr from /proc/net/fib_trie.   #add# ip xfrm: ipec,cmprs
# lnt22b,rpm: list contents, new root, reinstall, extract fls, src.rpm -> rpm, install old pkg, replace pkg, query fmt (sz, name, vrsn).  createrepo.  
# lnt22a,dnf: dnf cfg fl, provides, gr {list | info | install}, installroot, disable|enable repo, list repo|pkg, fc/el upgrd, list dependent rpms, protected_multilib=false, remove pkgs !longer reqd by user-installed pkgs, vars.  
# samba cfg.#add# for el7.     #lnt24a: lin to join win domain(realm).  #lnt24b: mount win share to lin.  #lnt25a: lin !booting for selinux ∴ upd grub menu.  #lnt26a: iscsi cfg.  ##add# kubernetes: https://blog.codeship.com/getting-started-with-kubernetes     
# losetup --show -f -P fileName;  # ~lnt27a, lxc: env setup, creation, cloning, supp by ora, info (alt lxc path). ~lnt27b: boot disk migrn w/ rsync (install grub).    # grub: ~ lnt35a: change boot kernel, gen new grub2.cfg.    
# lnt37a, kvm: disk(virtio,virtio-scsi(cloud)), nw(tap,virtio); pcipassthrough; nested; mount qcow2; console(changing cd runtime, !monitor, enable serial console), win (mouse), usb, sound,time, reset pswd in fc cloud image, uefi boot, 
  snapshot(list,crt,apply,del,rec crptn), hot plug cpu, vm detection(stop).  sparc emulation on x86: https://www.stromasys.com/solutions/charon-ssp/    # lnt36: list/wipe signature from dev.
#~ nt67a,nt67d: cfg openldap,tnsmanager for tns.  ~nt67b: os authn w/ openldap. ~nt67c: restrict users to login to lin.         ~lnt23a: set passwd !interactive. remove restrictions.  ~lsof -p $pid
# iptables: ~lnt30a, list. nat: prerouting(DNAT): f(src ip, bef dst ip|port, time of day, week day, time zone, src macAddr, str) -> aft dst ip|port. 
  postrouting: P,MASQUERADE: f(dst ip, ifc) P,SNAT: f(dst ip, bef src ip, str) -> aft src ip,owner. log,trace. append,ins,del. list|flush chain. fwd.  ~lnt30b: rules in cfg fl.  
# nftables, lnt30c: P: list all rules(∈ ruleset{tab, chain, rule}, chain, tab(+handle(hs,line#)), firewalld).
  P,script: var, flush rules, add tab, add chain f(tab, type(eg filter,nat), hook(eg i/p,(pre|post)rtg), priority[, policy(eg drop)]), add/insert/replace rule f(tab,chn, handle(add|insert=>aft|bef), dport, dip, ifc, counter, mon, accept), 
   add rule chn1 { $ifcIn | $ifcOut} { bef dst ip, srcIp, dport $prts, dnat to $ip:$dport1 | {masquerade|snat to $ip}}, include script. 
   Q: tab ={chain, addr family, rule, set, objO}. Q,addr family: matches ip (ipv4, dft), ip6, inet(v4,v6), arp(v4 add resolution proto), bridge(from bridge dev), netdev(ingress) pkt.  
   Q: chain={rule}.  nw stack -> base chain. regular chain can be jump tgt.  Q: set={ip/mac/proto/svc/mark, dynamic, $timeout ∴ -entries}, rule=f($set).  Q: map={ip/mac/proto/svc/mark/counter/quota : action}, rule=f($map).  
   Q: rule f(meter: allow $n simultaneous cons to $prt from saddr). list meter => ips w/ active cons to $prt.  Q,rule: add $saddr w/ con rate >$n/min to $set -> drop all cons from ip ∈ $set.
  P: systemd svc loads scripts ∈ cfgFl. scripts dir
#snort: lnt30i: OCI: inst1SbnPriv1-->snortInstSbnPriv2-->snortInstSbnPub-->inst2SbnPriv1, sbnPriv1: any tgt -->  snortInstSbnPriv2(enp1s0)
 ~o/p:[**] [genrId:snortId(sid):revId] (snort_decoder): T/TCP Detected [**]  ~ -s: syslog  ~ -b: log pkts in their native binary state to tcpdump fl to keep up w/ 100Mbps. unified2 log rdr(eg barnyard2).   ~cmd line options to change order of applying rules to pkts.
 ~large|generic recv offload(l|gro) enabled ∴ NIC reassembles pkt -> kernel. bdft, snort truncates pkts > dft snaplen(=1518 bytes). ∃ l|gro ∴ issues w/ stream tgt-based reassembly. ∴ turn off l|gro.
 ~lnt30d: inst.  ~lnt30e, snort.cfg: include, var, portvar, ipvar, alert f(proto(TCP,UDP,ICMP,IP), $cidrSrc|Dest, $prtSrc|Dest, msg, content f(text,|hex|) react(block & send notice), sid, revId), ip list. sid-msg.map fl.  ~lnt30f: cfgFl, cmd for IPS.  
 ~cidr: /16|/24 ∴ class B|C 
#nginx: ~lnt30g: start,stop,reload; cfg for static content; log. directive: svr{lsn $port# (udp), loc $pfx(regex) {root $path | proxy ( pass $url,bind f(ip,port), bfr sz), remIp = regex ∴ proxy pass $url}. fs path = $path/$pfx. $ip -> upstream.
 order: pfx(longest pfx 1st), regex.   ~lnt30h, LB: stream={upstream={svr:port, wt, max-cons, max-fails,fail-timeout(∴ consider svr !available)}, svr {..}}.  
# lnt28: ipxe,pxe boot.   #lnt31a: screen, dtach.  #lnt32a: fl encrn (gpg), drive encrn (cryptsetup), nw encrn (macsec,tcpcrypt)   #lnt33a: cksum, md5sum, sha256sum   #add#: mount -nouuid; change uuid: tune2fs -U random /dev/sdb1 
# ~locale; ~lnt38a: change TZ    #RAID 6, wikipedia: disk1={A1,B1,C1,Dp,Eq}, disk2={A2,B2,Cp,Dq,E1}, disk3={A3,Bp,Cq,D1,E2}, disk4={Ap,Bq,C2,D2,E3}, disk5={Aq,B3,C3,D3,Ep}.      # lnt38b: HP ilo w/ ssh.
# hibernate: make swapfile. kernel line of grub.cfg:  resume=UUID=$uuid resume_offset=$n          filefrag $swapFl -> 1st line of phy offset ∴ n.   /etc/dracut.conf: resume=UUID=$uuid  -> dracut -f ..
# lnt19b,predictable nw ifc name: en ∴ ethernet, wl ∴ WLAN, ww ∴ WWAN
 a. on-board dev: o<index>        b. hotplug: s<slot>[f<function>][d<dev_id>]         c. MAC: x<MAC>       d. PCI: p<bus>s<slot>[f<function>][d<dev_id>]       e. USB: p<bus>s<slot>[f<function>][u<port>][..][c<config>][i<ifc>]   #lnt35b: ens3->eth0.   
 info from f/w or BIOS is applicable & available: a > b > d/e. lspci ∴ bus:slot.fn (in hex)      expt,lspci -v -> dev serial# = mac    #lnt19c: script to measure progress of copying fl.    #xsel -b: copy to clipboard
#add:     UHCI (USB 1.1)   EHCI (USB 2.0)  XHCI (USB 3.0)  lsusb -t;
# screen resolution: xdpyinfo | grep dimensions    #cockpit: https://$ip:9090  #lnt19d: crt sparse fl w/ dd (seek+count=0)   #add w/ notification: dbus-run-session -- bash; dbus-launch --sh-syntax --exit-with-session bash
#DNS: ~BIND: P,lnt34a, svr cfg. Q,named.conf: listen port#, acl={cidr}, allow query f(acl), vw=f({zn}, allow-query/match-clnts f(acl)), zn-name=dom, (rev)zn f(type=master|fwd,znCfgFl|fwdrIps(failover)), 
  Q,rev zn: zn name: 1.0.10.in-addr.arpa, rec: 141 PTR e.c. ;141 ∴ last octet.  P,lnt34c: dyn DNS upd.
 P,c9p, zn fl: $ORIGIN e.c. ;∴ start of zn fl ∈ namespace  |$TTL 3600 ;dft expiration secs ∀ RR w/o own TTL  |e.c. IN SOA ns.e.c. usr.e.c. ( 1 8H 2H 4W 3600 ) ;prim-NS hostmaster-email (serial# time-to-refresh time-to-retry time-to-expire min-TTL)  |
  ; oradoc: host-label TTL rec-class rec-type rec-data  | e.c. IN NS ns ;ns.e.c is a NS for e.c  |e.c. IN NS ns.bkp.e. ;ns.bkp.e is bkp NS for e.c  |e.c. IN MX 10 ml.e.c. ;ml.e.c is mailsvr for e.c   |@ IN MX  20 ml2.e.c. ;equiv to above, "@" ∴ zn origin  |
  @ IN MX  50 ml3 ;equiv to above, w/ relative host name  | e.c. IN A $ip4a  | IN AAAA $ip6a  |ns IN A $ip4b ;for ns.e.c  | IN AAAA $ip6b ;for ns.e.c  |w3 IN CNAME e.c. ;w3.e.c = alias for e.c  |w31 IN CNAME w3 ;w31.e.c = alias for w3.e.c  |ml IN A $ip4c ;for ml.e.c  |
  ml2|3 IN A $ip4d|e ;for ml2|3.e.c   h IN A $ipi ∴ round robin     e.c ∴ eg.com    P,child zn: independent subdoms w/ their own SOA & name svr (NS) recs. parent zn of child zn ⊃ {NS recs that refer DNS queries to NSs of child zn}.
 P,TSIG (txn signatures): Q: crypty signs mesgs f(shared secret).  Q: restricts acs to some svr fns (eg, recursive queries) to authd clnts.  Q: ensures mesg authenticity (eg w/ dynamic UPDATE mesgs or zn transfers from prim to sec)
 P,expt: OCI: fwdr--UDP-->NLB--TCP-> onP DNS.  P,#add#: TCP vs UDP
 ~lnt34b,dnsmasq: P:lsn addr. P,dns: dom to auto add to simple names in /etc/hosts(EH).  P,dhcp: dom, dhcp range, gw, dns, bcst addr, ntp svr
%%%%%%%%%%%%%% lin(scripting)
# ~/.bashrc, ~/.bash_profile    #lnt5a: ~if: and, or, !, >/==/&&, regex, short if, else if, awk if.  ~while loop, subshell (rd i/p), rd i/p (few chars) . ~lnt5d: lk fl.  ~lnt5b: case stmt.  ~lnt5c: associated array.  ~$? ∴ exit status.  
 ~ ${!#} ∴ last arg in shell. : ∴ do nothing.   ~lnt5e: shell to exec script.
# lnt6a: seq of nos, letters.  #lnt6x: basename f(sfx)    #lnt6b, substr,length: shell, awk(adv). awk: tolower. pos of str2 in str1. remove prefix,suffix. incr var.  #lnt6c: get random val.  #wait ∀ child ps: wait. 
# lnt6d: echo {[!]new line,tab}, rd|gen pswd. printf: lpad, num sep (IN).    # tee: rd from stdio + wr to stdio & fls
# lnt6e: ~store ',",$v in a var. ~man, eval [arg] or (expt) $arg1 $arg2 ..: args are rd & concatenated into 1 cmd. ~store o/p of (cmd|arithmatic expr) in var.  ~exp all vars from cfg fl.  ~substitute env vars in fl.
# lnt6f: tail from 191st line.  #lnt6g: ~bc: hex -> decimal. ~no pfxd by 0|0x = octal|hex. base#no; #lnt6h: >1 line comment.  #lnt6i: ~$fl1 minus $fl2. ~paste: merge 2 fls, join 2 fls on common field  ~cat numbered o/p lines. tac reverse of cat.  ~sort -u $fl -o $fl;
# lnt6v: sql on csv.  # lnt6v1, sqlite.   #lnt6v2: spreadsheet (sc).  #lnt6v3: data -> bar/pie/curve google chart.  #lnt6j: egrep(or,regex(+sql)), grep (blank lines, tab), sed (regex,insert $str on nth line), print $n lines bef|aft matching lines.  
#add# regex: http://www.robelle.com/smugbook/regexpr.html # #add#:  append only fl: chattr +a $f;  #lnt6k, find: mtime,sz,type(fl/dir),usr,grp,exclude. du (hidden). stat -f $f ∴ (id, fs type, bl sz, free/avl bls); #lnt6l, touch: change fl timestamps.   
#lnt6u: setfacl, getfacl.   #echo $SECONDS.   #python script: local/l/lin/hs.py   #lnt6za,xargs: arg,||. 
# lnt6m,vi: search (case insensitive), get line# of curr line, print numbered lines, global search & replace, to prefix all lines by str, fix err, nowrap(+ less), syntax on|off, increase indent. lnt6ma: set terminal rows & cols.  #mkdir -p /d1/{d2,d3}; ln -s /d1 /d2/d3
# lnt6n: uname, os rel, os banner, ol uek rel.  #lnt6o: lower -> upper case.   #lnt6p,tr: removing '^M' (win), \n.  #lnt6q, cut,awk: a    b c -> b    #set -o vi or ksh -o vi  #lnt6z: vi cfg (align)    #lnt6r: [un]tar, zip, 7za, split, pipe tar o/p to split.
# lnt6s,date: format, set, arithmetic(+perl). rd hw clock, sync h/w & os clocks & vice versa     #lnt6t: bc    #lnt6w: max hostname length  #lnt6y: vim insert math symbol.  # lnt7a: fn. list fns: declare.  #lnt7b: perl prog.   #lnt7c: c prog + sqlplus instant clnt.  
# lnt7d: mos dwnld script, axel ||downloaader, wget params  #lnt7e: curl, know resp code w/ curl. #yes $str ∴ o/p $str repeatedly until killed.  # debug json syntax: cat $fl.json | python -mjson.tool  #lnt27c,shell: named param.  #lnt7f: here doc.  #lnt7g: jq    
%%%%%%%%% rec(non-tuning)
#S3: redo record ∈ RLF. cv=change vector, cv ∴ change to a bl. redo record={cv for data seg bl, cv for US dbl, cv for txn tab of USs}.            # nt23a: rman cfg cf auto bkp fmt.   #~nt23g: show rman cfg. cfg dft bkp dev.       
#~S17,nt22g,FRA(!outside): in general, ora eventually deletes transient obsolete fls or fls bkpd to tape. does !delete eligible fls until space must be reclaimed for some purpose. cfg retention policy to rec window of &days, redundancy $n. del obsolete inr bkp.   
 ~ nt22h, for FRA: cfg ALF del policy to bkped $n times. disk space reqd ∴ dels oldest logs(eligible for del) 1st.  ~ nt23c: ip: FRA dest, sz. vw: FRA usage.    # nt23d:~vw: RLF. ~restore ALF from-seq# & ∈thread#. seq# ∴ thread#.  
# ~nt23e: incomplete media rec -> rename RLF -> open resetlogs [upgrade] -> drop & add tmp fl on [bigfile] tmp tbs(nt56b). ~nt23f: clear [!archived|curr RLF of closed thread] RLF.       #rec cat should be EE.
#S13,nt23h: nomount -> res spfile from media -> shutdown -> nomount -> res cf [ f(autobackup, maxdays, db unique name of inst which took bkp(expt), until time)]        
#~ nt21a: cfg channel f(fmt, maxpiecesz, con), bkp df/df# in a channel.  ~nt21b: bkp as copy.   ~hs:in hot bkp, bkp db > switch log > bkp ALF.  ~nt21e: use disk as sbt for test (expt: bkp to fusemount obj storage).  
# nt21c: df lost w/o bkp -> crt new empty df -> media rec w/ all ALFs gend since orig fl was crtd. #nt22i: cfg st RMAN cmds ∈ log; spool.  #expt+266991.1: ro tbs + crt cf ∴ offline dfs of ro tbs  -> open resetlogs -> online tbs. 
# nt21d: rec db,df,tbs, skip tbs, del ALF. rec db < scn. del ALF,bkp <,> $dt. res db,df to new loc. sql script (cf rman switch df). vw: df copy. rec db through resetlogs. expt: res ∴ $dir/db_unique_name/df crtd. 
#~bkp ref,nt35b: RMAN res detects unusable dft filename(eg, OMF or ASM fl) ∴ RMAN crts new fl in same loc.     ~nt35c, vw: curr scn.      #~ nt35d: crosscheck bkp; expired ∴ !found on media.     #nt21f: bl rec script w/ dd
 ~ nt35e: res cf -> mount -> list incarnation (2 parent 154381, 116 curr 154877) -> reset to incarnation 2 -> res & rec db until scn 154876 -> open resetlogs -> list incarnation (2 parent 154381, 116 parent 154877, 311 curr 156234)
#~ nt22a,vw: fls needing media reco, ALF, cf & df in bkp set, bkp set, bkp piece, bkped ALF.   ~nt22b: user managed bkp. vw: fls in bkp mode.  ~nt22c: change bkp of cf, spfile, db, df, tbs [of pdb] completed bef $dt {[un]available | uncatalog}.  
 ~ nt22d: bkp dfs !bkped since $time.  ~REPORT OBSOLETE; ~nt22j: shutdown immediate -> mount -> ALF mode(vw) -> open. oerr: rec reqd ∴ RLFs may! be sufficient to rec dfs.
# S83: prim & stdby may have diff CPU arch, os, os binaries(32/64), or ora binaries (32/64). 413484.1: mixed-platform support & restrictions for phy stdby.          #12.2: >1 inst redo apply.
#~ nt45a: validate bkp set, db. pplts vw (cvw). tests data & ind bls that pass phy crptn checks for logical crptn(ie bl contents logically incst.), eg, crptn of a row piece or ind entry.  bkp db w/ logical crptn check
 ~ bkp ref> bkp: bkp bkp set just copies (! en/decr) bkp set to disk or tape.     ~ ip: goes through data in bl, to check logical self-consistency. costly insert,upd.   l: ip db_block_checking  
 ~ nt45b: rec crptn. any ps encountering bl crptn records in cvw. cvw does !record crptns that can be detected by validating relationships bet bls & segs, but can! be detected by checking individual bl. bkp, res, validate -s repaired bl from cvw.  
 ~ nt45c: rec db allowing crptns. rec db w/ sqlplus. hip: ignore offline/crptd undo segs (prevents access to listed US hdrs + assumes all txns are committed).  #check: _allow_resetlogs_corruption=true.  #~nt26f: tab as of timestamp. ~nt26b: purge tab, ind from recyclebin.
# ~ RECOVER applies incremental bkps to a df image copy to roll it forward in time. expt,9.2.0.4:L0 restored -> cumulative L1 applied  ~nt46a: level 0 bkp can be either bkp sets or image copies. incr bkp from SCN. ~nt46c: bkp 1 copy ∀ RLF seq# (!-d by RMAN) & -.
# hot backup mode or extra logging: 76736.1   # S14: rec steps: a) cc recovery (rolling forward): applies all committed & uncommitted changes in RLFs to affected dbls.             b) txn recovery (rolling back): applies US to undo uncommitted changes.
# nt27g,ip:  ~ ckpt interval|timeout ∴ #-redo bls(phy os bls, not db bls)|time, that can exist bet incr ckpt & last blk in RLF.  ~ mttr tgt ∴ time reqd for crash rec of single inst. when specified, ckpt interval overrides mttr tgt.  
  ~ log ckpts to alert   ~ RLF switch after ip time.         #vw in bkp cf ∴ recd until change#, time (expt).  l: V$DATABASE.controlfile_change#,controlfile_time
#~ nt47a, impdp params: remap schema|tbs|data(remapFn(col)), status, stop job, include, exclude, metrics.   ~ nt47b, impdp: !replace of existing tab(ret): existing tab-dep objs (eg inds, grants, trigs, constraints), are !modified.  
 ~ expt: expdp sch1 ∴  impdp crts sch1, granting roles to sch1.  ~nt47c: issues.  ~ expt perf: P: ret faster than truncate w/o existing ind.             P: w/o ind faster than w/ ind for truncate.        ~nt47e, script: search impdp log for errs.
 ~in,exclude in same exp,impdp.  ~utilities>expdp>include: grants on objs owned by SYS !expd. 
 ~ nt47d: sqlldr f(i/p,bad,discard fl, truncate|append tab, col enclosed by char). (crt / select from) ext tab f(i/p fl, col enclosed by char). expdp uses CTAS to crt ext tab w/ data that is stored in dmp fl.  
%%%%%%%%%%%%%% installation & upgrd(non-tuning)
#  nt49a: loc of inventory in diff os, list contents of inventory.            # clnt/server/interoperability support bet diff ora vrsns: 207303.1
#!CDB(!checkedFrm12.2) ~ nt28a: pre upgrd sql from old OH -> upgrd -> cfg fine-grained acs to ext nw svcs.           ~#!checkedFrm19#nt28b: upgrding time zone fl & timestamp with time zone data
#~ nt28c, upgrding pdb(p1): unplug p1 in OOH -> crt pdb in NOH f(p1.xml) -> catupgrd in p1 
#~ nt29a, OH: deinstall, clone, changing grps after installation, know osdba,asmdba etc. ~enable/disable options in binary: 948061.1   # ~ nt29b: xe instn.
#~ RU,nt30c:  get latest OPatch -> prereq -> shutdown dbs -> apply -> startup  -> open pdbs -> datapatch.  ~nt30b,vw: comp prod; db comp registry, log; upgrd, dwngrd & PSU applied; fixed CBO sql bugs(hs); sysaux occupants & move proc. 
 ~472937.1: info on installed db comps & schs. ~742060.1: release schedule of curr db releases.  #add#2275525.1 (internal).   ~ nt30d, ro OH: enable, status, dir changes.   ~suid bit perm of ora binary.
%%%%%%%%%%%%%% arch(non-tuning) 
#~ nt50a: alter tbs online|offline, ro|rw, perm|tmp.  P: offline normal (dft) ∴ ora flushes all bls in tbs out of SGA.  P: offline tmp ∴ ora ckpts tbs but does !ensure that all fls can be wrn.  P: offline imdt ∴ !ckpt.  vw: df status (offline, rec).  
  expt: -rows -> offline normal -> commit -> restart db -> online -> rows -d.
#~ nt51a: rowid =f(data obj#(∴db seg), tbs-relative df#, df-relative bl#, row# in bl).  S38: row# is ind into row dir entry (∈ bl hdr).  ptr to loc of row on bl ∈ row dir entry. db moves row within bl ∴ db upds $ptr ∴ rowid !changed.
 ~ S5: row +d in IOT ∴ $row can move within or bet bls ∴ $row !have permanent phy addr. logical rowid: P: base64-encoded representation of primary key of IOT. P: ∈ sec ind (ie ind on IOT).
%%%%%%%%%%%%%% nw(non-tuning) 
#^#dl
#~ nt54d,ip = { nw name, local & rem lsnr }.   ~nt54e: register inst w/ lsnrs imdtly.  ~nt52a: lsnr log: timestamp, clnt info(svc name, host, inst name), cman svr | clnt ip, establish | error, error code.  ~ nt54f: tnsping --> lsnr (!db).    ~nt31a: net svc name.        ~
#~ nt54a: param in sqlnet.ora: P: probe to check active clnt/svr cons. terminated or unused con found ∴ svr ps exits.  P: invited nodes. similar for ssh in /etc/hosts.   P: min authn protocol allowed to con.  P: clnt tracing. 
 ~ nt54b: param in listener.ora: logging, trace level, nodes invited|excluded for regn, use sid as svc name in con descriptor. ~#!checkedFrm19#nt54c: off lsnr logging -> mv lsnr log -> on lsnr logging.       #!checkedFrm19#nt53a: heterogeneous con, dsn to ora
#~ con id ∴ con ∈ trc & logs
%%%%%%%%%%%%%% misc(non-tuning) 
# ~ nt55a: curr sch: set in ses, vw.    ~nt55b: drop db.     ~nt55c: restrict logon to inst.   ~nt55d: ip resumable timeout. vw: all resumable stmts executed.
# ~ nt56a:df|tmpfl: resz,online,offline,autoextend. rename df,tmpfl,RLF. db open: !ckpt on df > offline > media rec df > online.  S97: rename OMF ∴ old fl deld. expt: rman switch does !del.
  ~ nt56b: add|drop df|tmpfile from|to tbs(even bigfile tmp tbs). drops empty fl. removes fl from DD & os.  ~nt56c,tbs: rename, shrink, drop. alter dft tmp tbs of db.
# ~ nt57a, kill ses. imdt ∴ rollback ongoing txns, release all ses locks, rec entire ses state, return ctrl imdtly. cancel sql.  ~nt57b: alter user's quota on tbs, set user's encrd pswd. ~nt57c: bef or aft inst startup: crt pfile|spfile from spfile|pfile.  
#~ nt58a, vw: ps, ses( JOIN ps), bg ps, inst(host name).  ~ nt58b, ses,inst,spfile ip vw. set,reset ip f(scope,sid).  # ~ expt,11.2.0.1.0: sid, db unique name, db name, svc name, inst name all may be diff. init$ORACLE_SID.ora, ora_pmon_$ORACLE_SID
# ~ nt59a: vw: vw text, DD tab & vw, cf, cf rec sec, seg, ext (expt: seg name ∴ tab name), user's tbs quota, free space, tbs, tab, constraint, ind, tab col, constraint col, obj, df, src.  ip: skip unusable inds (!ind of unique constraint).
  ~ nt59b, param: max log hist in cf. adds addl space to appropriate section of cf as needed, till max cf sz.  ~nt59c, cls in truncate tab: deallocates all space (including MINEXTENTS) of tab & its dependent objs. ind unusable ∴ space allocated for ind freed imdtly.
# ~ nt60a: ip ∴ dft date fmt of TO_CHAR & TO_DATE.  vw: nls param, nls ses param, db prop, clnt info of ses. query charset, IP from which clnt is connected. crt global context={appln-defined attr}. os var: nls lang, nls date fmt.
  ~ nt60b: ip, os var ∴ bytes or char to use for VARCHAR2 & CHAR.    ~ #add# globalization support guide > charset migration.      # ASM+RAC+OCFS+NFS,expt: fl sys mount, NFS mount, exports all sync   #nt60c: enable/disable direct NFS.
# nt32, scheduler vw: job, window, window gr member. job to run shell script.   #nt61b: obj quarantine isolates errored obj(a) + monitors a for impacts on sys. vw.     #S104,ip, delay in inst abort.   #add# admin guide > diagg & resolving problems
#dict schs: APPQOSSYS -> quality of svc mgmt.   #nt61a, adrci: crt pkg bet times -> gen zip fl, show log w/ prd. #nt61c,vw: (contents of alert log, diag trace (fl | fl contents)) f(pdb)    #nt5a: rda, orachk. #nt5b, tfactl: orachk      
%%%%%%%%%%%%%% sec(non-tuning) 
# ~nt62a, vw ∴ users in pswd fl, SYS* privs. orapwd. name of shared pswd fl is orapw.    ~nt62b, sqlplus: read pswd, hist w/ vi (expt pswd visible).      ~nt63a, set rsrc limit ip -> crt profile w/ ses/user -> crt user w/ profile.
# nt62c, vw: ora maintained user,role.  #nt62d: proxy usr f(role).  #S106: blockchain tab: for centralized blockchain appln. insert-only. {chain}. each(!1st) row in chain is chained to prev row in chain w/ cryptographic hash.
~~~~~~~~~~
~nt64d: unified auditing: enable in binary, crt policy, audit policy, clean audit trail. vw: audit trail, (enabled) policies.
~~~~~~~~~~
# ~ nt64c: turn on & check encrn & cksum in clnt|svr sqlnet.ora.
# expt: P: SQLNET.ALLOWED_LOGON_VERSION_SERVER=11 -> db restart -> set passwd -> pswd ver = 10g 11g 12c.   P,impdp + sqlfile: CREATE USER .. BY 'S:...;$encrdPswd' ;                  P: from oracle os user, sqlplus / ∴ logs in to ops$oracle db user
~~~~~~~~~~
S101: SELECT priv = READ priv + LOCK TABLE &tab IN EXCLUSIVE MODE; + SELECT ... FROM &tab FOR UPDATE;
%%%%%%%%%%%%%% dev(non-tuning) 
# ~nt65a: alter tab enable|disable constraint.   ~nt65b: crt dir.   ~sqlplus col fmt.  ~repln: symmetricds,local/l/db/symds.txt
  ~nt65c: crt, close dblink. we can! crt dblink in userO's schema, we can! use sch.dblink. vw: src dbs that opened dblinks to local db, src of high SCN activities.  ~nt18: compare & converge 2 replicated tabs.  
#~ nt19b: changing max sz of VARCHAR2, NVARCHAR2, RAW data types. ip. ~nt19c, sql fn: #-bytes in internal representation of expr.    ~l: compiling invalid objs   ~nt19a,sql: exec imdt, case, fn: n -> chr.  ~nt20: get ddl.   #nt19e,LISTAGG fn: f2 -> (v1,v2..) gr by f1.
##add# ~ adv appln dev guide > chp: edn-based redefn,  ~offset 10 rows fetch next 5 rows only.  ~ORA_HASH sql fn.  ~(hs) cr f(param) ∴ return rowset cf fn.    #invisible col    #nt19d, alter tab col: set unused, drop [unused] [cont].   
# DBMS_UTILITY: ~ nt68a, sql: vw -> subquery.  ~nt68b: format call|err stack, err bktrc #exptIt#; os identifier; plsql tab of names <--> comma-delimited list of names, wt on pending DML,  
# EXEC FOR r IN (SELECT * FROM t) LOOP INSERT INTO &t VALUES r; END LOOP;       # >1 tab insert: INSERT ALL    # quote >1 line sql block: Q'[...]   # nt19f,sql macro: fn($p) return expr/tab f($p),dbms_output.put_line.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OCI
%%%%%%%%%%%%%% OCI nw: 
src: https://docs.cloud.oracle.com/iaas/pdf/ug/OCI_User_Guide.pdf         rel notes:  https://docs.cloud.oracle.com/iaas/releasenotes/services/network/  studies till Nov. 12, 2020.

overview of nw:
---------------
 ~ VCN: {cidr bl} ∈ region, ipv4: /16../30. eg 192.168.0.0/24, reserved:  192.168.0.0 nw, 192.168.0.255 bcst, 192.168.0.1 sbn dft gw.       ~ VCN={sbn}. AD = {isolated, fault-tolerant DCs} ∈ region. 1 sbn uses 1 RSD.
 ~ sec vnic(sv) ∈ same AD as prim vnic (pv).  ~ prim prip (you or ora can choose) doesn't change during inst's lifetime. ora chooses puip. ephemeral puip exists only for lifetime of prip. reserved puip f(region).
 ~ VCN auto comes w/ RSD.  ~choose RSD during sbn creation.   ~pub/priv sbn can ∈ VCN w/ internet acs.   ~gwi|gwn: for rsrc w/|w/o puip. gwi --(!internet)--> OCI puip <--gws-- prip.   ~169.254.0.0/16 used for iSCSI con. 
#skip#: accesscontrol, classic, classicwithoraclenetwork, classicwithvpn

scenarios:
~~~~~~~~~~~~~~~
 ~ A: gwi --- virt rting fn built into VCN -----> VCN(10.0.0.0/16)={sbn 10.0.0.0/24 AD1 (rsrci), sbn 10.0.1.0/24 AD2 (rsrcj for redundancy)}.     
 ~ transit rting: P: onP --- 1 fc/vpn ---> DRG ---> hub VCN(h)  {LPGhi ---> LPGsi ---> spoke VCN(si)}. 
    Q,pdf, p1763:  onP: 172.16.0.0/12, h: 10.0.0.0/16, s1: 192.168.0.0/16.  rtt: (dest cidr, rt tgt) = DRG attachment(s1, LPGh1), LPGh1 (onP,DRG), h((onP,DRG),(s1, LPGH1)), s1((h,LPGs1),(onP,LPGs1)), LPGs1 (). h may! have sbn.
    Q,#skp#: you can attach DRG to any VCN in same region & tenancy. attachment ∴ VCN.     Q,#skp#: rts(hs cidr) advtd to onP|spoke = h + s1|onP (from rtt of (DRG attachment | LPGh1)).    Q,c2a: (DRG attachment) | LPGh1: crt & f(rtt).
    Q, w/o DRG, expt: h: LPG: lpghs1|2,  rttLpg: (cidrS1|2,pripInH(w/ ip fwdg)).  s1|2: LPG: lpghs1|2,  rttS1|2: (cidrH,lpghs1|2), (cidrS2|1,lpghs1|2).
   P, priv acs to OCI svcs(ocis):  ~Q: in fc pub peering, onP hosts use puips.  
    Q: onP -> DRG -> VCN_h -> gws -> ocis   Q: onP -> DRGi -> {VCNi,VCN4ocis}. VCN4ocis -> gws -> ocis.  rtt={dest cidr, rt tgt}: DRG4ocis attachment={PHX svc in ocis, gws}, gws={onP cidr, DRG}
    Q: onP -> DRG -> VCN(10.0.0.0/16).inst.frontendVnic(10.0.4.3/24) -> VCN.inst.backendVnic(10.0.8.3/24) -> gws -> ocis.
        rtt: DRG4ocis attachment={PHX svc in ocis, 10.0.4.3}, gws={onP cidr, 10.0.8.3}, sbnFrontend={onP cidr, DRG}, sbnBackend={PHX svc in ocis, gws}. disable src/dest check ∀ vnic.
    Q, generic: VCN(vcn1) local rtg ∴ ∀ rtt ∈ vcn1 ∃ !rule w/ vcn1's cidr (or subsection) as dest.   Q,hs: prip of DRG/gws ∈ cidr of VCN.
    Q,#skp#: DRG attachment or gws can exist w/o rtt.  rtt linked -> a rtt must always be linked w/ it.

NSG:
~~~~~~~~~~~~~~~
~ NSG = f(vnic(s), sec rule(s)). vnics, NSG ∈ same VCN. vnics ∈ computes w/ same sec posture. >1-tier arch: NSG-tr1 <--> NSG-tr2. NSG-tri ∈ same VCN.
~ hs: NSG bet prips of same VCN. expt: P,202106: (NSG|sec list) w/|w/o ssh from pub ∴ can ssh to puip.  P: NSG|sec-list !| allow any !∈ same VCN ∴ icmp(!ssh) to peered vcn !work.
  #skp# P: (NSG|sec list) w/|w/o ssh from pub ∴ can! ssh to puip + can ssh to prip. 
~ ∃ unique OCI-assigned id ∀ rule in a given NSG.  ~c3a: vw sec rules & rsrcs in NSG.   ~c3b: crt NSG.  ~ add|remove rsrc to|from NSG. generally, manage vnic membership of NSG at parent rsrc

sec lists:
~~~~~~~~~~~~~~~
 ~ (sbn : sec list) =(1:>1)        ~ ∃ stateless rule ∴ add rule that allows ingress ICMP type 3 code 4 from 0.0.0.0/0 (any port). this enables insts to receive Path MTU Discovery fragmentation mesgs.
 ~ ∃ stateful ingress rule in dft sec list to allow ICMP trfc type 3 (all codes) from $VCN's cidr & any port. this makes it easy for insts to receive con error mesgs from instO ∈ $VCN.
 ~ in|egress rule =f(src|dest cidr/svc, src & dest port#)     ~ large UDP pkt = {fragment}, only frag#1={prtl,port#}  ∴ set src & dest ports in rule = all.      ~ precedence: stateless > stateful

vnic:
~~~~~~~~~~~~~~~
 ~ vnic needs to fwd trfc (eg NAT)  ∴ disable src/dest check (in hdr ∀ nw pkt).   ~c3c: cfg os for sec vnics.  ~c3d: get inst metadata from $inst.

ip & DNS in ct VCN(ipv6)
~~~~~~~~~~~~~~~~~
~ vcn /56, sbn /64. nw gw supportg v6  DRG,LPG,gwi. global-unicast-addr (GUA) or globally-routable vcn cidr assigned by OCI. eg. vcn(2001:0db8:0123:7800::/56), sbn(2001:0db8:0123:7811::/64), vnic (2001:0db8:0123:7811:abcd:ef01:2345:6789). right-most 64 bits by ct. 
~ stateful ingress icmpv6 type 2 code 0 (pkt too big) ∴ PMTUD. stateful egress ∴ response tfc allowed !f(ingress rule).   ~fc vc, VCN: v4(reqd), v6(optional).   ~LB--v4(!v6)-->bknd    ~can! assign hostnames to v6 ip.  ~ips are regional.
#start# 20210728: p3751 Task 3: Create the internet gateway

prip:
~~~~~~~~~~~~~~~
 ~ sec prip has a puip ∴ puip can move along with prip to instO.     ~ assign sec prip to vnic from console.
 ~ bastion svc: IAM > bastion, inst ∈ priv(expt: !pub) sbn. managed ses: gws + inst > cloud agent > bastion + (hs) pub key gets copied.  port fwdg ses.  agent logs: /var/log/oracle-cloud-agent  
 
puip:
~~~~~~~~~~~~~~~
 ~ reserved (!ephemeral) puip can be assigned to sec prip.

DNS in ct VCN:
~~~~~~~~~~~~~~~
 ~ crt VCN & sbn ∴ specify dnsls. VCN|sbn domain name: (VCN-dnsl | sbn-dnsl.VCN-dnsl).oraclevcn.com. inst FQDN: hostname.sbn-domain-name ∴ prip. FQDN of hostname of (sec vnic | sec prip(sp)) ∴ (prim prip|sp).
 ~ (VCN dnsl | sbn dnsl | hostname) (should|must|must) be unique (across VCNs | in VCN | in sbn). display name need! be unique.    ~ DHCP options for DNS = {DNS, search domain(=dft, VCN domain name)}, has OCID(src: DHCP option)
 ~ custom DNS: use 169.254.169.254 as fwder for VCN-dnsl.oraclevcn.com.     

DHCP option:
~~~~~~~~~~~~~~~
~ restart inst's DHCP clnt ∴ DHCP passes same prip to inst ∴ don't stop DHCP clnt.    ~ DHCP lease renewed + !c4a ∴ /etc/hosts & /etc/resolv.conf overwritten.  ~l11: lc

rtt:
~~~~~~~~~~~~~~~
~ inst1-VCN1 <-- !| rtt (hs: | fw) --> inst2-VCN1|2              #~ hs: dest cidr in rtt ∴ src cidr

DRG:
~~~~~~~~~~~~~~~
~ #skp# atmt --> its rtt
~ DRG rtt & DRG rt distribution(rtd) -- rtg policies bet atmts. rts can be dyn im|exported w/ these atmts. rtd is im/export type + does! inherit action f(association).  rts ∈ attached nws are dyny imported into DRG rtts w/ optional import rtds.
~ DRG:{VCN,RPC,ipsec,fc attachment(atmt)}. VCN,ipsec m∈ tenancyO.  ~ sbn1 <--> hidden implicit rtt <--> sbn2. sbni ∈ $VCN.  expt,tcpdump(!nmap): inst1Sbn1 --> rtrMac -> inst2Sbn2(!1) --> rtrMac --> inst3Sbn1, rtrMac of sbni is same.     
~ DRG rtt={static, dyn rt}. atmt--dyn rt<-->rtd={priority: low# ∴ high priority, ex|import stmt: ∴ atmt-ocid or atmt-type}<-->DRG rtt. $stmt -d from rtd ∴ $rt -d from DRG.  dyn rts from $VCN ={sbn cidr ∈ $VCN, cidr ∈ rtt of $VCN}.  
  rt provenance: P: DRG1--rt<-->RPC atmt--rt<-->DRG2. P,ipsec-tnl/fc-virt-circuit, !true(even w/ rt): tnl1|vc1<-->DRG<-->tnl2|vc2. DRG:VCN=1:>1. dft: DRG rts tfc bet attached VCNs.
~ move virt circuit to DRGO.  ~RPC on DRG: 2 VCNs m∈ diff tenancies.  ~DRG rtt: enable equal-cost >1-path rtg (ECMP). tgt type: DRG,prip.
~ cmf, acs vcn in tenancyO w/ vcn attachment: reqr(DRG)|acptr(VCN): grLoc to manage DRG-attachment|DRG in tenancyO; admit grRem to manage DRG|DRG-attachment in tenancy;   #skp# acs vcn in tenancyO w/ RPC.
vpn:
~~~~~~~~~~~~~~~
~ for static-rtg(optional),BGP: enter inTnlIfcIpOci,Cpe for tnl troubleshooting  ~tnl mode : encrs & auths entire pkt(p1) ->  p2={diff hdr, p1}.      ~vpn = {redundant tnl(ti)}. uses asym rting across ti's. prim t1, bkp t2 ∴ trfc on any up ti.  
~ prefer $tnl: P: CPE's BGP loc pref attr.  P: cfg CPE to advt more specific rts on $tnl. OCI uses rt w/ longest pfx match.  P: BGP prefers shortest AS path, use AS path prependg(c0b) st $tnl has shortest path for $rt.
~ ct CPE !| behind NAT dev ∴ vpn con = f(ct CPE ike id(pu|pripCpe/FQDN)). fg: $inTnlIfcIpCpe1.  ~site-to-site tnls:  P: public telecom lines (less expensive than lease lines) used.    P: internal ip of participating nws & nodes hidden from ext users.
~ rt pref if both vpn & fc used (to $DRG): P,OCI->onP: 1. fc(asnCt) > vpn BGP(asnPriv,asnCt) > vpn static rt(asnPriv(3)). 2. OCI prefers oldest estd rt.  P,onP->OCI: most rts for OCI svcs advtd by DRG|pub-acs-path have longer(specific)|shorter pfx.
~ sec assn(SA) ⊃ sec param ind (SPI). SPI maps pkt's src, dest ip, prot type to SA db entry ∴  how to en/decr pkt. SPI = encrn dom(ED), proxy id, tfc selector.  
~ IPSec rt based tnl:  ∃ rtt lookup on a pkt's dest ip -> pkt encrd + sent to endO of tnl. OCI vpn headends use this, can work w/ policy-based tnls(#skip#) w/ some caveats. ED={any,any,IPv4}. can use 1 summary rt also.
~c0a: crt CPE f(puip of onP rtr), DRG, ipsec con f(CPE, DRG, onP static rt).  ~ PAT: VCN rtt: dest:tgt=$ipPAT:DRG. static rt in vpn: $ipPAT.   ~ >1 CPEs w/ same NAT ip. ~OR: DRG:CPE=1:>1. src(cisco ASA cfg): puipOci1|2 ∈ geo redundant rtrs.
~ ∃ >1 sites(s) vpnd to OCI + s cond to onP backbone rtrs ∴ cfg vpn rts w/ (local site aggregate rt & dft rt). (DRG rts learned from vpn | dft rt) are only used by trfc (from VCN to DRG | to ct DRG whose dest ip does! match more specific rts of any tnl).
~ phase1|2(isakmp|ipsec) params: proto(v1/v2), encrn algo(AES-256-cbc|AES-256-gcm), authn algo(SHA-2 384|HMAC-SHA-256-128), ses key lifetime(28800|3600), (exchange type(main mode), auth method(psk), diffie-hellman gr(DHG)(20)|perfect fwd secrecy (PFS)(5)).    
~ CPE cfg,verifed CPEs: local/l/c/cpe.  libreswan: f(ikev1|v2,puipCpe, puipOci, encrn dom, vti,phase1,2-(encr-alg,lifetime).  ~ can change static rts.  ~ cb0: lc
~ c0c,phase1: a) gws agree on ikev1/2. b) gws exchange psks. c) each gw provides phase1 id(ip). d)(hope v1): gw that starts ike negotiations sends main mode proposal. main mode validates ip & gw id.  e) gws agree on phase 1 params(NAT traversal, dead peer detection)
   f) gws agree on phase 1 transform cfg(encrn algo, authn algo, SA life, DHG).  
  phase2: a) gws agree on PFS. encr keys are changed at interval of force key expiration cfg(=8 hrs bdft). PFS ∴ 2nd time DH calculation ∴ SA keys of phase 1 & 2 != ∴ harder to break (if DHG >=14). b) proposal: encapsulating sec payload(ESP)(encr data, protect against 
  spoofing & pkt manipulation (replay detection)), auth algo (info recvd = sent), encr algo, force key expiration interval. c) gws exchange phase 2 tfc selectors (tnl rts). eg tnl rt: host ip, nw ip, or ip range. tnl rt= {ip behind loc|rem dev sendg tfc over vpn}
~ local/l/c/cpe.  P,skpd: policy-based,  asa,aws: interesting tfc sent -> ipsec comes up ∴ cfg SLA monitor.  P,PM: ping $anyIpVcnCidr(may !be up) or use BGP(∃ keepalive)
~ c0d, vpn log: listening for ike mesgs > loadg secrets > v1: initiating main mode (IMM) proposal > STATE_MAIN_I1(SMI1): sent MI1, expecting MR1(MIR1). v2: initiating ikev2 con > STATE_PARENT_I1(SPI1): sent v2I1, expected v2R1
  > v1|2: SMI1|SPI1: retransmission; will wait $sec1 for resp ... (RT) > SMI1|SPI1: timedout after $retransmits. no acceptable resp to 1st ikev1|2 mesg > starting keying attempt 2 of $max > v1: IMM to replace $n1 > SMI1: MIR1, replacing $n1 
  > -g state (SMI1) aged $secs2(hs: ~60s) + !sending notification (DS) > -g ike SA + con is supposed to remain up; schedule EVENT_REVIVE_CONNS > initiating con which recvd delete/notify + must remain up per local policy > RT > terminating SAs > DS
~ expt,hs: P: can |! reach(nmap) $inTnlIfcIpOci,Cpe from onP|VCN.   P,libreswan,onP ∈ ociInst: OCI->onP: 140.91.x.x -> cpe -> onP-ip, onP->OCI: cpe->OCI-ip 
~ #skp#: P: ques for gathering info, info about onP rtr (onP task)     P: cfging ct CPE (p 1945-2068), verifying CPE devs(p 2068-2069)     #add# chp svc essentials > puip for VCNs & OCI svcs nw

fastcon(fc):
~~~~~~~~~~~~~~~
 ~ priv|pub peering: to (a VCN | OCI pub svc (w/o internet))  w/ IPv5.       ~ con models: ora provider, 3pp, coloc w/ ora in OCI fc loc.  #skip#: requirements ∀ con model.
 ~ P, fc loc: ora DC where you can con w/ OCI.       P, metro area: geo area (eg, Ashburn) = {fc loc(fli)}. fli con to same ADs for failure in 1 fli.
   P, ora provider: nw svc provider that has integrated w/ ora in fc loc.  3pp !∈ {ora provider}.        P, coloc: ct equipment deployed in fc loc. 3pp ∴ must coloc.
   P, cc(in coloc or 3pp): phy cable coning ct nw to ora in fc loc. cc gr(in coloc or 3pp): link aggregation(to increase bw) gr (LAG) ={cc}.               P: fc/vpn --> DRG -- rtt --> VCN
   P, vc: an isolated nw path that runs over >=1 phy nw cons to provide 1 logical con bet ct edge & OCI. priv|pub vcs support priv|pub peering. ∃ >=1 priv vcs, eg, to isolate trfc from diff parts of ct org 
    (vc1|2 for 10.0.1.0/24 | 172.16.0.0/16), or to provide redundancy. ∃ |! DRG in priv|pub vc.
     pub vc: Q: provide ct puip pfxes (/31 or less specific) to ora -> ora verifies ownership ∀ pfx -> >=1 verified -> ora advts OCI puip through fc & ISP. when cfging ct edge, give higher pref to fc over ct ISP.
      Q: trfc from |! verified pub pfxes ∴ reply travels over (fc pub vc | gwi).   Q: add or remove puip pfxes by editing vc.
   P: coloc: ct existing nw  --> ct edge -- fc loc (phy con) --> ora edge --> OCI region
              |----------------------- metro area -----------------------------|
       ora provider: ct existing nw  --> ct edge(BS1) -- fc (phy con) --> provider edge(BS1a) --> provider nw --> provider edge(BS2a) -- fc loc (phy con) --> ora edge(BS2) --> OCI region
                                                                                                                    |----------------------- metro area -----------------------------------|
 ~ P, wikipedia: Border Gw Protocol (BGP) is designed to exchange rting & reachability info among autonomous syss (AS) on internet.  c2b: frr cfg.
   P, wikipedia: auto sys (AS) = {cond ip rting pfx, under control of >=1 nw operators on behalf of 1 administrative entity or domain that presents a common, clearly defined rting policy to internet}. for BGP rting: (AS:AS#(ASN))=(1:1). 
   airtel: https://ip.teoh.io/AS24560; whois
   P, ora provider: BGP ses bet BGP speakers ((BS1 & BS2) | (BS1 & BS1a + BS2a & BS2)) -> setting up vc ∴ provide basic BGP peering info to (ora|ora provider).   ~ gen reqmnts: nw equipment supporting L3 rtg w/ BGP.                  ~h/w & rting reqmnts: #skip#.
 ~ ora provider: P: onP ---phy coni ---- > fc loci ∈ same metro area ---> same DRG  (i=1,2, active/active). ∴ 2 BGP sess.    #c5, crt vc. P,c6: #skip# P, pub vc: launch inst f(provided puip pfx).     P: del vc ∴ del con w/ provider (else provider cont billing).
 ~ fc w/ 3pp:  P: use OCI console to set up cc (ccg) ->  logistics (#skip#).  P,c7: crt vc.  P: del cc 1 by 1.  ~ #skip#: fc metrics    ~cc: lc
 ~ >1 proto label swtg (MPLS) rts f(short label, !long nw addr) ∴ speed. label ∴ virt link (path) bet distant nodes (!endpts). MPLS can encapsulate pkts of >1 protos, 
 ~ ipsec over fc: https://docs.cloud.oracle.com/iaas/Content/Resources/Assets/whitepapers/encrd-fastconnect-public-peering.pdf. for BGP, filter specific vcn rts at CPE.    ~ #add#: rt filterg

acs azure
~~~~~~~~~~~~~~~
~ areas of availability: https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/azure.htm     ~ onP-->OCI<--!-->azure<--onP   ~same DRG for vpn & fc
~ cfg nw sec grs & sec rules. ping is ICMP type 8.       ~ prerequisites: P: prim & sec pairs of BGP ips(/30). ip2|3:OCI|azure. P: svc key got during expressrt cfg.        ~ c1a: crt priv fc.    ~c1b: crt expressrt circuit.
~ expt, IAM nw src:  crt $usr ∈ $grp(!=admin) -> allow group $grp to manage buckets in compartment $cmp where request.networkSource.name='$ns'   

gwi:
~~~~~~~~~~~~~~~
~ disable|enable (only w/ API)

NAT gw:
~~~~~~~~~~~~~~~
~  gwn|gws can be used only by rsrcs in gw's own VCN (!peered VCN or onP).   ~(gwn:VCN)=(>1:1), (sbn:gwn)=(>1:1)  ~gwn|gws: block/allow trfc 

gws:
~~~~~~~~~~~~~~~
~ enables access only to supported svcs in same region as VCN.    ~ gws = f(pub OCI infra svc)       ~ IAM policy = f(cidr,gws,bkt)

VCN peering:
~~~~~~~~~~~~~~~
~ loc|rem peering ∴ within|across region(s) same/diff|same tenancy. VCN1 <--> VCN2,VCN3: loc|rem peer ∴ !overlapping cidr bet (1,2,(1,3) |(2,3)      ~ stateless rules: ! con tracking (∴ beter perf), slow impact of DoS attack.
~ priv VCN1 <---> pub VCN2 ---> internet ∴ malicious host on internet --- (looks like src VCN2) --> VCN1.  VCN1 !--> dest outside of VCN1,2 (eg internet) but can use transit rtg.     
~ c8a: crt loc(LPG)|rem peering. rem peering con (RPC, on DRG) acts as a con pt for rem VCN.  ~expt, nmap rt: $ipOciReg-->140.91.$reg.x--> .. -->$ipVpnOnP. $ipOciReg1-->140.91.$reg1.x-->140.91.$reg2.-->$ipOciReg2

acs OCI-C:
~~~~~~~~~~~~~~~
#skp#

acs to other clouds w/ libreswan
~~~~~~~~~~~~~~~
~ c9a: AWS.   ~ point to site vpn: /data/.hs/dtb/scripts/ora/oci/vpn_libreswan.txt

nw perf:
~~~~~~~~~~~~~~~
~ #skip# SLA

troubleshooting:
~~~~~~~~~~~~~~~
~ ∃ stateful rule ∴ ICMP type 3 code 4 allowed

%%%%%%%%%%%%%% DNS
~ #skp# zn: part of DNS namespace. start of auth rec (SOA) defines zn. generally zn ={label underneath itself in tree}. eg in dtb/lc/dns/{named.conf,db.ke.dtb}       ~#skp# label: subdom. recs=f(label)
~ #skp#rsrc rec: specific dom info for zn.  eg, rec data(RDATA) of A/AAAA rec ⊃ {ip for dom}, of MX recs ⊃ {info f(mail svr for dom)}. OCI normalizes all RDATA into m/c readable format. returned presentation of RDATA may != i/p.    ~#skp# delegation: NS.  
~ zn ⊃ {trusted DNS recs that will ∈ OCI NS}.   ~delegating zn: w/ dom's registrar(from whois) (usually where ct purchased dom, eg godaddy(c8b),bluehost) ∴ pub zn.   
~ add zn rec.  ~P, add zn: prim (ctrl zn contents in OCI), sec (OCI pulls data from ext svr(allow OCI ip c9b), import. 
~ rec type(many skpd): P,ALIAS: priv pseudo-rec allowing CNAME fn at apex of zn.   P,PTR: ip -> hostname.  P,sender policy framework (SPF): spl TXT rec.  P,TXT: descriptive, human rdable text(!human for SPF & DKIM recs).     
~#skp# rec type(many skpd): P,addr(A|AAAA): hostname -> ipv4|6 ip. P,ALIAS: priv pseudo-rec allowing CNAME fn at apex of zn.  P,CNAME: canonical name(alias) for dom.  P,mail exchanger(MX): mail svr accepting mail for a dom; must point to hostname (! CNAME or ip). 
  P,NS: authoritative NSs for a zn.  P,PTR: ip -> hostname.  P:start of authority(SOA) ⊃ { prim NS, email of dom admin, dom serial#, diff timers relating to refreshing zn}. P,sender policy framework (SPF): spl TXT rec.  
  P,TXT: descriptive, human rdable text(!human for SPF & DKIM recs).     
~ reverse DNS (rd): P: for classless addr block (partial range of ips) Q: IP provider(ipr) hosts your ptr rec (PTR) ∴ !rd reqd.  Q: get exact syntax of rd hostname from ipr.  Q: crt & publish rd zn & PTR recs -> upd rd zn delegation w/ ipr (!dom registrar).  
   Q: cfg rd for classless addr block: ip 192.168.15.224/27 -> rd zn name (224-27.15.168.192.in-addr.arpa) (expt dig -x $ip).    Q: add CNAME rec ∀ host (if ipr does!). tell ipr to append CNAME ∀ host in OCI zn.   Q: A
  P: for full addr block. Q: ct ip(192.168.15.0) -> rd zn name (15.168.192.in-addr.arpa).  Q: A.  A: crt PTR ∀ host addr f(TTL (how long ext NSs will cc info about DNS rec, all PTRs same TTL), RDATA(enter CNAME (eg example.com) that PTR pts), hostname (web addr of zn)).  
~ zn fl fmt: P: only internet(IN) class rec ∈ OCI.  P: FQDN=<host label below origin(!ending w/ .)>.$origin_hostname.  P: $ORIGIN $origin_hostname <SOA rec>. SOA rec reqd ∀ zn. #skpSp# rec comps.  P,#skpSp#: import zn from godaddy, eg fl from godaddy -> amend.
  P, c9d, dig: $ns(+nslookup), short, trace($data..{hs: $data) recvd from $ns)), all recs, rev lookup, SOA, use search dom in resolv.conf. use dft tcp lookup in resolv.conf. 
   #add# https://linuxize.com/post/how-to-use-dig-command-to-query-dns-in-linux/:  dig +nocmd mail.google.com cname +noall +answer;
~ http redirect: P, crt,c9f: query: https://$dom.com/$path?$query 
~ TSIG (txn sig or secret key txn authn): sender -- DNS pkt ⊃ TSIG={shared secret key, pub key's 1way hashg algo to en|decr data} ∴ DNS auths upds to sec zns. adds sec for IXFR & AXFR txns. c9g: crt.
~ priv DNS:  P, zn: Q: within VCN. Q: -- duplicate zns across VCNs. Q: -- split-horizon DNS (ie same dom for pub & priv zns). ans =f(pub/priv query).      P: enable DHCP as a proto over LPG, RPC, fc, vpn.
  P, VCN -> resolver -> (order: vws -> dft vw -> rules(to fwd) -> internet DNS). vw={zn} ∈ region, resolver:vw = >1:>1 ∴ share priv DNS data across VCNs. resolver listens on 169.254.169.254(dft) + def lsng & fwdg (to resolvero in VCNO, onP, or priv nwO) endpts ∈ $VCN. 
   rule: query-dom|clnt-cidr=$dom|$cidr ∴ fwdg endpt --> ext-DNS. expt: clnt-cidr did! work.
~ trfc mgmt steering policy: P, comps: attachment(bet policy & zn ∴ resp = f(policy, !zn), case ∈ rule ∈ template.   P,c9e: failover|load-bal - PP -> SP. geoKey|asn|cidr : PP,dft -> SP. SP - svr:(pool,ip).  PP: pool->priority.  P: crt above policies.
  P,#skSp#: details of "crt steering policies using templates"
%%%%%%%%%%%%%% haproxy
~ P, cons are locally terminated by OS ∴ ∃ !relation bet both sides ∴ abnormal tfc (eg invalid pkts, flag combinations, window advertisements, seq nos, incomplete cons (SYN floods)) --!> sideO. 
  P, only valid complete reqs --> sideO. protocol deviations for which ∃ a tolerance ∈ spec are fixed ∴ they don't cause problem on svrs (eg >1-line hdrs).  P: it can modify/fix/+/-/rewrite url or any req or resp hdr.  P, req -> svr=f(element ∈ req)
  P: TCP|http LB decision for conn|req.  P:it can apply some rate limiting at diff pts, adjust trfc priorities(p) f(contents), --p--> lower layers & outer nw components by marking pkts.
  P: can maintain stats per ip, url, ck + detect abuse -> take action ((slow down, block, send outdated contents to) offenders).  P: nw issues ∈log.  P: can cmprs resps !cmprsd by svr,  P: may cc resps in RAM(!persistent storage). varnish cc save svr's rsrcs.  
~ P: sticks cons to same CPU as long as possible. 1 ps can run >1 proxy insts.
~ features: P: clnt authn f(crt) + configurable policies if ∃ !valid $crt.  P: dyn rec szg ∴ browser starts to fetch new objs while pkts are still in flight ∴ reduces page load time.  P: detect, log & block attacks even on SSL libs,
#start# 3.3.3. Basic features : Monitoring
%%%%%%%%%%%%%% load balancer(LB)
~ L4(tcp), L7(http). prim|sec LB ∈ AD1|2 ∈ $region. bknd = reachable inst.
~ #-cons to bknd w/ wt=3 =3* #-..=1. LB: P,TCP: (1st rqt) --> bknd f(policy, wt).  (later pkts on this con) --> same endpt.  P,http (ck-based ses persistence): (rqt) --> bkend f(ck's ses info).
  P, !sticky http: (∀ rqt) --> bknd f(policy,wt).    ~policy: round robin. least con (for TCP: ∃m active con w/o curr tfc). ip hash: bknd=hash fn(ipOfClnt). can! add bknd (marked as bkp) to bknd set w/ ip hash. 
~ c9o: >1 clnt-- >1 rqt -->LB--few con--> bknd. keep-alive bet (LB,bknd,n1) & (clnt,LB,n2) close. OR: bknd should! close con to LB. set idle timeout of lsnr bet 2 successive send/recv nw io ops during http rqt-resp (hs: & TCP) w/ clnt.
~ LB +,alter followg http x- hdr. P:x-fwdd-for: $origClnt, $proxy1, .., $proxyn. LB +s $proxyn.  P:x-fwdd-host: $bknd:$port.  P:x-fwdd-port: $LB-lsnr-port. P:x-fwdd-proto: $proto-used-to-con-LB-http(s).  P:x-real-ip. bknd acs log ⊃ LBip.
~ ses persistence(sp) of bknd set:  P: f(ip) ∴ !LB w/ proxy + !sp w/ dyn ip.
  P,sticky ck(http):  Q,appln: specify $ck + decide whether to disable fallback for !available svrs. works if bknd sends set-ck resp hdr ⊃ ck1 ∈ bknd set cfg(may ⊃*). LB --ck2=hash(ck1, rqt params)-> clnt. 
    ck1 changed ∴ LB --recomputed ck2-->clnt.  OR: treat $ck data as opaque entity. !use in ct appln. bknd -- set-ck resp hdr w/ past expiration dt ∴ $ck -d ∴ appln ck persistence stopped.
   Q,LB: LB--resp ⊃ $ck. set-ck hdr ⊃ ($attr,$val). R,c9c: $ck name.  R: attr=dom. RFC 6265: $val from www.eg.com =  S: [www.]eg.com ∴ clnt +$ck in ck hdr in http rqts to [www.[a.]]eg.com.  S: [www.]a.eg.com ∴  clnt !accept $ck
     S: null ∴ clnt returns $ck only for dom to which orig rqt was made.   R: attr=path. path of rqt-uri = (subdir of)$val ∴ clnt -- http rqt ⊃ $ck. dft: val=/.  R: attr=max-age. $val>=1s.  R: attr=sec. val=y ∴ clnt -- $ck w/ https
    R: attr=http only. clnt -$ck when providing acs to cks w/ !http apis(eg java script).  R: bknd !available ∴ persistent ses --> S,dft: bkndO.  S,$attr ∴ !fallback till clnt presents $ck ->(hs) bknd=f(path rt rule).       ~#skp# cfg changes causg outage
~ crt bknd set: specify (verify peer crt, max depth for crt chain verification).    ~ $bknd = P:drain ∴ LB stops fwdg new (TCP con & !sticky HTTP rqt) to $bknd. P: bkp ∴ LB fwds tfc to $bknd only when all other !bkp bknds fail health chk.
~ cipher suite = {cipher(ie algo)}. cipher uses transport layer sec (TLS) to determine sec, compatibility, speed of https tfc.  #skp#: supported ciphers, predefd cipher suites.
~ virt hostname(vh): vh(∈ DNS):(http(s))lsnr = >1:1. search order of vh: $dom, *$dom(wildcard crt), $dom*(>1 dom SAN crt)
~ req rtg rule(rrr): P: def order of rrrs.  P: rrr-set:http(s)-lsnr=1:>1. rrr={>1 cond, rt to $bknd-set}. !match ∴ -->dft bknd set.  P,match type for Q,http headers, query data params, cks: ⊃($key,$val), ∃ $key.  Q,path: =, ^$str.*, .*$str$. {!}$type. 
  P: cond1 AND/OR cond2. P: 1 level nested cond.  #skp# rtg policy language.  ~exact(^$str$), pfx(^$str.*), longest pfx($str.*), sfx(.*$str$)) match
  #add#: cond-type-req-hdr  key:User-Agent  val:  /Mobile|iPhone|iPod|iPad|Android|BlackBerry|IEMobile|Kindle|NetFront|Skyfire|Zune/ !regex(SR# 3-27285291181)
~ #2retire# path rt rule(http(s)): path:bknd-set. OR: path=/$p & /$p/. rule={string,(exact(^$str$), pfx(^$str.*), longest pfx($str.*), sfx(.*$str$)) match. 1 path rt set(={path rt rule}) /lsnr. priority of rules ∈ set: exact, longest pfx, pfx, sfx. LB chooses 1st 
  matchg pfx or sfx rule ∈ set.
~ rule set(rs): P: apply only to http lsnr.  P: rs:(lsnr in 1 LB)∴1:>1. P,rule: Q: ACL=f(cidr).  Q,c9h, http acs method: 1 method-list ∈ lsnr.  
   Q,c9i,url redirect: f(match cndn(exact,pfx,sfx,longest pfx),path) ∴ (redirectedUrl(ru),resp code). ru=$proto://$host:$port/$path?$query. token(case-sensitive): {var} ∴ $var∈incomingUrl. ru=null ∴ redirect loop.  specify resp code of ru.
#^#on
   Q, http rqt & resp hdr: R,c9n: +,-, extend.  R: -- metadata ⊃{lsnr, SSL terminatn} --> bknd.   R,c9m: bknd(eg weblogic) may need notification of ssl termn.  R,c9q: list of hdrs.
    R,sec: + hdr: S: ext dom can! iframe ct site. S: https only  S: !cross-site scripting(xss).  S: attack f(content type shifting).   - hdr: S: hide implementation(eg svr) details of bknd. !+/- built-in host hdr or http X-hdr.    Q, http hdr: sz(<=64k)& chr(.,_)
~ SSL crt: {pub crt, priv key, crt auth(CA) crt}. LB geny use 1 dom crt. rqt rtg cfg in lsnr may f((sub alt name (SAN) (>1 dom), wildcard) crt). self-signed crt for bknd SSL ∴ same crt for CA. OCI accepts x.509 type pem crt. c9j: ->pem. cat $crt $crtCa >>$crtChain.pem. 
  OR: 2048 bits priv key(hs: ct gens w/ ssh-keygen). c9k: validn, chk expiry dt. c9l: OCI !recognize priv key ∴ decr -> upload.  lsnr,bknd set f(crt).           ~ SSL: P: end to end SSL = {terminate SSL(clnt(c)->LB), bknd SSL(LB->bknd)}     
~ #skp# P: supported ciphers.  P: lc, P: metrics
~ expt: P: onP--VPN-->LB-->gws-->OCI-svc + LB: lsnr & bknd (tcp,443) + bknd={OCI-svc-ips} + onP DNS: OCI-svc:LB-ip ∴ ! onP fw rule to divert & whitelist tfc to VPN for OCI pub cidr + !chance of pub internet if ip of OCI-svc changes.
  P:  health check: resp code: 404(!found), path: /, port: 0 (uses bknd's tfc port).    P: Q: health chk: proto: http, port: 43501, uri: /console/login/LoginForm.jsp (no redirection).   Q, bknd: ip: $ipBkendSvr, port $prt#    ~cdb: UDP LB: lin virt svr (LVS, ipvsadm)
%%%%%%%%%%%%%% nw LB
~ L4 (TCP(+ http(s))/UDP/ICMP).  LB ∈ region, HA for 1 AD outage.       ~ used as next hop rt tgt (L3) w/ transit rtg.     ~priv LB consumes 1 prip.   ~TCP,UDP,http health chk.  
~ LB policy: (((ipSrc,ipDst),proto),prtSrc,prtDst) tuple hash. dft 5. ses affinity: 5, beyond lifetime of ses: 2,3. wt.
~ LB tracks state ∀ TCP & UDP flow. flow-(ipSrc,ipDst,proto,prtSrc,prtDst). idle timeout: P,TCP: 6 mins, pkts dropped.  P,UDP: 2 mins, next pkt is new flow + rtd to new bknd..
~ optional: pkt (orig src & dest hdr (ip & port), !NAT) --> bknd. upd rtt. skip src dest chk auto on.   ~bknd ∈ compartment.   ~LB insts: prim & stdby. hs: both doing health chk.  ~proto(TCP,http(s)):lsnr=(1:>1)  ~lsnr: TCP,UDP,TCP/UDP, any port.
~ expt: UDP health chk f(req,resp data)
%%%%%%%%%%%%%% WAF
20211201:
~ WAF is payment card industry (PCI) compliant,    ~allow|chk action: ( |!) skip all remaining rules in curr module.
~ each rule accepts JMESPath expr as cond. http reqs/resps (f(type of rule)) trigger WAF rules. fw is logical link bet WAF policy & enforcement pt(eg LB).  ~nw addr list:  P: ={ip: used by WAF policy}.  P,type: addr(∈ internet, vcnLb}, vcn addr(∈ vcnO).
~ http req/resp(r) --[trigger]-> rule = f(cond = JMESPath expr) -> json doc={r} ∴ (!)action. (!)==,>,>=,<,<=,∈,^,$,&&,||,keys,length. case-insensitive ==,∈,^,$. fn: ip ∈ cidr,nw addr list; ipWVcnId ∈ nw addr list.  ~ keys,length (req|resp hdr, req query,ck)
~ policy mgmt:  P,pre-cfgd action(pca):  Q(A),allow: skips remaining rules.  Q(A),chk: !stop, logs.  Q: 401 resp code.  A,src: waf concepts > action.   P,acs ctrl rule: req,resp f(cond, pca).   
  P,rate limit rule: cond. #-reqs(r) from unique ip <= limit(l). duration of r|(action after l reached). pca.
  P,protection rule(pr): Q: req f(cond, pca + new action f(hdr, resp (code, body(A))), protection capability={key#, name, collaborative status, tag(hs: eg CVE#), action}). A,eg: {"code":"403","message":"Forbidden"}. resp.  
   Q: exclusions f(req ck val, arg (query param or post/put data)).  Q: collaborative pr ={pr}, use scoring & trd to evaluate trfc.  Q: some prs can! be excluded.  Q:#skp#: pr list.  
   Q: protection capability settings: allowed http methods, max (http req hdr len, #-hdrs, #-args, single/total arg len),     P,enforcement pt: LB
#start# 20211201, p5920 Listing Network Address Lists
20210728: 
~ origin = internet facing endpt (eg LB puip) of appln protected by WAF. WAF policy = {dft origin, optional http hdrs & vals to pass to origin ∀ reqs}. WAF is PCI compliant. 
~ for https: pub crt f(fqdn of appln), priv key (pem), full chain crt (root, intermediate, origin svr). ssl crts can only be applied to main appln of policy.   ~policy f(prim dom(=fqdn of appln), subdom(wildcard dom allowed w/ cli))
~ OCI upstream timeout =300s ∴ origin's keep alive timeout >= 301s. csa: test upstream/origin keep alive timeout w/ telnet(80) & openssl(443). 
~ policy: P,crt: cat $crt $crtIntermediate >>$crtChain.pem.  P: http to https redirect.  P: svr name indication (SNI) = extension of TLS proto, which allows >1 secure hostnames to be served from 1 ip.  P: bfrg of resp from origin.  P: auto content ccg f(resp cc-ctrl hdr).
  P: allow collection of ip from clnt req if WAF is cond to CDN.       publish changes.
~ csb: test appln w/ curl f(resolve $wafPolicyDom:80/443:$ociWafIp), openssl(∴ crt validity dts).  ~upd DNS: cname -> cname-tgt(got from waf policy).  ~origin's ingress rules f(waf cidr ∈ oradoc).    ~ echo $strIn | openssl base64 -> $strOp; base64 <<< $strIn;
~ enable rules in detect mode: P: protection.   P, acs: ipSrc(hs), user agent.  
  P:BOT(javascript(js)|human-interaction(hi)|dev fingerprint(df) challenge):  Q: trld(t, #-failed-reqs) bef taking action. asyn req from browser during page loading ∴ OR: set t = 10|100 for apps w/ basic|heavy ajax usage.  
   Q,js: action=block + action-trld=at + at+1 reqs from clnt !acceptg js <= action-expire-time ∴ at reqs --> origin + 1 block action ∈ log.  Q,hi: secs,interactions bef t expires.  
   Q,js,hi,NAT support: user is identified by ip & hash. OR: disable for high-load apps (200+RPS).
   Q: action expire time (et,secs) bet challenges to same ip. client ip changes ∴ OR: set et=120|3600 for mobile|desktop apps.  Q,js: redirect resps from origin will be challenged.  Q,hi: secs to record user's events.  
   Q,hi: mouse movements, time on site, page scrolling  Q,df: gens hashed signatures of virt & real browsers. Q,df: max #-ips ∈ list -> action. #-secs ip ∈ list -> remove.
   Q,CAPTCHA: can customize comments for challenge ∀ url. out of reach of computer vision & OCR.  P,good bots ∈ log w/ bypass action. 
  P,test rules: fqdn?id=<script>alert("TEST");</script> w/ browser-used-in-testing-appln, browserO -> (2 entries for protection rule triggered by cross-site scripting req + 1 entry for detecting user agent & ip) ∈ policy-log
~ csc: order of processing rules & handlers.  ~ policy: P: f(prim(fqdn) & sub dom of tgt appln, origin).  P: crtd ∴ CNAME tgt(hyphenated-fqdn.OCI-dom (eg, myapp-mydom-com.oraclecloud.net) gend.  ~pending(!published) changes do! persist across browser sess. 
~ origin gr={origin: ∃ wtd LBg}
~ health checks (for >1 origins): url,interval,timeout, (un)healthy trld(#_failed|successful checks for origin is marked down|up), resp code, resp text, host hdr(dft, policy dom), user-agent.  ~LB on origins: ip-hash(wt), RR(wt), ck
~ protection rule(pr): P: req (ck,param,post/put data) to exclude(csd), block action, why blocked, max #-args, max (total)len of name & val of arg(s), days to analyze recommended actions, allowed http methods. arg ∴ query & body params in put/post req
  P,collaborative pr: Q: {pr: 3 elements of http txn must match against individual pr}.  Q: exclusion added ∴ it applies ∀ pr.  P: resp body inspection.  P, !exception: Q: since it f( (!)∃ element)  Q: REQUEST_{URI|PROTOCOL|HEADERS} ∈ log.
~#skp#: P: rule id.  P: custom protection rules
#start#: 20210728 p5223 IP Address Lists
#add# OCI nw arch: https://www.oracle.com/a/ocom/docs/oracle-cloud-infrastructure-security-architecture.pdf
%%%%%%%%%%%%%% email delivery svc
comps:
~~~~~~~~~~~~~~~
~ AS=f(compartment, region)  ~suppression list of recipients.  ~publishes $SPF to $DNS -> $SPF ⊃ hosts allowed to send mail on behalf of $DNS -> receiving mail svrs check $SPF ⊃ email's src ip
~ crt AS in region($rg) where svc is available -> choose any region for smtp credentials($sc) -> cfg appln to send email to $rg w/ $sc.        ~#skip#: svc capabilities & limits.    ~caa: crt smtp creds, crt AS, add/crt SPF in DNS.  ~cac: postfix.
~ email delivery > email cfg > displays smtp creds, svr, port, TLS(y/n).       ~ #skip#: smtp endpts, TLS reqmts.            ~ email delivery > suppression list > add email
~ single|double opt-in (un| confirmed(1)) to mailing list.  1: owner clicks link in confirmation email.    #skip: Canadian Anti-Spam Law (CASL)    ~cd: lc
%%%%%%%%%%%%%% sec zn(sz)
~ sz =f($cmp, $recipe={policy}). rsrc,data: sz --!-> std cmp. rsrc ∈ sz ∴ its coms ∈ sz. regular & auto bkp.
~ sz=f($cmp w/ same name). recipe:sz=1:>1.  ~sz: rsrc|data must be encrd f(ct-mngd key)|(in transit & at rest).
 ~#skp#: policies to restrict rsrc (movement, association)
#start# 20210616 p4512 Ensure Data Durability
%%%%%%%%%%%%%% k8s, v1.23
~comps: P,ctrl plane: Q,api svr: exposes api, scale horizontally.  Q,etcd: consistent & HA key val store of ctr data.  Q,scheduler: for pods. f(rsrc reqd, hw/sw/policy, (anti-)affinity spec, data locality, inter-workload interference, deadlines).
  Q,ctrlr mgr:  ctrlrs: R,node: node down -> notice & respond.  R,job: watch for job objs for one-off tasks(t) -> crt pods for t.  R,endpt: populates endpt obj (ie, joins svcs & pods).  R,svc ac & token: crt dflt acs & api acs tokens for new nss.
  Q,cld-ctrlr-mgr: ctr<-->$mgr<-->cld provider's(cp) api. ctrlr f(cp). R: node.  R,rt: set up rt in cld infra.  R,svc: crt, updt, - cld LB.
 P,node: Q,kubelet(∀): ensures ⊃rs(∈ podspec) running in pod.  Q,proxy(∀): maintain nw(pkt filtering) rules.  Q,⊃r runtime: eg docker, containerd, CRI-O, any implementation of k8s ⊃r runtime interface(CRI).  
 P,ctr addon: Q,DNS for ⊃rs.  Q: dashboard.  Q: ⊃r rsrc mong recs generic time-series metrics about ⊃rs in central db + -- UI for browsing data.  Q: ctr-level logging savs ⊃r logs to central log store w/ search/browsing interface.
~obj: P:={appln, reqd (node, rsrc, policy(restart, upgrade, fault-tolerance)) of $appln}.  P:={spec, status}.  P,crk: obj yaml fl={kind(deployment), name, #-replicas, image, port} -> apply.  
 P,crl: ∀ obj cfgFl ∈ configs dir + crt/patch (∴ retains changes made by wrrO, even if $changes !merged w/ obj cfg fl) live objs -> diff (∴ changes to make) -> apply.  P: unique obj kind+name. obj UUID.  
 P,crm,ns: ={rsrc: eg deployment,svc (!ctr-wide obj (eg. storageclass, node, persistent vol), unique name}. list curr nss. dflt,sys,pub,node-lease={lease obj ∀ node: kubelet--heartbeat->ctrl plane} ns. ns ∈ cmd or set ns for next cmds.
  crt svc ∴ DNS entry $svc.$ns.svc.cluster.local crtd. list rsrcs (!)∈ ns.  P,crn,field-selector: eg status,ns.  P,finalizer: nsd keys ∴ wait until $condn met -> fully -s rsrc.  P,obj metadata ⊃{owner ref, block -owner}
~ctr: P,cro,node: k8s crts node obj f(manifest) -> k8s checks that kubelet has regd to API svr matching metadata.name -> (un|)healthy node ∴ (continues checking | run pod). unique node-name ∴ $node. desc: hostname,ip(ext,int),
~#skp#: api, labels & selectors, annotations, finalizers, recommended labels
 #start#  ctr > node > Node status           ctr admin > loging
%%%%%%%%%%%%%% OKE
~ ctr={ 3 (for HA) ctrl plane nodes, data plane (pool of worker) nodes}. ctrl plane ps: kube-apiserver(for kubectl etc), kube-ctrlr-mgr (for (repln, endpts, namespace, serviceaccounts) ctrlr etc), kube-scheduler, etcd (stores ctr cfg).  k8s api endpt.
  P: worker node (wn)runs appln, kubelet(to talk to ctrl plane), kube-proxy (to maintain nw rules).  P: ctr ctrl plane pss mon & record state of wns + distribute rqtd ops bet them.   P: wns ∈|!∈ $pool ∈ ctr have same|diff cfg. wn pool cond to wn sbn.  
  P: pod={⊃r ∈ appln ∈ wn: share nw-namespace(ns) & storage-space + can be managed as 1 obj by ctrl plane}.  P: svc ={($pod w/ same fn: determined by selector), (policy to acs $pod)}. ct may expose svc on ext ip !∈ ctr. svc type: eg LB type crts LB ∈ LB-sbn.
  P: k8s manifest fl(pod spec or deployment.yaml etc) is yaml or json fl ={instructions to deploy appln to nodes in ctr, info about k8s deployment, svc, other k8s objs to crt on ctr}
  P: admission ctrlr(AC) intercepts authenticated & authorized reqs to k8s api svr bef admitting obj (eg pod) to ctr. AC can validate &/ modify obj. many adv features in k8s =f(enabled AC). AC =f(k8s vrsn). 
     crt ctr -> enable pod sec AC -> crt pod sec policies, roles/clusterroles, rolebindings/clusterrolebindings ∴ ops of pods f($policy) 
  P: namespaces(ns) divide ctr's rsrcs bet >1 users. initial ctr ns: Q,dft: for rsrcs w/ !other ns.  Q,kube-sys: for rsrcs crtd by k8s sys.  Q,kube-node-lease: for 1 lease obj per node to help determine node availability. Q,kube-pub: for rsrcs acsible across ctr.
~ cidr of ctr VCN {sbn of k8s API endpt(kae), wn, LB} should! overlap w/ cidr of pods & svcs.  wn sbn, kae sbn, gws ∈ ($vcn, $cmp). wn, kae --> internet, gws. gwi & gws ∈ $rtt ∴ may asym rtg.  ~sbn: kae, wn, LB(>=0).  ~ctr needs 1 ip ∈ kae sbn ∴ /30 cidr.  
~ wn name(do !change): oke-c$idCtr-n$idNodePool-s$idSbn-$slot, id=ocid-pfxd-w/-c|n|s.  ~ crd: crt k8s $cfg. ocicli cmd: ∈ $cfg--[dyny gens auth token(t)]-->[t ∈ $cfg]. t=f(short time,ctr,usr). kubectl f(t). crf: for toolO: crt svc ac -> its auth token ∈ $cfg.
~ kubectl drain $wn ∴ prevent new pods from starting + del existing pods.  ~-ctr ∴ (eg) VCN, gwi, gwn, rtt, sec list, LB, bl vol !-d.  
~ vw appln log: enable mong + chk cloud agent + crt $dyn-gr = {rule: $wn is tgt host} + crt policy for $dyn-grp to allow tgt hosts ∈ $dyn-gr to push logs to OCI logging -> def (custom logs & agent cfg f($dyn-gr, log path)). steps skpd
~ k8s dashboard: P: deploy manually ∴ dashboard ∈ kube-dashboard ns.  P: url(cre).  P,OR: don't install on prod for sec.  P,#skp#: acs  ~crg: deploy sample nginx appln.  ~crh: crt docker registry secret.
~ cri: image to pull from OCI registry & docker secret ∈ appln's manifest fl.  ~crj,label: AD, fault dom ∀ wn,pod. exclude wn from list of bknds ∈ bknd set.
~ autoscale: P,pods: wn --rsrc metrics--> metrics svr.  P,node pool: f(rsrc req (!utilization)). cfgFl={$node-pool, min/max sz, how}. rsrc req limits should ∈ pod spec. 
~ #skp# sec list cfg, enforcing use of signed images from registry, encrg k8s secrets at rest in etcd, using pod sec policies.
#start# 20211201 p1465:  Recommendations when using the Kubernetes Cluster Autoscaler in Production Environments
%%%%%%%%%%%%%% vmware soln
~ comps distributed across diff FDs ∈ AD. vsan replicates data across all esxi hosts. ∃ vlan ∴ L2 nw. ct esxi on BM !supported.
~ P: vsphere manages cpu, storage, nw = {esxi hypervisor, vcenter svr}. P: NSX-T for virt nwg & sec = {NSX mgr unified appliances w/ NSX-T loc mgr, NSX-T ctrlr, NSX-T edge nodes}. P: vsan -- 1 shared datastore for vms.  
  P: hybrid cloud extension(HCX) for appln migrn. HCX mgr --> gwn --> vmware saas. ∃ SDDC + change(c) in vmware vrsn, ssh keys etc ∴ c applies to new esxi hosts + manually upd old hosts w/ vcenter. 
~ vsphere 6.5/6.7 -> 7.0: new vsphere 7.0 SDDC + migrate w/ HCX.  ~ use vcenter to crt & manage workloads.  
~ cfg SDDC: P: min cidr /21. OR: con onP.  P: SDDC crtd ∴ can! enable HCX.  P: choose vmware (ie vsphere) vrsn. pub key to con esxi hosts.  P: mgmt-cidr/#-segs-for-sbn-&-vlans. vsphere-vlan-seg/vsphere-&-HCX. / ∴ divide
  P: vlan gw cidr -- (ip ∀ vlan's L3 trfc + prip OCI uses as attachment objs for puip).  vlan for Q: NSX edge uplink 1 (trfc bet SDDC & OCI)  Q: NSX edge VTEP (data plane trfc bet esxi host & NSX edge)  Q: NSX VTEP (data plane trfc bet esxi hosts).  
   Q: vmotion (migrn tool)  Q: vsan  Q: vsphere  Q: replication-net (vsphere replication engine).  Q: provisioning-net (vm cold migrn, cloning, snapshot migrn).   P: HCX
  P: crt initial logical seg_(>= /30) for SDDC workload(vms). $seg must! overlap w/ VCN or SDDC cidrs. SDDC crtd --> ct can +nw segs for SDDC in NSX mgr.  P: SDDC crtd --> vcenter usr/initalPswd showed.
~ NSX edge uplink1 vlan(workload cidr) --> onP/OCI svc/gwn/VCN. rtt of uplink1 vlan.    
#skp: HCX license types, billing options., addl doc
#start# 20210616 p4902:  To add an ESXi host to an SDDC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% openstack:
####
src: https://docs.openstack.org/neutron/latest/     https://docs.openstack.org/neutron/latest/admin    upgrade: https://docs.openstack.org/operations-guide/ops-upgrades.html
 packstack: https://wiki.openstack.org/wiki/Packstack
## equiv terms, (OS,OCI,AWS,azure): (AS/sbnp,VCN,VPC,)
# compute: nova, nw: neutron, bl storage: cinder, identity: keystone, image: glance, obj storage: swift, dashboard: horizon, orchestration: heat, workflow: mistral, telemetry: ceilometer, db: trove, elastic map reduce: sahara
  bare metal: ironic, messaging: zaqar, shared fs: manila, DNS: designate, search: searchlight, key manager: barbican, ⊃r orchestration: magnum, root cause analysis: vitrage, rule-based alarm actions: aodh
####
feb2020
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_openstack_platform/7/html/upgrading_openstack/chap-upgrade-all-at-once
# basic nw:
  ~ https://en.wikipedia.org/wiki/OSI_model
    OSI model(OS): 1,phy:         2,data link: ethernet,swt       3,nw: ip,rtr,puip.          4,transport: TCP/UDP/ICMP            
     5,ses:         6,presentation:             7,appln:
                                                                                            OSI model
          layer         Protocol data unit (PDU)                                                                   Function^[11]
        7 Application                           High-level APIs, including resource sharing, remote file access
 host   6 Presentation Data                     Translation of data between a networking service and an application; including character encoding, data compression and encryption/decryption
 layers 5 Session                               Managing communication sessions, i.e., continuous exchange of information in the form of multiple back-and-forth transmissions between two nodes
        4 transport    seg, datagram            reliable transmission of data segs bet pts on nw (eg segmentation, ack, multiplexing)
 ------ 3 nw          packet                   structuring & managing >1 node nw (eg addring, rting, trfc ctl).  OS: IP.
 media  2 data link    frame                    reliable transmission of data frames bet 2 nodes cond by phy layer.  OS: ethernet
 leayer 1 phy          symbol                   transmission & reception of raw bit streams over phy medium

  ~ #skip#ethernet ∈ layer 2 (L2, data link) of OSI model.
  ~ bcst: 1 host sends a frame to every host on nw by sending to MAC ff:ff:ff:ff:ff:ff.
  ~ NIC receives an ethernet frame ∴ a. by default, NIC checks if dest MAC = its MAC  (or bcst addr) --!match--> frame discarded.   b. NIC in promiscuous mode, pass all frames to OS.
  ~ frame destined for unknown MAC ∴ swt bcsts frame to all ports -> swt learns MAC of ports by observing trfc -> swt sends frames to correct port (!bcsting) -> fwdg info base (FIB) in swt = {mapping of MAC to port}
  ~ acs port: swtport cfgd for a VLAN.    ~ trunk ports = ports for cross-coning swts w/ same VLAN ids: any VLAN -- tag frame w/ VLAN id --> swt1. OS: swtport = trunk port
  ~ 1st time hostA -> hostB in same nw (arping -I eth0 $ipB): To: ff:ff:ff:ff:ff:ff. I am looking for IP $IPB. Signed: MAC $MACA. --> To: $MACA. I have IP $IPB. Signed: MAC $MACB. --> A sends frames to B --> upds ARP cc (arp -n)
  ~ dhclnt: UDP pkts,  P: DHCPDISCOVER on br0(port 68) to 255.255.255.255(local nw bcst, !fwdd to nwO (∴ DHCP svr ∈ local-nw)) port 67 :  I’m clnt at $macc, I need IP
    P: DHCPOFFER from $ips:  OK $macc, I’m offering $ipc.  P: DHCPREQUEST on br0 to 255.255.255.255 port 67:  $ips, I would like to have $ipc.  P: DHCPACK from $ips:  OK $macc, $ipc is yours.  P: bound to $ipc -- renewal in $n secs.
  ~ TCP: P,ephemeral port (ep): os of TCP clnt auto assigns ep to clnt. P: wr stream of bytes (sb) to a fl. P,os: breaks up sb into pkt, retransmits dropped pkts (∴ TCP , ensures transmitted data <= 
    (sender/receiver’s data buffers, nw capacity).  receiver os: re-assembles pkts in correct order into sb. P: ps1|2 TCP|UDP port# n at same time.
  ~ UDP:  P: eg: DHCP, DNS, NTP, virt extensible LAN(VXLAN). P: can bcst.  P, ip mcst: receiver applns (need !be on sender's nw) join mcst gr by binding UDP socket to mcst gr ip. rtrs need to support mcst rtng. VXLAN uses mcst.
  ~ ICMP: for sending ctl mesgs. eg: rtr recvs pkt -> P: !rt to dest ip ∴ rtr sends ICMP code 1 (dest unreachable) to src. P: too large pkt ∴ ICMP code 4 (frag,lnt29l).
# nw comps: ~ swt|rtr: fwd trfc f(dest eth addr | ip) in pkt hdr.
# overlay (tnl) prtls: ~ generic rtg encapsulation (GRE) prtl: runs over ip + used when delivery & payload prtls are compatible but payload addrs are incompatible. eg: payload might think it is running on L2 but it is actually running on L4 w/ datagram prtl over ip. 
   crts priv pt-to-pt con + works by encapsulating payload. is foundation prtl for tnl prtlO. -- weak authn.  ~ VXLAN: allows overlay (VXLAN seg) L2 nw to spread across >1 underlay L3 nw domains. only VMs within same VXLAN seg can communicate.
  ~ generic nw virt encapsulation (GENEVE): defines content of metadata flexibly that is added during encapsulation + tries to adapt to diff nw virt scenarios. uses UDP. is dyn in size w/ extensible option hdrs. supports b|m|ucst.  # nw namespace.          
# NAT: ~ RFC 1918, priv ip: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16. pub internet can! send pkt to these ips.
# OS nw: ~ prn: L2. optional support for DHCP & metadata svcs. con or map to existing L2 nw in DC w/ VLAN tagging.   ~rtd prn: L3. maps to >1 L2 segs(prn) in DC. ∃ rtr ∀ seg.
  ~ ssvc (virt) nw: P: enables !privd projs to manage nw w/o admin. -- DHCP & metadata svcs to insts. supports VXLAN or GRE as they can support more nws than L2 segn w/ VLAN tagging.  P,IPv4|6: uses (RFC1918 prip | puip). <--> prn w/ (SNAT | static rts) on virt rtr.    
  ~ sbnp: pre-defined pool of ips from which to crt sbns w/ auto allocation.
  ~ sec grp: dft rules:  P: egress trfc uses src MAC & ip of port for inst, src MAC & ip combination in allowed-addr-pairs, or valid MAC addr (port or allowed-addr-pairs) + linked EUI64 link-local IPv6 addr ∴ allow egress.   
    P:  allow egress DHCP discovery & req mesgs that use src MAC of port for inst & unspecified IPv4 ip (0.0.0.0).  P: allow ingress DHCP & DHCPv6 responses from DHCP svr on sbn. P: deny egress DHCP & DHCPv6 responses to prevent insts from acting as DHCP(v6) svrs.
    P: ..IPv6..   P: allow egress !ip trfc from MAC of port for inst & any addl MAC in allowed-addr-pairs on port for inst.
    separate ARP filtering rules(r1) prevent insts from using ARP to intercept trfc for instO. can! disable or remove r1.      ~ LB w/ HAProxy
  ~#skp#: P: API svr, plug-in & agents, msg queue. P: policy.json params.
mar2020:
# FWaaS: 
  ~ fw gr ={(in,e)gress policy}. policy =ordered {rule}. pub policy is shared across projs. fw driver: iptables, OpenVSwitch f(flow entries in flow tabs), cisco manipulates NSX devs. fw gr applied at port level, L3|L2 fwg at rtr|VM ports.
# svc&agent: ~ntrn svr(ctrlrs): -- API endpts + serves as 1pt of acs to db. ~L2 agent(compute & nw nodes): use OpenVSwitch, lin bridge etc -> nw segn for proj nw. ~L3 agent(on nw node): -- east-west&north-south rtg,fwaas,vpnaas etc.
  ~ both svcs & agents may load ntrnc ⊃ {oslo.messaging cfg for internal ntrn RPCs, host specific cfg (eg fl path), (db, keystone, nova creds, & endpoints strictly for ntrn-svr to use}}.   ~ #skp#: P: cfg options, ext ps run by agents.   
# addr scope(AS): ~ AS shows where addrs can be rtd bet nws(hs: sbn).  ~AS ⊃ {sbnp}.  ~add >1 sbnp to AS if sbnps have diff owners ∴ !addr overlap in AS.    ~rtr marks trfc from each ifc w/ its AS.   
  ~ cea, admin: crt AS, sbnp f(AS,cidr). list,show sbnp.  ~ceb, !privd: crt nw -> crt sbn f(nw,cidr), sbn f(nw,sbnp) -> show nw -> add rtr f(sbn).
#^#c
  ~ inst1|2 in nw1|2. (+hs): fip of inst1 = prip of inst2. ping fip works from ext nw !f(AS). AS of inst1|2 !=|= AS of ext nw ∴ ping $pripInst1|2 !| works (even w/ rt). rtr NAT to cross AS.
# auto allocation of nw topologies: ~cfa: set up dft ext nw -> crt dft sbnps -> crt/get nw topology, o/p ⊃ {nw id} -> crt vm f(nw id) -> !nwId + ∃ >1 nw ∴ nova will invoke API behind auto allocated topology crt, fetch nw UUID 
  + pass it on during booting.  -> validate that reqd rsrcs are correctly set up for auto-allocation
# availability zone(AZ): ~ grs nw nodes (for HA) running DHCP, L3, FW etc.  ~cfb: cfg AZ for agent.  ~cfc: crt nw f(AZ). AZ is selected from $cfgFl if rsrc is crtd w/o AZ hints. list AZs. nwg svc schedules rsrc -> show AZ of a rsrc.
  ~ cfd,cfg: AZ aware nw & rtr scheduler, L3 & DHCP HA.  ~#skp#: reqd extensions.
may2020:
#cgj: bgps acts as rt svr using BGP.
#bgp dyn rtng(bgpDr): ={svc plug-in(implements nw svc extension), agent(manages bgp peering sess)}. 
 ~eg cfg:  P,cga, ctrlr node: enable L3 & bgpDr svc plug-in. P,cgb, agent node: cfg driver & rtr id.  P: crt AS(AS1). crt sbnp for prn & ssn f(AS1,cidr)(AC1).  
  P,cgd: crt prn,ssn. crt provider,ssvc sbn f(nw,sbnp). crt ssvc sbn f(nw, cidr !∈ AS)). P,cge: crt rtrs. ∀ rtr, add 1 ssvc sbn as ifc on rtr(AC2). add prn as gw ∀ rtr(AC3). 
  P,cgf: crt bgps. add bgps to prn (AC4)(this builds list of rtrs ∴ bgps can advt ssn pfxs w/ corresponding rtr as next-hop ip).  crt bgp peer. hs: peer-ip ∈ ssvc sbnp. host w/ bgp agent must have L3 con to provider rtr. ->  add bgp peer to bgps.  
  P,cgg: schedule bgps to bgpDr agent.  P: bgpDr advts pfxs for ssns & host rts for fip if AC1,2,3,4, cgc. fip is advtd if rtr w/ fip binding has AC3,4, cgi.
  P, ops w/ distributed virt rtr (DVR), cgh: (dest : next hop)=(ssn : SNAT gw fip), ((supporting fip of prn | prip of inst): puip agent gw)
# DNS integration: ~cha: assign dns (domain, name) to port. 
# DNS resolution for inst: P,case 1: each ssn uses unique DNS resolver(s)(DR): DHCP agent offers >=1 unique DR to insts via DHCP ∀ ssn.  cia: crt sbn f(DR), add|remove DR to|from sbn.  DR-ip=0.0.0.0 ∴ !DR.
  P,case2: DHCP agents fwd DNS queries from inst to (DHCP agent (!DR) resolves insts in ssn) Q,cib: an explicitly cfgd DR(s) in DHCP agents.   Q,cic: DR(s) cfgd in resolv.conf of host.   
# fip port fwd: cja,TCP/UDP/other port: puip --[fwd trfc] --> prip. rtr svc plug-in manages fips & rtrs ∴ cfg it along w/ port-fwdg svc plug-in.  #ip mgmt(IPAM) crts driver framework for (de)allocation of sbns & ip.   #MTU: cka,jumbo frames. DHCP agent -- MTU to insts.
# nw seg ranges: cla: set of dft ranges crtd f(vals ∈ ML2 cfg fl).  clb: enable & verify nw seg range svc plugin in ctrlr node. clc,admin: list ranges, show a range. cld,admin: crt or upd range f(prj,sharedYN).  prj1: crt tenant nw. priv > shared.       
jun2020:
# OVS h/w offloading, SR-IOV > (crt VF, cfg allow list): ~ PF: phy fn. phy eth ctrlr that supports SR-IOV.  VF: virt fn. virt PCIe dev crtd from PF.  representor port(repp): virt nw ifc cf SR-IOV port that represents nova inst.
 ~ enp3s0f0: PF + ifc for VLAN prn + has access to priv nw ∀ node.  ~ enable SR-IOV: P: recommend using VLAN prns for segregation ∴ we can combine insts w/ & w/o SR-IOV ports on 1 nw.  physnet2 = prn.  ~ cma: enable SR-IOV & VT-d -> pci passthrough in grub -> crt VF.   
 ~ cmc: cfg offloading in PF.    ~cme,cfg node (VLAN|VXLAN): ctrlr,compute: cfg V(X)LAN driver, pci passthrough. VF: trusted ∴ promiscuous. 
 ~ validate offloading: cmh,crt trusted port direct on priv nw(porti). i=1,2. -> cmi, crt inst vmi f( porti, computei) -> vm1: ping vm2 -> compute2: cmj, find repp. -> compute2,cmk: tcpdump on repp ∴ 1st ICMP pkt, rest offloaded.  ~#skp# supported eth ctrlrs, prereqs.
# cna, native OVS fw driver.     
jul2020:
# rtd prn: ~ enables 1 prn to represent >1 L2 nws (bcast domains) or segs.  L2(swtg)|L3(rtg) handles transit of trfc bet (ports on same seg | segs).  seg:sbn=1:>1. 
 ~ seg={unique phy nw name, segn type, segn id}. operator must implement rtg among segs. (host,rack,phy nw)={compute01, rack1, seg1),{compute02, rack1, seg1),..,{compute11, rack2, seg2),,{compute12, rack2, seg2), >=1 (DHCP agent)/seg. 
   IPv4: nwg svc(authn creds,cob) --I={ip} ∀ seg --> compute scheduler’s placement API [inst ∈ host w/ seg w/ I].  ~coa: ntrnc f(seg plugin) ~nw or compute nodes: cfg L2 agent on each node to map >=1 segs to appropriate phy nw bridge or ifc.
 ~ coc: crt VLAN prn nwMSeg f(phyNw1,vlanId1). cod: rename seg(!nw) nwMSeg->seg1. coe:crt seg2 f(phyNw2,vlanId2,nwMSeg). cof:crt sbn1|2 f(seg1|2). cog: verify sbn f(DHCP agent).  coh: verify ∃ (inventory,host aggregate) ∀ seg in compute svc.    ~coi: crt port f(nwMSeg).  
 ~ #skipAd# !rtd nw -> rtd nw.
# svc fn(SF) chaining(SFC):  ~ SFC is s/w-defd ng (SDN) vrsn of policy-based rtg (PBR). SFC rts pkts through >=1 SF (!conventional rtg, that rts pkts w/ dest ip). SF emulates series of cabled phy nw devs.
  ~eg: P: loc1 --$fw(pkt)--> loc2, ∃ !next hop ip in $fw.  P: ordered series of SFs, pkts must flow through 1 inst + hashing algo distributes flows across >1 insts ∀ hop.
  ~ port chain(PC) or SF path = { {port: defs seq of SFs}, {flow classifier(FC): specifies classified trfc flows entering chain}}.  ~SF(hs:port pair)={(in,e)gress port(P1E)}. same PIE port ∴ 1 virt bidirectional port.
  ~ PC is 1dir SFC($SFC) ={head, tail ports}. 2dir SFC ={2 $SFC}.    ~(PC : FC)=(1:>1), st P: !ambiguity on which chain should handle pkts in flow; P: >1 flows can req same SF path. 
  ~ PC ={seq of port pair gr: is hop in PC, represents SFs providing equiv fn (eg gr of fw SFs)}. SFC LBs over SFs in port pair gr.  ~rsrcs: mostly #skip#
  ~ crt PC: SF inst 1|2|3: name: vm1|2|3. fn: fw|fw|(intrusion detection sys (IDS)). port pair: ([p1, p2]|[p2, p3]|[p4, p5]). ∃ nw nw1. src creds of proj that owns nw1. cpa: crt ports on nw1 + record UUID.  
    cpb: launch SF inst vmi w/ ports pi & p(i+1)  cpc:crt FC fc1=f((src,dest) (pfx,port)).  cpd:crt port pair PPi f(pi(in), p(i+1)(e)).  cpe: crt|updt port pair gr PPGi f(PPi, PP(i+1))  cpf: crt|updt PC PCi f(PPGi, PPG(i+1), fc1).
aug2020
# PCI-SIG single root io virtn & sharing (SR-IOV):  ~(PF:VF)={1:>1). VF can be assigned to inst, bypassing hypervisor & virt swt ∴ near-line wire speed.  ~SR-IOV agent: allows to set admin state of ports, (en,dis)able spoof checking, cfg QoS rate limiting & min bw.  
  ~ using SR-IOV ifc:  P: crt VF.   P: cfg allow list.  P,cml: cfg ntrn-svr (ctrlr).  P,cmm: cfg nova-scheduler(ctrlr).  P,cmn: enable ntrn-sriov-nic-agent(compute).
  ~ launching insts w/ SR-IOV ports: coc: crt VLAN prn nw1 f(seg1). crt sbn f(nw1,sbnp1). -> get nwId1 -> cmo: crt port p1 f(nwId1,vnic type = direct/normal/direct-phy/macvtap) -> cha: get port id. -> chb: crt inst f($portId)
  ~ SR-IOV w/ InfiniBand(IB): P: allows virt PCI dev(VF) to be directly mapped to guest ∴ higher perf & adv features (eg RDMA (rem direct m/m acs)).  P,preqs: Q: use IB enabled nw adapters.  Q: IB sbn mgr brings up link on card. prim & bkp sbn mgr.  
     Q: install & cfg ebrctl on compute nodes. grep 'ebrctl' /etc/nova/rootwrap.d/*.  P,#skipAd#: limitations  ~#skipSp#: P: supported eth ctrlers. P: SR-IOV w/ connectX-3/connectX-3 pro dual port eth.
sep 2020
#sbnp: ~cqa: whether available.  ~quota. ~cq7b: get,set,use dft. ~cqc: set pfx.                   # sbn onboard: P,cqd: move sbns(pfx1) in nw1 to sbnp1(pfx2) ∴ sbnp1={pfx1 & 2}
#svc sbn: ~ crt nw1. -> cra, crt sbn1|2 f(nw1,cidr1|2,svcType=nova|foo) -> crb,crt inst f(nw1) ∴ cidr1. ip allocation: IPAM driver returns ip from sbn w/ svc type = port dev owner. 
 ~ DVR cfg: goal of reducing #-puips. crt nw1. -> crc,crt sbn1|2|3 f(nw1,cidr1|2|3,svcType=instFip|fip-agent-gw(on compute|foo))
#start#  svc sbn > Example 2 - DVR configuration¶ > 5
##skpChps# P: ML2 plug-in.  P: HA for dhcp.  P: DNS integration w/ ext svc.  P: distributed virt rtg w/ VRRP.  P: ntrn pkt logging framework.  P: macvtap mechanism driver.  P: OVS w/ DPDK datapath.  
 P: Qos, QoS-guaranteed min bw: advanced. role-based acl: sec.
%%%%%%%%%%%%%% AWS(nw) https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html
~ AZ:AD, EC2:compute, elastic-ip:fip, transit-gw:DRG, VPC:VCN, 
vpc user guide 20210707:
~ prip-->NAT dev-->gwi. site-to-site vpn: virt priv gw or DRG(∈ AWS) ---> CPE. 
#start# p14 • You can request an IPv6 CIDR block
%%%%%%%%%%%%%% IAM
~ inst pricipal, https://www.ateam-oracle.com/post/calling-oci-cli-using-instance-principal
  Allow dynamic-group dynGrhs to manage instance-family in compartment deb
  export OCI_CLI_AUTH=instance_principal
  oci compute instance list --compartment-id ocid1.compartment.oc1..aaaaaaaavev6d4acaeqpgn3sqiljzrfogoe5fz2ewalj7gnuqy7ogr2duzmq
%%%%%%%%%%%%%% study
db: 21c new features: complete: admin guide,ref, upgrd guide.  
cloud: k8s
youtube: mysql, docker, OKE, openstack, postgresql
%%%%%%%%%%%%%% 










