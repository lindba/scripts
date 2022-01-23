#!/bin/bash -x
#/usr/bin/env -S bash -x
#act: nsn => only nw ns;  sysd => systemd

nsi=$1; act=$2; ns=$nsi;
cln(){ ip link set dev $nsc down; ip link set dev $nsh down; ip link delete $nsc; ip link delete $nsh; ip netns delete $ns
 umount -fl /run/netns; for mp in /var/run/netns/$ns; do umount -fl $mp; done; #$(df -ha | grep $ns| grep -v /$ns| tr -s ' ' | cut -d ' ' -f6| sort -r) 
 pkill -f "/run/sshd-$ns.pid"; if [[ $act != nsn ]]; then umount -fl $nsm/proc $nsm/sys $nsm/sys/kernel/debug $nsm/dev $nsm/dev/pts $nsm/var $nsm/var/run/netns/$ns $nsm; fi; 
 rm /var/run/netns/$ns; }  #mv /var/run/netns/$ns /var/run/netns/$ns$(date +"%Y%m%d_%H%M%S"); # Error: Peer netns reference is invalid

ntns(){ ip link add $nsh type veth peer name $nsc address $nscMac;    #veth
 #doc: ip link add $nsc link $nsh type macvlan mode passthru;  #passthru
 ip link set dev $nsh up; ip netns add $ns; ip link set $nsc netns $ns up; ip netns exec $ns ip link set dev lo up;
 ip link add name $brns type bridge; ip link set dev $brns up; ip link set dev $nsh up; ip link set $nsh master $brns;    #veth
 ip addr replace $gw/$pfx dev $brns; #veth, home
 ip netns exec $ns ip addr add $ip/$pfx dev $nsc; ip netns exec $ns ip route add default via $gw dev $nsc; }

mnt(){ mkdir -p $nsm; mount --make-rprivate /; mount --make-shared -o bind $nsr $nsm;
 mkdir -p $nsm/proc $nsm/sys $nsm/sys/kernel/debug $nsm/dev $nsm/dev/pts $nsm/run $nsm/var;
 if [[ $act != sysd ]]; then mount --rbind /dev $nsm/dev/; mount --rbind /dev/pts $nsm/dev/pts;  mount -t proc proc $nsm/proc/; mount --rbind /sys $nsm/sys/;  #did !test w/ systemd
  mount --rbind /run $nsm/run; #t mount --rbind /sys/fs/cgroup $nsm/sys/fs/cgroup;
 fi;
 for dir in inst  kom  tmp  vm; do mount --rbind /data/$dir $nsm/data/$dir; done; for hsDir in chintangsha dtb; do  mount --rbind /data/.hs/$hsDir $nsm/data/.hs/$hsDir; done; #home:
}

pvr(){ ntns; ipt; [[ a$act != ansn ]] && mnt; cd $nsm;  
 #doc:  !privd: as db user unshare --map-root-user ...
 #systemctl,try:  mount --bind /proc/self/ns/net /var/run/netns/$ns; 
 #doc ip netns exec $ns /usr/sbin/sshd -D &   #doc: for only nw ns, systemd of host works
 #doc: for mount ns
 #doc: ip netns exec $ns unshare --mount --uts --ipc --mount-proc=/proc --pid --fork --root $nsm /usr/lib/systemd/systemd --system
 ns1="netns exec $ns unshare --mount --uts --ipc --mount-proc=/proc --pid --fork ";
 if [[ $act == sysd ]]; then ip $ns1 --root $nsm /usr/lib/systemd/systemd --system & ip netns exec $ns journalctl -k -b -f;    #expt: selinux permissive on host & ns
 else unshare --help | grep '\-\-root'; if [[ $? == 0 ]]; then [[ $act != nsn ]] && nrc="--root $nsm"; ip $ns1 $nrc /usr/sbin/sshd -D -o PidFile=/run/sshd-$ns.pid -E /tmp/sshd.log -o ListenAddress=$ip;
  else #ip netns exec $ns unshare --mount --uts --ipc --mount-proc=/proc --pid --fork --root $nsm /bin/bash
   ip $ns1 /bin/bash - <<pvr
   if [[ $act != nsn ]]; then pivot_root . $nsm;  echo $ns > /proc/sys/kernel/hostname; mount debugfs  /sys/kernel/debug -t debugfs;  #doc: for USB
    cd /; mount -t sysfs sysfs sys; mount -t proc proc proc/; #t exec /usr/lib/systemd/systemd;  #tested with fedora 34, did !work with OL7
   fi;
   /usr/sbin/sshd -D -o PidFile=/run/sshd-$ns.pid -o ListenAddress=$ip;  #!systemd
pvr
 fi; fi;
}

