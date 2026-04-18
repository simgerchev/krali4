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
chmod 750 /home/level4/inhere
chmod 640 /home/level4/inhere/file0*
chown -R level4:level4 /home/level4/inhere

cat > /home/level4/.motd << 'EOF'
Level 4 → 5
-----------
The password is in the only human-readable file inside 'inhere/'.
Hint: the 'file' command tells you what type each file is.
EOF
chmod 644 /home/level4/.motd
chown level4:level4 /home/level4/.motd
