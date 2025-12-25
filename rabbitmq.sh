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
SCRIPT_DIR=$(pwd)
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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing rabbitmq"
systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling rabbitmq"
systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Starting rabbitmq"

rabbitmqct1 add_user roboshop roboshop123 &>>$LOG_FILE
rabbitmqct1 set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "Setting up permissions"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: %Y $TOTAL_TIME seconds$N"

