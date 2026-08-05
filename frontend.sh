#!/bin/bash

source ./common.sh
check_root

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Installing nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing existing content"

# Downloading .zip file multiple times is not a problem
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html &>>$LOGFILE

# previous content is being removed using rm -rf command there is no idempotency problem
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extracting frontend code"

# check your repo and path
cp /home/ec2-user/expense-shell-1-re/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copied expense conf"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting nginx"