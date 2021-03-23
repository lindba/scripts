tmp=.; upld=$1;

lg=$tmp/rsrc.log; lgt=$tmp/rsrct.log; lge=$tmp/rsrc.err; echo > $lg; echo > $lge; svcs="compute db dns fs lb network";
lstSvc() { oci $svc | tail -n +10  | egrep  -v "                                  "| tr -s ' ' | cut -d' ' -f2; }
lstRsrc() { skp=''; echo > $lgt; for r in  component image shape version policy protocol location provider; do  echo $rsrc | grep $r 1>/dev/null; [[ $? == 0 ]] && { skp=skipped; break; }; done;
 echo '### '$svc:$rsrc@$cn $skp |tee -a $lg $lge;
 [[ ! $skp ]] && { case $rsrc in ip-sec-connection) oci $svc $rsrc list $cmpId 2>>$lge | tee -a $lg $lgt; ipsc=$(grep ocid1.ipsecconnection $lgt | cut -d\" -f4); ;;
  ip-sec-tunnel) for ipsci in $ipsc; do  oci $svc $rsrc list --ipsc-id $ipsci 2>>$lge | tee -a $lg; done;  ;;
  public-ip) for ipsci in $ipsc; do  oci $svc $rsrc list --scope region --all 2>>$lge | tee -a $lg; done;  ;;
  *) oci $svc $rsrc list $cmpId 2>>$lge | tee -a $lg; ;; esac; } }

declare -A cmpa; i=1; for cmp in $(oci iam compartment list | egrep -e "ocid1.compartment|\"name\"" | cut -d\" -f4); do if [[ $((i%2)) == 1 ]]; then ci=$cmp; else cn=$cmp; cmpa[$cn]=$ci; fi; ((i++)); done
for cn in ${!cmpa[@]}; do cmpId="--compartment-id "${cmpa[$cn]}; for svc in $svcs; do for rsrc in $(lstSvc); do lstRsrc; done; done; done;
[[ $upld ]] && { oci os bucket create --name rsrc $cmpId 2>/dev/null; oci os object put --bucket-name rsrc --file $lg --force; echo "output: rsrc.log in bucket rsrc in compartment $cn" |tee -a $lg; }

