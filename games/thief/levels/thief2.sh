#!/bin/bash
# thief2: SSH password is passed in, challenge file has spaces in name, contains thief3 password
MY_PASS="$1"
NEXT_PASS="$2"

echo "thief2:$MY_PASS" | chpasswd

echo "$NEXT_PASS" > "/home/thief2/spaces in this filename"
chown root:thief2 "/home/thief2/spaces in this filename"
chmod 044 "/home/thief2/spaces in this filename"

cat > /home/thief2/.motd << 'EOF'
Thief 2 → 3
-----------
The password is stored in a file called 'spaces in this filename'.
EOF
chown root:thief2 /home/thief2/.motd
chmod 044 /home/thief2/.motd
