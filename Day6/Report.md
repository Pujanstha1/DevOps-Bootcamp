## Task 1. OnceServer Dashboard Script Documentation

## Overview
`onceserver-dashboard.sh` is a Bash script designed to provide a comprehensive view of your server’s status in a single glance. The script displays key information such as server name, uptime, current user, system resource usage, external IP, and last login attempts. It uses colors for better readability.

---


## Script Sections

### 1.1 Setup Colors
```bash
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"
```

**Explanation:**
- `\e[32m` sets the text color to **green**  
- `\e[36m` sets the text color to **cyan**  
- `\e[33m` sets the text color to **yellow**  
- `\e[31m` sets the text color to **red**  
- `\e[0m` resets the color back to default  

These color codes are used with `echo -e` to make the output visually appealing.

---

### 1.2 Clear Screen and Header
```bash
clear
echo -e "${CYAN}========================= OnceServer-Dashboard =========================${RESET}"
```

**Explanation:**
- `clear` clears the terminal for a fresh dashboard view  
- The header is displayed in **cyan** using the variable `${CYAN}`  

---

### Server Name & Uptime
```bash
echo -e "${RED}-------------------------- SERVERNAME & UPTIME ------------------------- ${RESET}"
echo -e "${GREEN}Servername: ${RESET} $(hostname)"
echo -e "${GREEN}Uptime: ${RESET} $(uptime -p)"
```

**Explanation:**
- `hostname` returns the server’s hostname  
- `uptime -p` returns a human-readable uptime (e.g., "up 2 hours, 35 minutes")  

---

### Current User & Date
```bash
echo
echo -e "${YELLOW}Current User: ${RESET} $USER"
echo -e "${YELLOW}Date: ${RESET} $(date)"
```

**Explanation:**
- `$USER` is an environment variable containing the current logged-in user  
- `date` displays the current system date and time  

---

### Disk, Memory & CPU Usage

#### Disk Usage
```bash
echo -e "${GREEN}Disk Memory: ${RESET}"
df -h | grep -v tmpfs
```

**Explanation:**
- `df -h` shows disk usage in a human-readable format  
- `grep -v tmpfs` excludes temporary file systems from the display  

#### Memory Usage
```bash
echo
echo -e "${GREEN}Memory Usage: ${RESET}"
free -h
```

**Explanation:**
- `free -h` displays memory usage in a human-readable format  

#### CPU Usage
```bash
echo
echo -e "${GREEN}CPU Usage: ${RESET}"
ps -eo pid,comm,%cpu --sort=-%cpu | head -6
```

**Explanation:**
- `ps -eo pid,comm,%cpu` lists the PID, command, and CPU usage of processes  
- `--sort=-%cpu` sorts the processes by CPU usage in descending order  
- `head -6` shows only the top 5 CPU-consuming processes (plus header)  

---

### External IP
```bash
echo
echo -e "${GREEN}Your External IP: ${RESET}"
curl icanhazip.com
```

**Explanation:**
- `curl icanhazip.com` fetches the public IP of the server  

---

### Last 3 Login Attempts
```bash
echo
echo -e "${RED}Last 3 Login attemps: ${RESET}"
last -n 3
```

**Explanation:**
- `last -n 3` displays the last three login attempts  

---

### Footer
```bash
echo
echo -e "${CYAN}==================================================${RESET}"
```

**Explanation:**
- Adds a colored footer for aesthetic separation  

---

## Usage
1. Save the script as `onceserver-dashboard.sh`  
2. Make it executable:
```bash
chmod +x onceserver-dashboard.sh
```
3. Run the script:
```bash
./onceserver-dashboard.sh
```
### Output
![alt text](images/task1.png)
---
---

## Task 2 MyIP Script Documentation

## Overview
`myip.sh` is a Bash script that quickly displays the private and public IP addresses of your server. It is designed to answer the common question: "What is the IP of this server?" in a clear and visually appealing way.

---



## Script Sections

### 1. Variables
```bash
PRIVATE_IP=$(hostname -I)
PUBLIC_IP=$(curl icanhazip.com)
```
**Explanation:**
- `hostname -I` returns all private IP addresses of the server
- `curl icanhazip.com` fetches the public IP address from an external service

---

### 2. Colors
```bash
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"
```
**Explanation:**
- Defines ANSI color codes for styling the output
- `${RESET}` resets color back to default after each colored output

---

### 3. Clear Screen and Header
```bash
clear
echo -e "${CYAN}========== MY SERVER IP ADDRESSES ==========${RESET}"
```
**Explanation:**
- Clears the terminal to show the script output clearly
- Prints a header in cyan to highlight the script’s purpose

---

### 4. Display Private IP
```bash
echo -e "${GREEN}Your Private IP: ${RESET}"
echo $PRIVATE_IP
echo
```
**Explanation:**
- Displays the server’s private IP address in green for emphasis
- Adds an empty line for spacing

---

### 5. Display Public IP
```bash
echo -e "${GREEN}Your Public IP: ${RESET}"
echo $PUBLIC_IP
```
**Explanation:**
- Displays the server’s public IP address in green for emphasis

