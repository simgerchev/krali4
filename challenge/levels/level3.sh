#!/bin/bash
# level3: SSH password is passed in, hidden file inside inhere/ contains level4 password
MY_PASS="$1"
NEXT_PASS="$2"

echo "level3:$MY_PASS" | chpasswd

mkdir -p /home/level3/inhere
echo "$NEXT_PASS" > /home/level3/inhere/.hidden
chmod 750 /home/level3/inhere
chmod 640 /home/level3/inhere/.hidden
chown -R level3:level3 /home/level3/inhere

cat > /home/level3/.motd << 'EOF'
Level 3 → 4
-----------
The password is hidden somewhere inside the 'inhere' directory.
EOF
chmod 644 /home/level3/.motd
chown level3:level3 /home/level3/.motd
