#!/bin/bash

##############################################
# Description: Create VPC in AWS
# Add a command line argument create to create the vpc and subnet.
# Add a command line argument teardown to delete the vpc and subnet.
# - Create a VPC
# - Create a public subnet
# Verify if user has aws installed, user might be using windows, linux or mac.
# Verify if aws cli is configured.
##############################################

# Variables
VPC_CIDR="10.0.0.0/16"
SUBNET_CIDR="10.0.3.0/24"
REGION="us-east-1"
VPC_NAME="demo-vpc"
SUBNET_NAME="demo-subnet"
SUBNET_AZ="us-east-1a"

# Verify if aws cli is installed
if ! command -v aws &> /dev/null
then    
    echo "AWS CLI could not be found. Please install AWS CLI to proceed."
    exit 1
fi

# Verify if aws cli is configured
if ! aws sts get-caller-identity &> /dev/null
then
    echo "AWS CLI is not configured. Please configure AWS CLI to proceed."
    exit 1
fi

# Create or delete VPC and Subnets based on command line argument.
if [ "$1" == "create" ]; then
    # Create VPC and tag it
    VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --region $REGION --query 'Vpc.VpcId' --output text)
    echo "Created VPC with ID: $VPC_ID"
    aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=$VPC_NAME --region $REGION
    echo "Tagged VPC with Name: $VPC_NAME"

    # Create Public Subnet and tag it
    SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR --availability-zone $SUBNET_AZ --region $REGION --query 'Subnet.SubnetId' --output text)
    echo "Created Subnet with ID: $SUBNET_ID"
    aws ec2 create-tags --resources $SUBNET_ID --tags Key=Name,Value=$SUBNET_NAME --region $REGION
    echo "Tagged Subnet with Name: $SUBNET_NAME"

    echo "VPC and Subnet creation completed successfully."

elif [ "$1" == "teardown" ]; then
    # Find VPC ID by Name tag
    VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_NAME" --region $REGION --query 'Vpcs[0].VpcId' --output text)

    if [ "$VPC_ID" == "None" ]; then
        echo "No VPC found with Name: $VPC_NAME"
        exit 1
    fi

    # Find Subnet ID by Name tag
    SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$SUBNET_NAME" --region $REGION --query 'Subnets[0].SubnetId' --output text)

    # Delete Subnet
    if [ "$SUBNET_ID" != "None" ]; then
        aws ec2 delete-subnet --subnet-id $SUBNET_ID --region $REGION
        echo "Deleted Subnet with ID: $SUBNET_ID"
    else
        echo "No Subnet found with Name: $SUBNET_NAME"
    fi

    # Delete VPC
    aws ec2 delete-vpc --vpc-id $VPC_ID --region $REGION

    # End of script
    echo "Deleted VPC with ID: $VPC_ID"
    else
        echo "No VPC found with Name: $VPC_NAME"
        exit 1
    fi
