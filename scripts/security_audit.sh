#!/bin/bash

#Report Timestamp
base_dir="$HOME/audit-tool"
cloud_backup="$base_dir/backups"
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
audit_report="$base_dir/outputs"
report_file="$base_dir/outputs_$timestamp"

echo "Starting audit..." >> "$report_file"
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
grep -a "$Failed password" /var/log/auth.log | tail -n 20 >> "$report_file"
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


#Report summary
echo -e "\n[======Audit Report Summary======]" >> "$report_file"
echo "Report Generated at: $(date)" >> "$report_file"
echo "Report Path: $report_file" >> "$report_file"
echo "Audit completed at $(date)" >> "$report_file"
echo "===================================================" >> "$report_file"

#Optional Cloud Sync
echo -e "\n[======Cloud Sync======]" >> "$report_file"
echo "Sync started at: $(date)" >> "$report_file"

if rsync -avh "$report_file" "$cloud_backup" >> "$report_file" 2>&1; then
echo "Cloud Sync Succeeded at: $(date)" >> "$report_file"
echo "Report synced to $cloud_backup" >> "$report_file"
else
echo "Cloud Sync failed at: $(date)" >> "$report_file"
echo "Report file is stored at: $report_file" >> "$report_file" 2>&1
echo "Audit Completed at: $(date)" >> "$report_file"
echo "Report file remains at: $report_file" >> "$report_file"
fi
echo "Audit Completed at: $(date)" >> "$report_file"
echo "======================================================" >> "$report_file"
echo -e "\nCloud Sync Succeeded at: $(date)" 


#GitHub Sync Attempt
echo -e "\n[======GitHub Sync Attempt======]" >> "$report_file"
echo "GitHub Sync started at: $(date)" >> "$report_file"
git add . >> "$report_file" 2>&1
commit_message="Security Audit Report $timestamp"
git commit -m "$commit_message" >> "$report_file" 2>&1
if git push -u origin master >> "$report_file" 2>&1; then
echo -e "\nGitHub sync succeeded at: $(date)"
echo "GitHub sync succeeded at: $(date)" >> "$report_file"
echo "Report synced to: git@github.com:shaddie123/audit-tool.git" >> "$report_file"
else
echo "GitHub sync failed at: $(date)"
echo "GitHub sync failed at: $(date)" >> "$report_file"
echo "Check Git configuration and remote setup." >> "$report_file"
fi
echo -e "\nReport successfully saved at $report_file"