ipt() { echo 1 > /proc/sys/net/ipv4/ip_forward; iptables -t nat -A PREROUTING  -p tcp -j DNAT  --destination $instIp --to-destination $ip; iptables -t nat -A POSTROUTING -s $ip -o $instIfc -j MASQUERADE; }
#ipt() { echo 1 > /proc/sys/net/ipv4/ip_forward; iptables -t nat -A POSTROUTING -o $instIfc  -j MASQUERADE; iptables -A FORWARD -i $brns -o $instIfc -j ACCEPT;
# ip addr replace $instIp/$instPfx dev $instIfc:$instIfcIdx; iptables -t nat -A PREROUTING  -p tcp -j DNAT  --destination $instIp --to-destination $ip; }
#enbr(){ echo 1 > /proc/sys/net/ipv4/ip_forward; instGw=$(ip route|head -1 | cut -d' ' -f3); ip link set $instIfc master $brns; ip addr flush dev $instIfc; ip link set $instIfc master $brns; ip addr flush dev $instIfc; ip route add default via $instGw; }

declare -f > /tmp/ns.fn; . ns_$ns.cfg; cln 2>/dev/null;  
case $act in cln) . ns_$ns.cfg; cln 2>/dev/null; ;;
 cld) #doc: to assign sbn ip on ns. 
  ./ns.sh $nsi cln; ./ns.sh c$nsi cln; 
  #doc:  /usr/bin/env -S !working ∴ export ns=$ns
  ns=c$nsi; . ns_$ns.cfg;  ntns; ipt; export ns=$nsi; ip addr replace $instIp/$instPfx dev $instIfc; ip netns exec c$nsi /bin/bash <<cld
  . ns_$ns.cfg; . /tmp/ns.fn; pvr;
cld
 ;;
 *) ns=$nsi; . /tmp/ns.fn; pvr; ;;   #doc(cld): rt cidr of ns to host vm
 #cln 2>/dev/null; 
esac;





#doc: nsenter --target 83941 --mount --uts --ipc --net --pid  -- 






<<tmp

###### tmp

##cloud
ns_cdes.cfg
ip=10.0.1.141
pfx=24
gw=10.0.1.15
nscMac=16:cf:e0:4d:7b:7c
nsh=nsh$ns;   #veth
nsc=ns$ns
brns=br$ns;
nsm=$ns; #for cln
instIfc=ens3
instIp=10.0.0.141
instPfx=24
instIfcIdx=0

#ns_des.cfg
ip=10.0.0.141
pfx=30
gw=10.0.0.142
nscMac=02:00:17:01:22:f0
nsh=nsh$ns;   #veth
nsc=ns$ns
brns=brns;
instIfc=nscdes
instIp=10.0.1.141
instPfx=24
instIfcIdx=0
nsm=/ns/$ns;
nsr=/data/ns/$ns;


