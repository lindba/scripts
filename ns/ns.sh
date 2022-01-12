#!/bin/bash
#/usr/bin/env -S bash -x

nsi=$1; act=$2; ns=$nsi;
cln(){ ip link set dev $nsc down; ip link set dev $nsh down; ip link delete $nsc; ip link delete $nsh; ip netns delete $ns
 umount -fl /run/netns; for mp in /var/run/netns/$ns; do umount -fl $mp; done; #$(df -ha | grep $ns| grep -v /$ns| tr -s ' ' | cut -d ' ' -f6| sort -r)
 pkill -f "/run/sshd-$ns.pid"; if [[ $act != puip ]]; then umount -fl $nsm/proc $nsm/sys $nsm/sys/kernel/debug $nsm/dev $nsm/dev/pts $nsm/var $nsm/var/run/netns/$ns $nsm; fi;
 rm /var/run/netns/$ns; }  #mv /var/run/netns/$ns /var/run/netns/$ns$(date +"%Y%m%d_%H%M%S"); # Error: Peer netns reference is invalid

ntns(){ ip link add $nsh type veth peer name $nsc address $nscMac;    #veth
 #doc: ip link add $nsc link $nsh type macvlan mode passthru;  #passthru
 ip link set dev $nsh up; ip netns add $ns; ip link set $nsc netns $ns up; ip netns exec $ns ip link set dev lo up;
 ip link add name $brns type bridge; ip link set dev $brns up; ip link set dev $nsh up; ip link set $nsh master $brns;    #veth
 ip addr replace $gw/$pfx dev $brns; #veth, home
 ip netns exec $ns ip addr add $ip/$pfx dev $nsc; ip netns exec $ns ip route add default via $gw dev $nsc;
 ip netn exec $ns echo $ns > /proc/sys/kernel/hostname; ip netns; }

mnt(){ mkdir -p $nsm; mount --make-rprivate /; mount --make-shared -o bind $nsr $nsm;
 mkdir -p $nsm/proc $nsm/sys $nsm/sys/kernel/debug $nsm/dev $nsm/dev/pts $nsm/run $nsm/var; mount --rbind /dev $nsm/dev/; mount --rbind /dev/pts $nsm/dev/pts;
 mount -t proc proc $nsm/proc/; mount --rbind /sys $nsm/sys/;  #did !test w/ systemd
 mount --rbind /run $nsm/run; #t mount --rbind /sys/fs/cgroup $nsm/sys/fs/cgroup;
 for dir in inst  kom  tmp  vm; do mount --rbind /data/$dir $nsm/data/$dir; done; for hsDir in chintangsha dtb; do  mount --rbind /data/.hs/$hsDir $nsm/data/.hs/$hsDir; done; #home:
}

pvr(){ ntns; [[ $act = puip ]] && ipt || mnt; cd $nsm;
 #doc:  !privd: as db user unshare --map-root-user ...
 #systemctl,try:  mount --bind /proc/self/ns/net /var/run/netns/$ns;
 #doc ip netns exec $ns /usr/sbin/sshd -D &   #doc: for only nw ns, systemd of host works
 #doc: for mount ns
 #doc: ip netns exec $ns unshare --mount --uts --ipc --mount-proc=/proc --pid --fork --root $nsm /usr/lib/systemd/systemd --system
  unshare --help | grep '\-\-root'; if [[ $? == 0 ]]; then ip netns exec $ns unshare --mount --uts --ipc --mount-proc=/proc --pid --fork --root $nsm /usr/sbin/sshd -D -o PidFile=/run/sshd-$ns.pid -E /tmp/sshd.log -o ListenAddress=$ip;
 else #ip netns exec $ns unshare --mount --uts --ipc --mount-proc=/proc --pid --fork --root $nsm /bin/bash
  ip netns exec $ns unshare --mount --uts --ipc --mount-proc=/proc --pid --fork /bin/bash - <<pvr
   pivot_root . $nsm;  echo $ns > /proc/sys/kernel/hostname;
   mount debugfs  /sys/kernel/debug -t debugfs;  #doc: for USB
   cd /; mount -t sysfs sysfs sys; mount -t proc proc proc/; #t exec /usr/lib/systemd/systemd;  #tested with fedora 34, did !work with OL7
   /usr/sbin/sshd -D -o PidFile=/run/sshd-$ns.pid -o ListenAddress=$ip;  #!systemd
pvr
 fi;
}

ipt() { echo 1 > /proc/sys/net/ipv4/ip_forward; iptables -t nat -A PREROUTING  -p tcp -j DNAT  --destination $instIp --to-destination $ip; }   #iptables -t nat -A POSTROUTING -j MASQUERADE; iptables -A FORWARD -i $brns -o $instIfc -j ACCEPT; }
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

