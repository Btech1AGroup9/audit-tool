#!/bin/bash

#Report Timestamp
timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
report_dir="$HOME/myproject/docs"
report_file="$report_dir/audit_report_$timestamp.txt"


touch "$report_file"

echo -e "\n===Security Audit Report - $timestamp===" >> "$report_file"
echo "===================================================" >> "$report_file"

#Checking for Open Ports
echo -e "\n[====Open Ports====]" >> "$report_file"
if ss -tuln >> "$report_file"; then
echo "Open Ports retrieved successfully." >> "$report_file"
else
echo "Failed to retrieve Open Ports!." >> "$report_file"
echo "===============================================" >> "$report_file"
fi

#Failed Login Attempts
echo -e "\n[====Failed Logins====]" >> "$report_file"
if grep -a "$Failed password" /var/log/auth.log > /dev/null; then
grep -a "$Failed password" /var/log/auth.log | tail -n 10 >> "$report_file"
echo "Failed Login attempts recorded." >> "$report_file"
else
echo "Could not access /var/log/auth.log." >> "$report_file"
echo "===============================================" >> "$report_file"
fi

#User Permissions
echo -e "\n[====User Permissions====]" >> "$report_file"
if getent passwd > /dev/null; then
getent passwd | awk -F: '{ print $3 " -> UID: "$1", Shell: "$7 }' >> "$report_file"
echo "User Permission Data gathered." >> "$report_file"
else
echo "Failed to gather user permission data!." >> "$report_file"
echo "================================================" >> "$report_file"
fi

#Group Memberships
echo -e "\n[====Group Memberships====]" >> "$report_file"
echo "List of group memberships." >> "$report_file"

for username in $(cut -d: -f1 /etc/passwd); do
group_info=$(groups "$username" 2>/dev/null)
if [ -n "$group_info" ]; then
echo "$username: $group_info" >> "$report_file"
else
echo "$username: No group memberships found." >> "$report_file"
fi
done
echo "===================================================" >> "$report_file"


#Optinal Sync
cloud_backup="/mnt/cloud/audit/audit_backups/"
echo -e "\n[======Cloud Sync======]" >> "$report_file"
echo "Security Audit Done! Report saved at: $report_file"

if [ -f "$report_file" ]; then
if mount | grep -q "/mnt/cloud"; then
rsync -avh "$report_file" "$cloud_backup"

if [ $? -eq 0 ];then
echo "Cloud Sync Successful! Report backed up to $cloud_backup" >> "$report_file"
else
echo "Cloud Sync failed! Please check your connection or path." >> "$report_file"
fi
else
echo "Cloud path not mounted. Sync skipped." >> "$report_file"
fallback_path="/home/shadrack/myproject/cloud_fallback"
mkdir -p "$fallback_path"
rsync -avh "$report_file" "$fallback_path"
echo "Report copied to:" "$fallback_path" >> "$report_file"
fi
echo "Audit Completed at: $(date '+%Y-%m-%d %H:%M:%S')" >> "$report_file"
else
echo "Report file not found" >> "$report_file"
fi