# cgroup namespace: https://blogs.rdoproject.org/2015/08/hands-on-linux-sandbox-with-namespaces-and-cgroups/
 usr=db; ns=ns1; nsh=nsh1; nsc=nsc1; hm=/ns/$ns;
 # create a new namespace
 ip netns add $ns; #t ip netns exec $ns su -l $usr;
 ip link add $nsh type veth peer name $nsc;
 # initiate the host side
 ip link set $nsh up
 # initiate the container side
 ip link set $nsc netns $ns up
 # configure network
 ip addr add 192.168.242.1/30 dev $nsh
 ip netns exec $ns ip addr add 192.168.242.2/30 dev $nsc
 ip netns exec $ns ip route add default via 192.168.242.1 dev $nsc

  # Create a new home directory tree
  mkdir -p $hm/$usr; chown $usr $hm/$usr
  # Make sure / is private
  mount --make-rprivate /  ; cat /proc/self/mountinfo
  #mount --make-rprivate --make-unbindable  /  ; cat /proc/self/mountinfo
  umount /ns; mount --make-shared /dev/vdb1 /ns           # https://lwn.net/Articles/689856/
  #unshare -m --propagation unchanged sh; 
  unshare --mount; 
  mount -o bind /proc /ns/proc; cd /ns; pivot_root . /ns; /usr/sbin/sshd -o PidFile=/run/sshd-$ns.pid -o ListenAddress=192.168.242.2
  #mknod /dev/urandom c 1 9 
  mp=/ns;mkdir -p $mp/proc $mp/sys  $mp/dev  $mp/var; mount -t proc proc $mp/proc/; mount --rbind /sys $mp/sys/; mount --rbind /dev $mp/dev/; mount --rbind /dev/pts $mp/dev/pts; 
  ss -ltn

  # Create a new root shell with the mount namespace
  unshare --mount; export PS1="[\u@ns \W]\$ "
    # New mount will be local to this session
    mount -o bind $hm /home; 
  mount -o bind /ns /
  # Other directories can be replaced e.g., /tmp
   mount -t tmpfs none /tmp
   # Drop privilege back to user
   su -l $usr



# Create cgroups
cgcreate -g cpu,memory,blkio,devices,freezer:/$ns
# Allows only 1ms every 100ms to simulate a slow system
cgset -r cpu.cfs_period_us=100000 -r cpu.cfs_quota_us=1000 $ns
# Set a limit of 2Gb
cgset -r memory.limit_in_bytes=2G $ns
# Limit block I/O to 1MB/s
for dev in 253:0 252:0 252:16 8:0 8:16 1:0; do
  cgset -r blkio.throttle.read_bps_device="${dev} 1048576" $ns
  cgset -r blkio.throttle.write_bps_device="${dev} 1048576" $ns
done
# Deny access to devices
cgset -r devices.deny=a $ns
# Allow access to console, null, zero, random, unrandom
for d in "c 5:1" "c 1:3" "c 1:5" "c 1:8" "c 1:9"; do
  cgset -r devices.allow="$d rw" $ns
done
 
# Create network namespace
ip netns add $ns

# Join cgroup, netns and activate resources limit
cgexec -g cpu,memory,blkio,devices,freezer:/$ns   \
  prlimit --nofile=256 --nproc=512 --locks=32         \
    ip netns exec $ns                             \
      unshare --mount --uts --ipc --pid --mount-proc=/proc --fork sh -c " mount -t tmpfs none /home; mount -t tmpfs none /tmp; mount -t tmpfs none /sys; mount -t tmpfs none /var/log; exec su -l $sr "


#systemd
https://developers.redhat.com/blog/2016/09/13/running-systemd-in-a-non-privileged-container
 for m in memory hugetlb net_cls,net_prio cpu,cpuacct freezer perf_event devices cpuset blkio; do mount --bind -o ro $m $nsm/$m; done;
https://github.com/systemd/systemd/issues/6477
 cd $nsm; mount -t tmpfs tmpfs /sys/fs/cgroup/
 mkdir /sys/fs/cgroup/systemd; mount -t tmpfs tmpfs /sys/fs/cgroup/systemd
 mkdir /sys/fs/cgroup/systemd/lxc # mount -o remount,rw /
 mkdir /SUB; mount -t cgroup cgroup -o none,name=systemd /SUB
 mkdir /SUB/lxc; echo 1 >/SUB/lxc/cgroup.procs
 mount --bind /SUB/lxc /sys/fs/cgroup/systemd/lxc; cat /proc/self/cgroup

https://news.ycombinator.com/item?id=17343039
mount proc $nsm/proc; mount sysfs $nsm/sys; mount devtmpfs $nsm/dev; mount devpts $nsm/dev/pts

tmp

