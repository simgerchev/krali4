#!/bin/bash
# thief7: password is inside a gzip-compressed file
MY_PASS="$1"
NEXT_PASS="$2"

echo "thief7:$MY_PASS" | chpasswd

echo "$NEXT_PASS" | gzip -c > /home/thief7/data.gz
chown root:thief7 /home/thief7/data.gz
chmod 044 /home/thief7/data.gz

cat > /home/thief7/.motd << 'EOF'
Thief 7 → 8
-----------
The password is in 'data.gz', which is a gzip-compressed file.
Decompress it to read the contents.
Hint: zcat data.gz
EOF
chown root:thief7 /home/thief7/.motd
chmod 044 /home/thief7/.motd
