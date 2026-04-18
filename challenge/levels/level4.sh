#!/bin/bash
# level4: SSH password is passed in, only human-readable file among binary files contains level5 password
MY_PASS="$1"
NEXT_PASS="$2"

echo "level4:$MY_PASS" | chpasswd

mkdir -p /home/level4/inhere
for i in $(seq 0 8); do
    dd if=/dev/urandom bs=1 count=32 > "/home/level4/inhere/file0$i" 2>/dev/null
done
echo "$NEXT_PASS" > /home/level4/inhere/file09
chown -R root:level4 /home/level4/inhere
chmod 050 /home/level4/inhere
chmod 044 /home/level4/inhere/file0*

cat > /home/level4/.motd << 'EOF'
Level 4 → 5
-----------
The password is in the only human-readable file inside 'inhere/'.
Hint: the 'file' command tells you what type each file is.
EOF
chown root:level4 /home/level4/.motd
chmod 044 /home/level4/.motd
