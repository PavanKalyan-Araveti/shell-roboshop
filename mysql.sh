#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)
echo "Scripting started executing at : $(date)"

if [ $USERID -ne 0 ]; then
    echo "ERROR: Please run this script with root privilage"
    exit -1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 is $R Failure $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is $G success $N" | tee -a $LOG_FILE
    fi
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing mysql"
systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling mysql"
systemctl start mysqld&>>$LOG_FILE
VALIDATE $? "Starting mysql"

mysql_secure_installation --set-root-pass Roboshop@1
VALIDATE $? "Setting up user and pass"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: %Y $TOTAL_TIME seconds$N"

