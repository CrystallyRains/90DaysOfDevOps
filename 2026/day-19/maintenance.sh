#!/bin/bash

LOG_FILE="./maintenance.log"

{
    echo "===== Maintenance started: $(date) ====="

    echo "--- Log Rotation ---"
    ./log_rotate.sh test_logs

    echo "--- Backup ---"
    ./backup.sh test_logs backups

    echo "===== Maintenance completed: $(date) ====="
    echo
} >> "$LOG_FILE" 2>&1

echo "Maintenance completed. Output logged to $LOG_FILE"
