#!/bin/bash
set -e

gen_pass() { tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 24; }

PASS1=$(gen_pass)
PASS2=$(gen_pass)
PASS3=$(gen_pass)
PASS4=$(gen_pass)
PASS5=$(gen_pass)

/levels/level0.sh "$PASS1"
/levels/level1.sh "$PASS1" "$PASS2"
/levels/level2.sh "$PASS2" "$PASS3"
/levels/level3.sh "$PASS3" "$PASS4"
/levels/level4.sh "$PASS4" "$PASS5"
/levels/level5.sh "$PASS5"

# Per-user resource limits: max 30 processes, 50MB file writes, 5min CPU time
cat >> /etc/security/limits.conf << 'EOF'
level0  hard  nproc   30
level1  hard  nproc   30
level2  hard  nproc   30
level3  hard  nproc   30
level4  hard  nproc   30
level5  hard  nproc   30
level0  hard  fsize   51200
level1  hard  fsize   51200
level2  hard  fsize   51200
level3  hard  fsize   51200
level4  hard  fsize   51200
level5  hard  fsize   51200
level0  hard  cpu     5
level1  hard  cpu     5
level2  hard  cpu     5
level3  hard  cpu     5
level4  hard  cpu     5
level5  hard  cpu     5
EOF

for i in $(seq 0 5); do
    printf '[[ -f ~/.motd ]] && cat ~/.motd\n' >> /home/level$i/.bashrc
    chown level$i:level$i /home/level$i/.bashrc
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
