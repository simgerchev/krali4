#!/bin/bash
# thief7: password is inside a gzip-compressed file
MY_PASS="$1"
NEXT_PASS="$2"

echo "thief7:$MY_PASS" | chpasswd

mkdir -p /var/thief7
echo "$NEXT_PASS" | gzip -c > /var/thief7/data.gz
chown root:thief7 /var/thief7/data.gz
chmod 040 /var/thief7/data.gz
chown root:thief7 /var/thief7
chmod 750 /var/thief7

cat > /home/thief7/.motd << 'EOF'
Thief 7 → 8
-----------
The password is in '/var/thief7/data.gz', which is a gzip-compressed file.
Decompress it to read the contents.
Hint: zcat /var/thief7/data.gz
EOF
chown root:thief7 /home/thief7/.motd
chmod 044 /home/thief7/.motd
