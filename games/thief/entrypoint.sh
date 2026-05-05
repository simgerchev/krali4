#!/bin/bash
set -e

gen_pass() { tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 24; }

PASS1=$(gen_pass)
PASS2=$(gen_pass)
PASS3=$(gen_pass)
PASS4=$(gen_pass)
PASS5=$(gen_pass)
PASS6=$(gen_pass)
PASS7=$(gen_pass)
PASS8=$(gen_pass)
PASS9=$(gen_pass)

/levels/thief0.sh "$PASS1"
/levels/thief1.sh "$PASS1" "$PASS2"
/levels/thief2.sh "$PASS2" "$PASS3"
/levels/thief3.sh "$PASS3" "$PASS4"
/levels/thief4.sh "$PASS4" "$PASS5"
/levels/thief5.sh "$PASS5" "$PASS6"
/levels/thief6.sh "$PASS6" "$PASS7"
/levels/thief7.sh "$PASS7" "$PASS8"
/levels/thief8.sh "$PASS8" "$PASS9"
/levels/thief9.sh "$PASS9"

echo "=== DEBUG PASSWORDS ==="
echo "thief0  →  thief0 (fixed)"
echo "thief1  →  $PASS1"
echo "thief2  →  $PASS2"
echo "thief3  →  $PASS3"
echo "thief4  →  $PASS4"
echo "thief5  →  $PASS5"
echo "thief6  →  $PASS6"
echo "thief7  →  $PASS7"
echo "thief8  →  $PASS8"
echo "thief9  →  $PASS9"
echo "======================="

# Per-user resource limits: max 30 processes, 50MB file writes, 5min CPU time
cat >> /etc/security/limits.conf << 'EOF'
thief0  hard  nproc   30
thief1  hard  nproc   30
thief2  hard  nproc   30
thief3  hard  nproc   30
thief4  hard  nproc   30
thief5  hard  nproc   30
thief6  hard  nproc   30
thief7  hard  nproc   30
thief8  hard  nproc   30
thief9  hard  nproc   30
thief0  hard  fsize   51200
thief1  hard  fsize   51200
thief2  hard  fsize   51200
thief3  hard  fsize   51200
thief4  hard  fsize   51200
thief5  hard  fsize   51200
thief6  hard  fsize   51200
thief7  hard  fsize   51200
thief8  hard  fsize   51200
thief9  hard  fsize   51200
thief0  hard  cpu     5
thief1  hard  cpu     5
thief2  hard  cpu     5
thief3  hard  cpu     5
thief4  hard  cpu     5
thief5  hard  cpu     5
thief6  hard  cpu     5
thief7  hard  cpu     5
thief8  hard  cpu     5
thief9  hard  cpu     5
EOF

for i in $(seq 0 9); do
    printf '[[ -f ~/.motd ]] && cat ~/.motd\n' >> /home/thief$i/.bashrc
    chown thief$i:thief$i /home/thief$i/.bashrc
done

cat > /etc/ssh/banner << 'EOF'

  ██╗  ██╗██████╗  █████╗ ██╗     ██╗██╗  ██╗
  ██║ ██╔╝██╔══██╗██╔══██╗██║     ██║██║  ██║
  █████╔╝ ██████╔╝███████║██║     ██║███████║
  ██╔═██╗ ██╔══██╗██╔══██║██║     ██║╚════██║
  ██║  ██╗██║  ██║██║  ██║███████╗██║     ██║
  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝

  Authorized access only. All sessions are logged.

EOF

exec /usr/sbin/sshd -D -e
