#!/bin/bash

if ! aws --version; then
    sudo apt update
    sudo apt install unzip -y
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2aa.zip"
    unzip awscliv2.zip
    sudo ./aws/install || rm -fr aws && unzip awscliv2aa.zip && sudo ./aws/install --update
fi

# Variables
BACKUP_DATE=$(date +"%Y-%m-%d")
BACKUP_FILENAME="backup-$BACKUP_DATE.tar.bz2"
BACKUP_DIRS="/etc /home /root"
S3_BUCKET="s3://aa-dd-andrew-thomas"

# Create the archive
echo "Creating backup archive..."
tar -cjf "$BACKUP_FILENAME" $BACKUP_DIRS

# Check if the archive was created successfully
if [ $? -ne 0 ]; then
    echo "Error: Failed to create the backup archive."
    exit 1
fi

echo "Backup archive created: $BACKUP_FILENAME"

# Upload the archive to S3
echo "Uploading backup to S3 bucket $S3_BUCKET..."
aws s3 cp "$BACKUP_FILENAME" "$S3_BUCKET/"

# Check if the upload was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to upload the backup to S3."
    exit 1
fi

echo "Backup successfully uploaded to $S3_BUCKET"

# Optionally, remove the local backup file after successful upload
# Uncomment the following line if you want to delete the local backup
# rm "$BACKUP_FILENAME"

echo "Backup process completed successfully."
