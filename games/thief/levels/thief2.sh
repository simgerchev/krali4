#!/bin/bash
# thief2: hidden file inside inhere/ contains thief3 password
MY_PASS="$1"
NEXT_PASS="$2"

echo "thief2:$MY_PASS" | chpasswd

mkdir -p /home/thief2/inhere
echo "$NEXT_PASS" > /home/thief2/inhere/.hidden
chown root:thief2 /home/thief2/inhere/.hidden
chmod 044 /home/thief2/inhere/.hidden
chown root:thief2 /home/thief2/inhere
chmod 050 /home/thief2/inhere

cat > /home/thief2/.motd << 'EOF'
Thief 2 → 3
-----------
The password is hidden somewhere inside the 'inhere' directory.
EOF
chown root:thief2 /home/thief2/.motd
chmod 044 /home/thief2/.motd
