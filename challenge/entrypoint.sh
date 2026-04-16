#!/bin/bash
set -e

# Generate random passwords for levels 1-5 (level0 password is fixed: "level0")
declare -A PASS
for i in $(seq 1 5); do
    PASS[$i]=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 24)
done

# Set SSH passwords
echo "level0:level0" | chpasswd
for i in $(seq 1 5); do
    echo "level$i:${PASS[$i]}" | chpasswd
done

# ── Level 0 → 1 ──────────────────────────────────────────────────────────────
echo "${PASS[1]}" > /home/level0/readme
chmod 640 /home/level0/readme
chown level0:level0 /home/level0/readme

cat > /home/level0/.motd << 'EOF'
Level 0 → 1
-----------
The password for the next level is stored in a file called 'readme'
in the home directory. Use it to log into level1 via SSH.
EOF
chmod 644 /home/level0/.motd
chown level0:level0 /home/level0/.motd

# ── Level 1 → 2 ──────────────────────────────────────────────────────────────
# Hint: reading a file named '-' requires: cat ./-
echo "${PASS[2]}" > /home/level1/-
chmod 640 /home/level1/-
chown level1:level1 /home/level1/-

cat > /home/level1/.motd << 'EOF'
Level 1 → 2
-----------
The password is stored in a file named '-' in the home directory.
EOF
chmod 644 /home/level1/.motd
chown level1:level1 /home/level1/.motd

# ── Level 2 → 3 ──────────────────────────────────────────────────────────────
echo "${PASS[3]}" > "/home/level2/spaces in this filename"
chmod 640 "/home/level2/spaces in this filename"
chown level2:level2 "/home/level2/spaces in this filename"

cat > /home/level2/.motd << 'EOF'
Level 2 → 3
-----------
The password is stored in a file called 'spaces in this filename'.
EOF
chmod 644 /home/level2/.motd
chown level2:level2 /home/level2/.motd

# ── Level 3 → 4 ──────────────────────────────────────────────────────────────
mkdir -p /home/level3/inhere
echo "${PASS[4]}" > /home/level3/inhere/.hidden
chmod 750 /home/level3/inhere
chmod 640 /home/level3/inhere/.hidden
chown -R level3:level3 /home/level3/inhere

cat > /home/level3/.motd << 'EOF'
Level 3 → 4
-----------
The password is hidden somewhere inside the 'inhere' directory.
EOF
chmod 644 /home/level3/.motd
chown level3:level3 /home/level3/.motd

# ── Level 4 → 5 ──────────────────────────────────────────────────────────────
mkdir -p /home/level4/inhere
for i in $(seq 0 8); do
    dd if=/dev/urandom bs=1 count=32 > "/home/level4/inhere/file0$i" 2>/dev/null
done
echo "${PASS[5]}" > /home/level4/inhere/file09
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

# ── Level 5 (final) ──────────────────────────────────────────────────────────
cat > /home/level5/.motd << 'EOF'
Level 5
-------
Congratulations — you've completed all levels!
EOF
chmod 644 /home/level5/.motd
chown level5:level5 /home/level5/.motd

# Print MOTD on login for each user via .bashrc
for i in $(seq 0 5); do
    echo '[[ -f ~/.motd ]] && cat ~/.motd' >> /home/level$i/.bashrc
    chown level$i:level$i /home/level$i/.bashrc
done

# SSH banner
cat > /etc/ssh/banner << 'EOF'

  ██╗  ██╗██████╗  █████╗ ██╗     ██╗██╗  ██╗
  ██║ ██╔╝██╔══██╗██╔══██╗██║     ██║██║  ██║
  █████╔╝ ██████╔╝███████║██║     ██║███████║
  ██╔═██╗ ██╔══██╗██╔══██║██║     ██║╚════██║
  ██║  ██╗██║  ██║██║  ██║███████╗██║     ██║
  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝

  Authorized access only. All sessions are logged.

EOF

exec /usr/sbin/sshd -D -e
