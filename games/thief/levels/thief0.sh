#!/bin/bash
# thief0: fixed SSH password "thief0", challenge file contains thief1 password
NEXT_PASS="$1"

echo "thief0:thief0" | chpasswd

echo "$NEXT_PASS" > /home/thief0/readme
chown root:thief0 /home/thief0/readme
chmod 044 /home/thief0/readme

cat > /home/thief0/.motd << 'EOF'
Thief 0 → 1
-----------
The password for the next level is stored in a file called 'readme'
in the home directory. Use it to log into thief1 via SSH.
EOF
chown root:thief0 /home/thief0/.motd
chmod 044 /home/thief0/.motd
