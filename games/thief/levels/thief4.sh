#!/bin/bash
# thief4: password is among 500 lines in data.txt — find it with grep
MY_PASS="$1"
NEXT_PASS="$2"

echo "thief4:$MY_PASS" | chpasswd

seq -f 'I8oAzXwN%04.0fpFcDuEjKmVl' 1 500 > /tmp/thief4_lines
INSERT=$((RANDOM % 450 + 25))
{
    head -n "$((INSERT - 1))" /tmp/thief4_lines
    echo "password: $NEXT_PASS"
    tail -n "+$INSERT" /tmp/thief4_lines
} > /home/thief4/data.txt
rm /tmp/thief4_lines

chown root:thief4 /home/thief4/data.txt
chmod 044 /home/thief4/data.txt

cat > /home/thief4/.motd << 'EOF'
Thief 4 → 5
-----------
The password is in 'data.txt', hidden among 500 lines of garbage.
Find the line that starts with 'password: ' — everything after that prefix is the password.
Hint: grep 'password:' data.txt
EOF
chown root:thief4 /home/thief4/.motd
chmod 044 /home/thief4/.motd
