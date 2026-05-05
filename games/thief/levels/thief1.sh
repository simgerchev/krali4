#!/bin/bash
# thief1: challenge file has spaces in name, contains thief2 password
MY_PASS="$1"
NEXT_PASS="$2"

echo "thief1:$MY_PASS" | chpasswd

echo "$NEXT_PASS" > "/home/thief1/spaces in this filename"
chown root:thief1 "/home/thief1/spaces in this filename"
chmod 044 "/home/thief1/spaces in this filename"

cat > /home/thief1/.motd << 'EOF'
Thief 1 → 2
-----------
The password is stored in a file called 'spaces in this filename'.
EOF
chown root:thief1 /home/thief1/.motd
chmod 044 /home/thief1/.motd