---

### 6. Footer
```bash
echo -e "${CYAN}============================================${RESET}"
```
**Explanation:**
- Prints a closing line in cyan to visually close the output section

---

## Usage
1. Save the script as `myip.sh`
2. Make it executable:
```bash
chmod +x myip.sh
```
3. Run the script:
```bash
./myip.sh
```

---

## Output
![alt text](images/task2.png)
This output clearly separates private and public IPs for quick reference.




## Task 3. Hardening Script Documentation

## Overview
`harden.sh` is a Bash script designed to apply basic server security best practices. It automates common hardening tasks such as disabling root SSH login, changing the SSH port, installing fail2ban, disabling unused services, configuring a firewall, and generating a report of all changes.

---


## Prerequisites
- Must run as root
- Bash shell (`#!/bin/bash`)
- Linux system with `systemctl` (supports `firewalld` or `ufw`)
- Package manager: `apt` or `yum`

---

## Script Sections

### 1. Root Check
```bash
if [[ "$EUID" -ne 0 ]]; then
        echo "You are logged in as '$USER'. Please login as Root"
        exit 1
fi
```
**Explanation:**
- Ensures the script is run as root; many hardening tasks require administrative privileges

---

### 2. Disable Root Login via SSH
```bash
if grep -q "^PermitRootLogin" $SSH_CONFIG; then
        sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG
else
        echo "PermitRootLogin no" >> $SSH_CONFIG
fi
```
**Explanation:**
- `PermitRootLogin no` disables direct SSH login as root
- Uses `sed` to update existing configuration or appends if not present

---

### 3. Change SSH Port
```bash
NEW_PORT=2222
if grep -q "^Port " $SSH_CONFIG; then
        sed -i "^Port .*/Port $NEW_PORT/" $SSH_CONFIG
else
        echo "Port $NEW_PORT" >> $SSH_CONFIG
fi
```
**Explanation:**
- Changes SSH port to reduce automated attacks on port 22
- Checks if a port is defined and updates or adds it accordingly

---

### 4. Install & Configure Fail2ban
```bash
if command -v apt >/dev/null 2>&1; then
        apt update -y
        apt install -y fail2ban
elif command -v yum >/dev/null 2>&1; then
        yum install -y epel-release
        yum install -y fail2ban fail2ban-systemd
fi
systemctl enable fail2ban
systemctl restart fail2ban
```
**Explanation:**
- Installs `fail2ban` to protect SSH and other services from brute-force attacks
- Enables and starts the service

---

### 5. Disable Unused Services
```bash
UNUSED_SERVICES=(cups avahi-daemon bluetooth)
for svc in "${UNUSED_SERVICES[@]}"; do
        if systemctl list-unit-files | grep -q $svc; then
                systemctl disable --now $svc 2>/dev/null
        fi
done
```
**Explanation:**
- Stops and disables services that are not needed, reducing attack surface

---

### 6. Configure Firewall
```bash
if command -v firewalld >/dev/null 2>&1 || systemctl list-unit-files | grep -q firewalld; then
        systemctl enable firewalld --now
        firewall-cmd --permanent --add-port=$NEW_PORT/tcp
        firewall-cmd --permanent --add-service=ssh
        firewall-cmd --reload
elif command -v ufw >/dev/null 2>&1; then
        ufw allow $NEW_PORT/tcp
        ufw allow ssh
        ufw --force enable
fi
```
**Explanation:**
- Configures firewall rules using `firewalld` or `ufw`
- Allows SSH and the new SSH port
- Ensures firewall is active

---

### 7. Restart SSH
```bash
if systemctl restart ssh 2>/dev/null; then
        SSH_NAME="sshd"
elif systemctl restart ssh 2>/dev/null; then
        SSH_NAME="ssh"
fi
```
**Explanation:**
- Restarts SSH to apply configuration changes
- Detects correct SSH service name

---

### 8. Generate Report
```bash
echo "========== Hardening Report ============" > $REPORT
echo "Started at: $(date)" >> $REPORT
# Logs changes here
echo "Hardening Completed at: $(date)" >> $REPORT
echo "Report saved to: $REPORT"
```
**Explanation:**
- Creates a log of all actions performed
- Includes start and end timestamps

---

## Usage
1. Save the script as `harden.sh`
2. Make it executable:
```bash
chmod +x harden.sh
```
3. Run the script as root:
```bash
sudo ./harden.sh
```
4. View the report:
```bash
cat /var/log/harden-report.log
```

---


![alt text](images/Task3harden.png)

---
Output:

```
[pujan@192 devops-lab]$ cat /var/log/harden-report.log
========== Hardening Report ============
Started at: Mon Nov 24 03:03:06 PM +0545 2025
----------------------------------------
Root Login via SSH
Changed Port to 2222
Installed & Enabled Fail2ban
Disabled cups
Disabled avahi-daemon
Disabled bluetooth
Configured firewalld
Restarted SSH Service:
----------------------------------
Hardening Completed at: Mon Nov 24 03:03:15 PM +0545 2025
```