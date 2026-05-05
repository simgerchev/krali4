#!/bin/bash
# thief5: password is stored base64-encoded in encoded.txt
MY_PASS="$1"
NEXT_PASS="$2"

echo "thief5:$MY_PASS" | chpasswd

printf '%s' "$NEXT_PASS" | base64 > /home/thief5/encoded.txt
chown root:thief5 /home/thief5/encoded.txt
chmod 044 /home/thief5/encoded.txt

cat > /home/thief5/.motd << 'EOF'
Thief 5 → 6
-----------
The password is in 'encoded.txt', but it has been base64 encoded.
Decode it to find the password.
Hint: base64 -d encoded.txt
EOF
chown root:thief5 /home/thief5/.motd
chmod 044 /home/thief5/.motd
