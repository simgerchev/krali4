#!/bin/bash
set -e

gen_pass() { tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 24; }

PASS1=$(gen_pass)
PASS2=$(gen_pass)
PASS3=$(gen_pass)
PASS4=$(gen_pass)
PASS5=$(gen_pass)

/levels/thief0.sh "$PASS1"
/levels/thief1.sh "$PASS1" "$PASS2"
/levels/thief2.sh "$PASS2" "$PASS3"
/levels/thief3.sh "$PASS3" "$PASS4"
/levels/thief4.sh "$PASS4" "$PASS5"
/levels/thief5.sh "$PASS5"

# Per-user resource limits: max 30 processes, 50MB file writes, 5min CPU time
cat >> /etc/security/limits.conf << 'EOF'
thief0  hard  nproc   30
thief1  hard  nproc   30
thief2  hard  nproc   30
thief3  hard  nproc   30
thief4  hard  nproc   30
thief5  hard  nproc   30
thief0  hard  fsize   51200
thief1  hard  fsize   51200
thief2  hard  fsize   51200
thief3  hard  fsize   51200
thief4  hard  fsize   51200
thief5  hard  fsize   51200
thief0  hard  cpu     5
thief1  hard  cpu     5
thief2  hard  cpu     5
thief3  hard  cpu     5
thief4  hard  cpu     5
thief5  hard  cpu     5
EOF

for i in $(seq 0 5); do
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
