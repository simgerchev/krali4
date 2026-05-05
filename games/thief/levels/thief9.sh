#!/bin/bash
# thief9: final level — congratulations
MY_PASS="$1"

echo "thief9:$MY_PASS" | chpasswd

cat > /home/thief9/.motd << 'EOF'
Thief 9
-------
Congratulations — you've completed all levels!

Skills unlocked:
  cat, ls -la, file, grep, base64, find, zcat, sort/uniq
EOF
chmod 644 /home/thief9/.motd
chown thief9:thief9 /home/thief9/.motd
