# Log Rotation & Cleanup -- Documentation

## **Task Summary**

Implement a log rotation system on a Linux server to: - Create a new log
file every day with a timestamp. - Compress older logs for archival. -
Delete logs older than **30 days**. - Apply all operations to:\
**`/var/log/app_logs/`**

A cron job triggers the script daily at midnight.

------------------------------------------------------------------------

## **Requirements & How They Are Met**

### **1. Delete logs older than 30 days**

The script uses the `find` command to delete `.log` and `.log.gz` files
older than 30 days:

``` bash
find "$LOG_DIR" -type f -mtime +30 -name "app_log_*.log*" -exec rm -rf {} \;
```

------------------------------------------------------------------------

### **2. Create a new log file every day**

The script generates a log file using today's date:

``` bash
TODAY=$(date +%F)
NEW_LOG="${LOG_DIR}/app_log_${TODAY}.log"
touch "$NEW_LOG"
```

------------------------------------------------------------------------

### **3. Compress logs older than 1 day**

All previous day `.log` files (except today's) get compressed:

``` bash
for file in ${LOG_DIR}/app_log_*.log; do
    if [[ $file != "$LOG_DIR/app_log_$TODAY.log" ]]; then
        gzip -f "$file"
    fi
done
```

------------------------------------------------------------------------

## **Final Script**

``` bash
#!/bin/bash

# ---------------- Log Rotation & Cleanup ----------------

# Directory where application logs are stored
LOG_DIR="/var/log/app_logs"

# Create the directory if it does not exist
if [[ ! -d "$LOG_DIR" ]]; then
    sudo mkdir -p "${LOG_DIR}"
    if [[ ! -d "${LOG_DIR}" ]]; then
        echo "Error: Failed to create the Directory!"
        exit 1
    else
        echo "Log Directory Created!"
    fi
fi

# Get today's date in YYYY-MM-DD format
TODAY=$(date +%F)

# Name of the new log file
NEW_LOG="${LOG_DIR}/app_log_${TODAY}.log"

# Create a new log file for today if it doesn't exist
if [[ ! -f "${NEW_LOG}" ]]; then
    sudo touch "$NEW_LOG"
    echo "Created a new logfile: '${NEW_LOG}'"
fi

# Compress logs older than 1 day
for file in ${LOG_DIR}/app_log_*.log; do
    if [[ $file != "$LOG_DIR/app_log_$TODAY.log" ]]; then
        sudo gzip -f "$file"
    fi
done

# Delete logs older than 30 days (both .log and .gz)
find "$LOG_DIR" -type f -mtime +30 -name "app_log_*.log*" -exec rm -rf {} \;

echo "Log Rotation and Cleanup Completed!"
```

------------------------------------------------------------------------

## **Cron Job Configuration**

To run the script daily at midnight:

``` bash
crontab -e
```

Add:

``` bash
0 0 * * * /home/pujan/devops-lab/log-rotation.sh
```

------------------------------------------------------------------------

## **Notes**

-   Ensure the script has execute permission:

    ``` bash
    chmod +x /home/pujan/devops-lab/log-rotation.sh
    ```

-   Log directory must be writable by the script user.

-   `sudo` inside cron may require NOPASSWD configuration.

------------------------------------------------------------------------
