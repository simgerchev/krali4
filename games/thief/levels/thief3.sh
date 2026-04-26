#!/bin/bash
# thief3: SSH password is passed in, hidden file inside inhere/ contains thief4 password
MY_PASS="$1"
NEXT_PASS="$2"

echo "thief3:$MY_PASS" | chpasswd

mkdir -p /home/thief3/inhere
echo "$NEXT_PASS" > /home/thief3/inhere/.hidden
chown root:thief3 /home/thief3/inhere/.hidden
chmod 044 /home/thief3/inhere/.hidden
chown root:thief3 /home/thief3/inhere
chmod 050 /home/thief3/inhere

cat > /home/thief3/.motd << 'EOF'
Thief 3 → 4
-----------
The password is hidden somewhere inside the 'inhere' directory.
EOF
chown root:thief3 /home/thief3/.motd
chmod 044 /home/thief3/.motd
