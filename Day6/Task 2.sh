#!/bin/bash

<<comment
Task 2
Your teammate always asks “What is the IP of this server?”
create a bash script as myip.sh which shows only the
private and public IP in a pretty way.
comment

PRIVATE_IP=$(hostname -I)
PUBLIC_IP=$(curl icanhazip.com)

#Colors
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

clear
echo -e "${CYAN}========== MY SERVER IP ADDRESSES ==========${RESET}"

#Private IP
echo -e "${GREEN}Your Private IP: ${RESET}"
echo $PRIVATE_IP
echo

#Public IP
echo -e "${GREEN}Your Public IP: ${RESET}"
echo $PUBLIC_IP

echo -e "${CYAN}============================================${RESET}"