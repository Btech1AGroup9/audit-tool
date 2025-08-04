#!/bin/bash
REPO="/home/shadrack/audit-tool"
LOG="$REPO/outputs_$(date).log"
cd "$REPO" || exit 1
ping -c 1 github.com > /dev/null 2>&1
if [ $? -n 0 ]; then
echo "Github unreachable." | tee -a "$LOG"
exit 1
fi

git add .
git commit -m "Auto sync $(date)" && \
git push origin master && \
echo "Sync complete" | tee -a "$LOG"
