#!/bin/bash

# 1. Handle errors — exit if arguments are missing or source doesn't exist
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing arguments."
    echo "Usage: $0 <source_directory> <backup_destination>"
    exit 1
fi

source_dir="$1"
backup_dir="$2"

if [ ! -d "$source_dir" ]; then
    echo "Error: Source directory '$source_dir' does not exist."
    exit 1
fi

# Ensure backup destination directory exists
mkdir -p "$backup_dir"

# 2. Creates a timestamped .tar.gz archive
timestamp=$(date +%Y-%m-%d)
archive_name="backup-${timestamp}.tar.gz"
archive_path="${backup_dir}/${archive_name}"

tar -czf "$archive_path" -C "$(dirname "$source_dir")" "$(basename "$source_dir")"

# 3. Verifies the archive was created successfully
if [ $? -eq 0 ] && [ -f "$archive_path" ]; then
    echo "Archive created successfully!"
    
    # 4. Prints archive name and size
    echo "Archive Name: $archive_name"
    # Using 'du -sh' for human-readable size (e.g., 10M, 2G)
    echo "Archive Size: $(du -sh "$archive_path" | cut -f1)"
else
    echo "Error: Failed to create archive."
    exit 1
fi

# 5. Deletes backups older than 14 days from the destination
echo "Cleaning up backups older than 14 days in $backup_dir..."
find "$backup_dir" -type f -name "backup-*.tar.gz" -mtime +14 -exec rm {} \;

echo "Backup process complete."

