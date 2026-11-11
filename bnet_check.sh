#!/bin/bash
# bnet_check.sh - CPU / memory / bnetscs startup sanity check (BorderNet SBC)
#
# Usage:
#   ./bnet_check.sh                 # check this box and the running bnetscs
#   ./bnet_check.sh "<ps line>"     # analyze a pasted bnetscs command line (e.g. from a customer)
#
# Checks: CPUs (count, topology, NUMA, affinity, cgroup quota), memory (total, available,
# swap, hugepages, cgroup limit, AppParams EXPECTED_SYSTEM_MEMORY), bnetscs args vs the
# runplatformenv formulas, process RSS/threads/open-files, and the SIP pool 4 GiB wrap
# (DLG4-35: pool = maxcalllegs/4 elements x 30776 bytes; >= 4 GiB wraps).

ELEM_SIZE=30776          # SIP Msg Pool SizeOfElement seen on 3.9.3-166 (Read buffers: 30728)
APPPARAMS=/config/mibs/current/appparams/AppParams.xml
RUNENV=/opt/bnet/bin/runplatformenv

ok()   { printf "  [ OK ] %s\n" "$*"; }
warn() { printf "  [WARN] %s\n" "$*"; WARNS=$((WARNS+1)); }
info() { printf "         %s\n" "$*"; }
hdr()  { printf "\n== %s\n" "$*"; }
WARNS=0

# ---------------------------------------------------------------- bnetscs command line
if [ -n "$1" ]; then
    CMDLINE="$1"; P=""; MODE="pasted command line"
else
    P=$(pgrep -f '/opt/bnet/bin/bnetscs -' | head -1)
    if [ -n "$P" ]; then CMDLINE=$(tr '\0' ' ' < /proc/$P/cmdline); MODE="running pid $P"
    else CMDLINE=""; MODE="bnetscs not running"; fi
fi
arg() { echo "$CMDLINE" | grep -oE -- "-$1 [^ ]+" | head -1 | awk '{print $2}'; }

printf "bnet_check on %s  (%s)  %s\n" "$(hostname)" "$MODE" "$(date '+%F %T %Z')"

# ---------------------------------------------------------------- CPU
hdr "CPU"
NPROC=$(nproc 2>/dev/null); NPROC_ALL=$(nproc --all 2>/dev/null)
info "nproc (usable) = $NPROC   nproc --all = $NPROC_ALL"
if command -v lscpu >/dev/null; then
    lscpu | grep -E '^(Model name|Socket\(s\)|Core\(s\) per socket|Thread\(s\) per core|NUMA node\(s\)|NUMA node[0-9]+ CPU)' | sed 's/^/         /'
fi
[ "$NPROC" != "$NPROC_ALL" ] && warn "only $NPROC of $NPROC_ALL CPUs usable by this shell (affinity/cgroup)"
# cgroup CPU quota (v2 then v1)
if [ -r /sys/fs/cgroup/cpu.max ]; then
    read q per < /sys/fs/cgroup/cpu.max
    [ "$q" != "max" ] && warn "cgroup v2 cpu.max quota = $q/$per (~$(awk -v a=$q -v b=$per 'BEGIN{printf "%.1f",a/b}') CPUs)" || info "cgroup cpu.max: no quota"
elif [ -r /sys/fs/cgroup/cpu/cpu.cfs_quota_us ]; then
    q=$(cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us); per=$(cat /sys/fs/cgroup/cpu/cpu.cfs_period_us)
    [ "$q" -gt 0 ] 2>/dev/null && warn "cgroup v1 CPU quota = $q/$per" || info "cgroup v1: no CPU quota"
fi
if [ -n "$P" ]; then
    AFF=$(grep Cpus_allowed_list /proc/$P/status | awk '{print $2}')
    info "bnetscs Cpus_allowed_list = $AFF"
fi

# ---------------------------------------------------------------- Memory
hdr "Memory"
mi() { awk -v k="$1:" '$1==k{print $2}' /proc/meminfo; }   # kB
MT=$(mi MemTotal); MA=$(mi MemAvailable); ST=$(mi SwapTotal); SF=$(mi SwapFree)
HPT=$(mi HugePages_Total); HPF=$(mi HugePages_Free); HPS=$(mi Hugepagesize)
gb() { awk -v k="$1" 'BEGIN{printf "%.1f GiB", k/1048576}'; }
info "MemTotal $(gb $MT)   MemAvailable $(gb $MA) ($(awk -v a=$MA -v t=$MT 'BEGIN{printf "%d%%",100*a/t}'))"
info "Swap total $(gb $ST)  free $(gb $SF)"
info "HugePages total $HPT  free $HPF  size $((HPS/1024)) MiB  (= $(gb $((HPT*HPS))))"
[ "$MA" -lt $((MT/10)) ] && warn "less than 10% memory available"
if [ -r /sys/fs/cgroup/memory.max ]; then
    m=$(cat /sys/fs/cgroup/memory.max); [ "$m" != "max" ] && warn "cgroup v2 memory.max = $(gb $((m/1024)))" || info "cgroup memory.max: no limit"
elif [ -r /sys/fs/cgroup/memory/memory.limit_in_bytes ]; then
    m=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes); [ "$m" -lt $((MT*1024)) ] 2>/dev/null && warn "cgroup v1 memory limit = $(gb $((m/1024)))"
