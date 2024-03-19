#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.pkljs.tech

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y

VALIDATE $? "Disablling nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enable nodejs 18" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing nodejs 18"
id roboshop
if [ $? -ne 0 ]
then
   useradd roboshop
   VALIDATE $? "Roboshop user creation"
else
   echo -e "roboshop iser already exits $Y SKIPPING $N"
fi

mkdir -p /app

VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "Downloading catalogue"

cd /app 

unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "Unziping"

npm install &>> $LOGFILE

VALIDATE $? "Installing denpendancies"

cp /home/centos/roboshop-shell/catalogue.serivce /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "coping catalogue servie file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue deamon reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enabling"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Catalogue s"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copy mongodb s"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mandogb client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js

VALIDATE $? "Loading catalogue data into mongodb"



