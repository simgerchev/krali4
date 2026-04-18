#!/bin/bash
# level3: SSH password is passed in, hidden file inside inhere/ contains level4 password
MY_PASS="$1"
NEXT_PASS="$2"

echo "level3:$MY_PASS" | chpasswd

mkdir -p /home/level3/inhere
echo "$NEXT_PASS" > /home/level3/inhere/.hidden
chown root:level3 /home/level3/inhere/.hidden
chmod 044 /home/level3/inhere/.hidden
chown root:level3 /home/level3/inhere
chmod 050 /home/level3/inhere

cat > /home/level3/.motd << 'EOF'
Level 3 → 4
-----------
The password is hidden somewhere inside the 'inhere' directory.
EOF
chown root:level3 /home/level3/.motd
chmod 044 /home/level3/.motd
