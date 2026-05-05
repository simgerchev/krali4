#!/bin/bash
# thief3: only human-readable file among binary files contains thief4 password
MY_PASS="$1"
NEXT_PASS="$2"

echo "thief3:$MY_PASS" | chpasswd

mkdir -p /home/thief3/inhere
for i in $(seq 0 8); do
    dd if=/dev/urandom bs=1 count=32 > "/home/thief3/inhere/file0$i" 2>/dev/null
done
echo "$NEXT_PASS" > /home/thief3/inhere/file09
chown -R root:thief3 /home/thief3/inhere
chmod 050 /home/thief3/inhere
chmod 044 /home/thief3/inhere/file0*

cat > /home/thief3/.motd << 'EOF'
Thief 3 → 4
-----------
The password is in the only human-readable file inside 'inhere/'.
Hint: the 'file' command tells you what type each file is.
EOF
chown root:thief3 /home/thief3/.motd
chmod 044 /home/thief3/.motd
