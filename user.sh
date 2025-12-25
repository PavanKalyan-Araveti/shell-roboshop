#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
MONGODB_HOST="mongodb.apavan.space"
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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling Nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Nodejs"

id roboshop &>>$LOG_FILE

if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /bin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else 
    echo  -e "User already exist... $Y Skipping $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading user application"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "Unzip user"

npm install &>>$LOG_FILE
VALIDATE $? "Install dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Copy systemctl service"

systemctl daemon-reload
systemctl enable user &>>$LOG_FILE
VALIDATE $? "Enable user"

systemctl restart user
VALIDATE $? "Restart user"