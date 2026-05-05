#!/bin/bash
# thief6: find the one human-readable file > 1033 bytes among hundreds in nested dirs
MY_PASS="$1"
NEXT_PASS="$2"

echo "thief6:$MY_PASS" | chpasswd

mkdir -p /home/thief6/inhere
for d in $(seq 1 10); do
    mkdir -p /home/thief6/inhere/maybehere$d
    for f in $(seq 1 20); do
        dd if=/dev/urandom bs=$((RANDOM % 200 + 10)) count=1 \
           of="/home/thief6/inhere/maybehere$d/file$(printf '%02d' $f)" 2>/dev/null
    done
done

TARGET="maybehere$((RANDOM % 10 + 1))"
{ echo "$NEXT_PASS"; head -c 1100 /dev/zero | tr '\0' 'x'; echo; } \
    > "/home/thief6/inhere/$TARGET/file07"

chown -R root:thief6 /home/thief6/inhere
find /home/thief6/inhere -type d -exec chmod 050 {} \;
find /home/thief6/inhere -type f -exec chmod 040 {} \;

cat > /home/thief6/.motd << 'EOF'
Thief 6 → 7
-----------
The password is in 'inhere/' — 10 subdirectories, ~200 files, almost all binary.
Find the only human-readable file larger than 1033 bytes.
Hint: find inhere/ -type f -size +1033c
EOF
chown root:thief6 /home/thief6/.motd
chmod 044 /home/thief6/.motd
