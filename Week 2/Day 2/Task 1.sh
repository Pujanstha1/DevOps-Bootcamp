#!/bin/bash

<< Task
Create a bash script that shows everything at onceserver-dashboard.sh
- clears screen and shows in color:
- Server name & uptime
- Current user & date
- Disk, memory & CPU usage
- Your external IP
- Last 3 login attempts
Task

#Task 1.1
# Setup Colors
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

#Task 1.2
#Clears Screen and shows in color
clear

echo -e "${CYAN}========================= OnceServer-Dashboard =========================${RESET}"


#Servername and Uptime
echo -e "${RED}-------------------------- SERVERNAME & UPTIME ------------------------- ${RESET}"
echo -e "${GREEN}Servername: ${RESET} $(hostname)"
echo -e "${GREEN}Uptime: ${RESET} $(uptime -p)"

## Current User and Date
echo
echo -e "${YELLOW}Current User: ${RESET} $USER"
echo -e "${YELLOW}Date: ${RESET} $(date)"

## Disk Memory and CPU Usage
echo

## Disk Usage
echo -e "${GREEN}Disk Memory: ${RESET}"
df -h | grep -v tmpfs

## Memory Usage
echo
echo -e "${GREEN}Memory Usage: ${RESET}"
free -h         #Lists free memory in human readable form

## CPU Usage
echo
echo -e "${GREEN}CPU Usage: ${RESET}"
ps -eo pid,comm,%cpu --sort=-%cpu | head -6

# Your External IP
echo
echo -e "${GREEN}Your External IP: ${RESET}"
curl icanhazip.com

# Last 3 Login Attemps
echo
echo -e "${RED}Last 3 Login attemps: ${RESET}"
last -n 3

echo
echo -e "${CYAN}=================================================="