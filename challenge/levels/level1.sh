#!/bin/bash
# level1: SSH password is passed in, challenge file named '-' contains level2 password
MY_PASS="$1"
NEXT_PASS="$2"

echo "level1:$MY_PASS" | chpasswd

# Hint: reading a file named '-' requires: cat ./-
echo "$NEXT_PASS" > /home/level1/-
chmod 640 /home/level1/-
chown level1:level1 /home/level1/-

cat > /home/level1/.motd << 'EOF'
Level 1 → 2
-----------
The password is stored in a file named '-' in the home directory.
EOF
chmod 644 /home/level1/.motd
chown level1:level1 /home/level1/.motd
