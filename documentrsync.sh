#!/bin/bash

# Set the source and destination directories
source_dir="/home/jsingape/"  # Replace with your actual home directory
dest_dir="/mnt/winshare/rasp4-dump/rasp-docs-2025"  # Replace with the actual mount point of your CIFS share

# Set the log file location
log_file="/path/to/rsync_backup.log"  # Replace with the desired log file path

# Use rsync to perform the backup
rsync -r -t -p -o -g -D -vzh --no-links --progress \
      --exclude=".*" \  "$source_dir" "$dest_dir" >> "$log_file" 2>&1

# Add a timestamp to the log file
echo "$(date) - Backup completed" >> "$log_file"
