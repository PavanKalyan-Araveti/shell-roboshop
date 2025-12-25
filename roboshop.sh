#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0d9388090da2dfd31"

for instance in $@
do
   Instance_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output tex)

   if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids i-0908b777cb346a92b --query 'Reservations[0].Instances[0].PrivateIpAddress' --output $instance)
   else
        IP=$(aws ec2 describe-instances --instance-ids i-0908b777cb346a92b --query 'Reservations[0].Instances[0].PublicIpAddress' --output $instance)
   fi

   echo "$instance: $IP"
done