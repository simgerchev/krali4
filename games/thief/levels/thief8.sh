#!/bin/bash
# thief8: password is the only unique line in a file full of duplicates
MY_PASS="$1"
NEXT_PASS="$2"

echo "thief8:$MY_PASS" | chpasswd

{
  for word in alpha bravo charlie delta foxtrot golf hotel india juliet kilo \
               lima mike november oscar papa quebec romeo sierra tango uniform; do
      for _ in $(seq 1 15); do
          echo "$word"
      done
  done
  echo "$NEXT_PASS"
} | sort -R > /home/thief8/data.txt

chown root:thief8 /home/thief8/data.txt
chmod 044 /home/thief8/data.txt

cat > /home/thief8/.motd << 'EOF'
Thief 8 → 9
-----------
The password is in 'data.txt', but most lines are duplicates.
The password is the only line that appears exactly once.
Hint: sort data.txt | uniq -u
EOF
chown root:thief8 /home/thief8/.motd
chmod 044 /home/thief8/.motd
