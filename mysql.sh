#!/bin/bash


dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting MySQL Server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up root password"

# Below code is will be useful for idempotent nature
# -e is to enable for command --> show databases
# First time while running if block executes and sets up password
# Second time when ran the password is already setup it will skip setting password agian

mysql -h db.daws-78s.shop -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} $>>$LOGFILE
    VALIDATE $? "MySQL root password setup"
else
    echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi
