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

VALIDATE $? "Disablling nodejs" &>> $LOGFILE

dnf module enable nodejs:18 -y

VALIDATE $? "Enable nodejs 18" &>> $LOGFILE

dnf install nodejs -y

VALIDATE $? "Installing nodejs 18" &>> $LOGFILE

useradd roboshop

VALIDATE $? "Roboshop user added" &>> $LOGFILE

mkdir /app

VALIDATE $? "Creating app directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "Downloading catalogue" &>> $LOGFILE

cd /app 

unzip /tmp/catalogue.zip

VALIDATE $? "Unziping" &>> $LOGFILE

npm install 

VALIDATE $? "Installing denpendancies" &>> $LOGFILE

# 
cp /home/centos/roboshop-shell/catalogue.serivce /etc/systemd/system/catalogue.service

VALIDATE $? "coping catalogue servie file" &>> $LOGFILE

systemctl daemon-reload

VALIDATE $? "catalogue deamon reload" &>> $LOGFILE

systemctl enable catalogue

VALIDATE $? "Enabling" &>> $LOGFILE

systemctl start catalogue

VALIDATE $? "Catalogue s" &>> $LOGFILE

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copy mongodb s" &>> $LOGFILE

dnf install mongodb-org-shell -y

VALIDATE $? "Installing mandogb client" &>> $LOGFILE

mongo --host $MONGODB_HOST </app/schema/catalogue.js

VALIDATE $? "Loading catalogue data into mongodb" &>> $LOGFILE



