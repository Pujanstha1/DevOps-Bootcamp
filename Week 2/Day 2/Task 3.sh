#!/bin/bash

REPORT="/var/log/harden-report.log"
SSH_CONFIG="/etc/ssh/sshd_config"

echo "========== Hardening Report ============" > $REPORT
echo "Started at: $(date)" >> $REPORT
echo "----------------------------------------" >> $REPORT

# ---- Check Root -----
if [[ "$EUID" -ne 0 ]]; then
        echo "You are logged in as '$USER'. Please login as Root"
        exit 1
fi

## 1. Disable root login via ssh
echo "[*] Disabling SSH root login..."
if grep -q "^PermitRootLogin" $SSH_CONFIG; then
        sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG
else
        echo "PermitRootLogin no" >> $SSH_CONFIG
fi

echo "Root Login via SSH" >> $REPORT

## 2. Change SSH Port

NEW_PORT=2222

echo "[*] Changing SSH Port to $NEW_PORT...."

if grep -q "^Port " $SSH_CONFIG; then
        sed -i "^Port .*/Port $NEW_PORT/" $SSH_CONFIG
else
        echo "Port $NEW_PORT" >> $SSH_CONFIG
fi

echo "Changed Port to $NEW_PORT" >> $REPORT

## 3. Install & Configure Fail2ban

echo "[*] Installing Fail2ban..."

if command -v apt >/dev/null 2>&1; then
        apt update -y
        apt install -y fail2ban
elif command -v yum >/dev/null 2>&1; then
        yum install -y epel-release
        yum install -y fail2ban fail2ban-systemd
fi

systemctl enable fail2ban
systemctl restart fail2ban

echo "Installed & Enabled Fail2ban" >> $REPORT


## 4. Disable Unused Services
UNUSED_SERVICES=(cups avahi-daemon bluetooth)

echo "[*] Disabling unused services..."

for svc in "${UNUSED_SERVICES[@]}"; do
        if systemctl list-unit-files | grep -q $svc; then
                systemctl disable --now $svc 2>/dev/null
                echo "Disabled $svc" >> $REPORT
        fi
done

## 5. Sets up basic firewall rules (ufw or firewalld)

echo "[*] Configuring Firewall...."
if command -v firewalld >/dev/null 2>&1 || systemctl list-unit-files | grep -q firewalld; then

        systemctl enable firewalld --now
        firewall-cmd --permanent --add-port=$NEW_PORT/tcp
        firewall-cmd --permanent --add-service=ssh
        firewall-cmd --reload

        FIREWALL="firewalld"
        echo "Configured firewalld" >> $REPORT
elif command -v ufw >/dev/null 2>&1; then

        ufw allow $NEW_PORT/tcp
        ufw allow ssh
        ufw --force enable

        FIREWALL="ufw"
        echo "Configured ufw" >> $REPORT
else
        echo "No firewall found. Instead ufw or firewalld manually." >> $REPORT
fi

## 6. Restart SSH

echo "[*] Restarting SSH service.."

if systemctl restart ssh 2>/dev/null; then
        SSH_NAME="sshd"
elif systemctl restart ssh 2>/dev/null; then
        SSH_NAME="ssh"
fi

echo "Restarted SSH Service: $SSH_NAME" >> $REPORT


## 7. Create a report of what was changes.

echo "----------------------------------" >> $REPORT
echo "Hardening Completed at: $(date)" >> $REPORT
echo "Report saved to: $REPORT"

echo -e "\n Security Hardening Complete!"
echo "Report saved at: $REPORT"