fi
if [ -r "$APPPARAMS" ]; then
    EXP=$(grep -o 'EXPECTED_SYSTEM_MEMORY"[^/]*value="[0-9]*"' "$APPPARAMS" | grep -oE '[0-9]+"$' | tr -d '"')
    if [ -n "$EXP" ]; then
        HAVE=$(awk -v k=$MT 'BEGIN{printf "%d", k/1048576+0.5}')
        [ "$HAVE" -ge "$EXP" ] && ok "MemTotal ~${HAVE} GiB >= AppParams EXPECTED_SYSTEM_MEMORY ${EXP}" \
                               || warn "MemTotal ~${HAVE} GiB < AppParams EXPECTED_SYSTEM_MEMORY ${EXP}"
    fi
fi

# ---------------------------------------------------------------- bnetscs process
if [ -n "$P" ]; then
    hdr "bnetscs process (pid $P)"
    st() { awk -v k="$1:" '$1==k{print $2}' /proc/$P/status; }
    info "VmRSS $(gb $(st VmRSS))   VmSize $(gb $(st VmSize))   Threads $(st Threads)"
    NOF=$(awk '/Max open files/{print $4}' /proc/$P/limits); NFD=$(ls /proc/$P/fd 2>/dev/null | wc -l)
    info "open files $NFD / limit $NOF   TCP sockets $(ls -l /proc/$P/fd 2>/dev/null | grep -c socket) (all sockets)"
    info "started $(ps -o lstart= -p $P)   cpu $(ps -o %cpu= -p $P)%"
fi

# ---------------------------------------------------------------- startup args vs formulas
hdr "bnetscs startup values"
if [ -z "$CMDLINE" ]; then
    info "no command line available"
else
    for k in corethreads swtransnumthreads maxcalllegs maxusers maxregisters subscriptions primary installtype; do
        printf "         %-18s %s\n" "$k" "$(arg $k)"
    done
    MCL=$(arg maxcalllegs); CT=$(arg corethreads); SW=$(arg swtransnumthreads)
    MU=$(arg maxusers); MR=$(arg maxregisters); SB=$(arg subscriptions)
    if [ -n "$MCL" ]; then
        CPU_F=$((MCL/8192))
        hdr "runplatformenv formula check (cpu_num implied by maxcalllegs/8192 = $CPU_F)"
        [ -z "$1" ] && { [ "$CPU_F" = "$NPROC" ] && ok "maxcalllegs matches nproc ($NPROC x 8192)" \
                                               || warn "maxcalllegs=$MCL implies cpu_num=$CPU_F but nproc=$NPROC (overridden or edited?)"; }
        [ -n "$MU" ] && { [ "$MU" = $((CPU_F*16384)) ] && ok "maxusers = cpu_num x 16384" || warn "maxusers $MU != $CPU_F x 16384"; }
        [ -n "$MR" ] && { [ "$MR" = $((CPU_F*1024)) ]  && ok "maxregisters = cpu_num x 1024" || warn "maxregisters $MR != $CPU_F x 1024"; }
        [ -n "$SB" ] && { [ "$SB" = $((CPU_F*1024)) ]  && ok "subscriptions = cpu_num x 1024" || warn "subscriptions $SB != $CPU_F x 1024"; }
        [ -n "$CT" ] && { [ "$CT" = $((CPU_F-1)) ] && ok "corethreads = cpu_num-1" || warn "corethreads $CT != cpu_num-1 ($((CPU_F-1)))"; }
        [ -n "$SW" ] && [ -n "$CT" ] && { [ "$SW" = "$CT" ] && ok "swtransnumthreads = corethreads" || warn "swtransnumthreads $SW != corethreads $CT"; }

        hdr "SIP stack pool sizing (DLG4-35 4 GiB wrap)"
        EL=$((MCL/4)); BYTES=$(awk -v e=$EL -v s=$ELEM_SIZE 'BEGIN{printf "%.0f", e*s}')
        info "pool elements = maxcalllegs/4 = $EL  x $ELEM_SIZE B = $(awk -v b=$BYTES 'BEGIN{printf "%.2f GiB", b/2^30}') per pool (SIP Msg Pool, Read buffers pool)"
        if awk -v b=$BYTES 'BEGIN{exit !(b>=2^32)}'; then
            USE=$(awk -v b=$BYTES -v s=$ELEM_SIZE 'BEGIN{printf "%d", (b%2^32)/s}')
            warn "pool >= 4 GiB: wraps - only $USE of $EL elements usable ($(awk -v u=$USE -v e=$EL 'BEGIN{printf "%d%%",100*u/e}'))"
            info "largest safe maxcalllegs (multiple of 8192): $(awk -v s=$ELEM_SIZE 'BEGIN{m=int((2^32-1)/s)*4; print int(m/8192)*8192}')"
        else
            ok "pool < 4 GiB: no wrap ($(awk -v b=$BYTES 'BEGIN{printf "%.0f%%", 100*b/2^32}') of the 4 GiB limit)"
        fi
        [ -n "$MT" ] && info "2 pools = $(awk -v b=$BYTES 'BEGIN{printf "%.2f GiB", 2*b/2^30}') virtual vs MemTotal $(gb $MT)"
    fi
fi
if [ -r "$RUNENV" ]; then
    hdr "runplatformenv ($RUNENV)"
    grep -nE '^\s*(cpu_num|maxcalllegs|maxusers|maxregisters|subscriptions|corethreads)=' "$RUNENV" | sed 's/^/         /'
fi

printf "\n%d warning(s)\n" "$WARNS"
