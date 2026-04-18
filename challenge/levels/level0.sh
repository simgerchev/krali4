#!/bin/bash
# level0: fixed SSH password "level0", challenge file contains level1 password
NEXT_PASS="$1"

echo "level0:level0" | chpasswd

echo "$NEXT_PASS" > /home/level0/readme
chown root:level0 /home/level0/readme
chmod 044 /home/level0/readme

cat > /home/level0/.motd << 'EOF'
Level 0 → 1
-----------
The password for the next level is stored in a file called 'readme'
in the home directory. Use it to log into level1 via SSH.
EOF
chown root:level0 /home/level0/.motd
chmod 044 /home/level0/.motd
