#!/bin/bash
# level5: final level, SSH password is passed in
MY_PASS="$1"

echo "level5:$MY_PASS" | chpasswd

cat > /home/level5/.motd << 'EOF'
Level 5
-------
Congratulations — you've completed all levels!
EOF
chmod 644 /home/level5/.motd
chown level5:level5 /home/level5/.motd
