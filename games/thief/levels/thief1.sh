#!/bin/bash
# thief1: SSH password is passed in, challenge file named '-' contains thief2 password
MY_PASS="$1"
NEXT_PASS="$2"

echo "thief1:$MY_PASS" | chpasswd

# Hint: reading a file named '-' requires: cat ./-
echo "$NEXT_PASS" > /home/thief1/-
chown root:thief1 /home/thief1/-
chmod 044 /home/thief1/-

cat > /home/thief1/.motd << 'EOF'
Thief 1 → 2
-----------
The password is stored in a file named '-' in the home directory.
EOF
chown root:thief1 /home/thief1/.motd
chmod 044 /home/thief1/.motd
