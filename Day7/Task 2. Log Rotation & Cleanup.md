## Ticket summary: 
**Log Rotation and Cleanup Description:** You need to implement a log rotation system on your server where logs older than 30 days are deleted, and a new log file is created every day. This should be applied to application logs in `/var/log/app_logs/`.

**Requirements:**
- Create a script that checks for log files older than 30 days and removes them.
- Ensure that a new log file is created every day with a timestamp.
- Ensure that logs are compressed for archival.