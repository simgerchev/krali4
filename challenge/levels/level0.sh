#!/bin/bash
# level0: fixed SSH password "level0", challenge file contains level1 password
NEXT_PASS="$1"

echo "level0:level0" | chpasswd

echo "$NEXT_PASS" > /home/level0/readme
chmod 640 /home/level0/readme
chown level0:level0 /home/level0/readme

cat > /home/level0/.motd << 'EOF'
Level 0 → 1
-----------
The password for the next level is stored in a file called 'readme'
in the home directory. Use it to log into level1 via SSH.
EOF
chmod 644 /home/level0/.motd
chown level0:level0 /home/level0/.motd
