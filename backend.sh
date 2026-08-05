#!/bin/bash

source ./common.sh

check_root

echo "Please enter DB password:"
read -s mysql_root_password


dnf module disable nodejs -y &>>$LOGFILE
dnf module enable nodejs:20 -y &>>$LOGFILE
dnf install nodejs -y &>>$LOGFILE

id expense &>>$LOGFILE # whe set -e and trap is used this will be treated as error because expense user is not created yet
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
else
    echo -e "Expense user already created...$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE # -p if file exists silents and don't throw error if file not present creates new file

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE

npm install &>>$LOGFILE

# Giving absolute path
# Check your path and repo
cp /home/ec2-user/expense-shell-1-re/backend.service /etc/systemd/system/backend.service &>>$LOGFILE

systemctl daemon-reload &>>$LOGFILE

systemctl start backend &>>$LOGFILE

systemctl enable backend &>>$LOGFILE

dnf install mysql -y &>>$LOGFILE

mysql -h db.daws-78s.shop -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE

systemctl restart backend &>>$LOGFILE

