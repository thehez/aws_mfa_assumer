#!/bin/bash

#exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT


## quick script to grab a session token for an MFA arn and update AWS Creds file
## get role information
read -p 'Enter ARN of MFA account: ' mfa_arn
read -p 'Enter MFA Token: ' token
read -p 'Enter Profile to use: ' profile_name

echo 'Attempting to get session token... '

# call STS for session token
temp_role=$(aws sts get-session-token --serial-number $mfa_arn --token-code $token --profile $profile_name)

if [ $? -eq 0 ]; then
    echo 'Session token recieved, updating AWS Config... '
else
    echo 'Unable to retrieve session token, please check the MFA arn and profile are correct '
    exit
fi

# export variables
export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)

# Add session to AWS config
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile mfa
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile mfa
aws configure set aws_session_token $AWS_SESSION_TOKEN --profile mfa

echo 'AWS Config updated with MFA profile "mfa" '

read -p 'Do you need to perform role assumption with the MFA profile (y/n) ' answer
if [ $answer == 'y' ]; then
    ## get role information
    read -p 'enter the ARN of the role to assume: ' role_arn
    read -p 'enter a name for the role session: ' role_session_name
    echo 'Attempting role assumption... '

    # call role assumption
    temp_role=$(aws sts assume-role --role-arn $role_arn --role-session-name $role_session_name --profile 'mfa')

    if [ $? -eq 0 ]; then
    echo 'Role assumed, updating AWS Config... '
    
    ## update aws configuration
    # export variables
    export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
    export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
    export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)

    # create new profile in config
    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile $role_session_name
    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile $role_session_name
    aws configure set aws_session_token $AWS_SESSION_TOKEN --profile $role_session_name
    echo 'AWS Profile updated'
    exit
    else
    echo 'Unable to assume the role, please check the role trust policy and your permissions are correct '
    exit
    fi
else
    echo 'role assumption not required exiting '
    exit
fi