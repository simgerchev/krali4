#!/bin/bash
# level2: SSH password is passed in, challenge file has spaces in name, contains level3 password
MY_PASS="$1"
NEXT_PASS="$2"

echo "level2:$MY_PASS" | chpasswd

echo "$NEXT_PASS" > "/home/level2/spaces in this filename"
chmod 640 "/home/level2/spaces in this filename"
chown level2:level2 "/home/level2/spaces in this filename"

cat > /home/level2/.motd << 'EOF'
Level 2 → 3
-----------
The password is stored in a file called 'spaces in this filename'.
EOF
chmod 644 /home/level2/.motd
chown level2:level2 /home/level2/.motd
