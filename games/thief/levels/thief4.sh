#!/bin/bash
# thief4: SSH password is passed in, only human-readable file among binary files contains thief5 password
MY_PASS="$1"
NEXT_PASS="$2"

echo "thief4:$MY_PASS" | chpasswd

mkdir -p /home/thief4/inhere
for i in $(seq 0 8); do
    dd if=/dev/urandom bs=1 count=32 > "/home/thief4/inhere/file0$i" 2>/dev/null
done
echo "$NEXT_PASS" > /home/thief4/inhere/file09
chown -R root:thief4 /home/thief4/inhere
chmod 050 /home/thief4/inhere
chmod 044 /home/thief4/inhere/file0*

cat > /home/thief4/.motd << 'EOF'
Thief 4 → 5
-----------
The password is in the only human-readable file inside 'inhere/'.
Hint: the 'file' command tells you what type each file is.
EOF
chown root:thief4 /home/thief4/.motd
chmod 044 /home/thief4/.motd
