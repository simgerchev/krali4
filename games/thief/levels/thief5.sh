#!/bin/bash
# thief5: final level, SSH password is passed in
MY_PASS="$1"

echo "thief5:$MY_PASS" | chpasswd

cat > /home/thief5/.motd << 'EOF'
Thief 5
-------
Congratulations — you've completed all levels!
EOF
chmod 644 /home/thief5/.motd
chown thief5:thief5 /home/thief5/.motd
