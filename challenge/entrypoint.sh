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
