#!/bin/bash

## quick script to grab a session token for an MFA arn and update AWS Creds file
## get role information
read -p 'Enter ARN of MFA account: ' mfa_arn
read -p 'Enter MFA Token: ' token
read -p 'Enter Profile to use: ' profile_name

# call STS for session token
temp_role=$(aws sts get-session-token --serial-number $mfa_arn --token-code $token --profile $profile_name)

# export variables
export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)

# Add session to AWS config
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile mfa
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile mfa
aws configure set aws_session_token $AWS_SESSION_TOKEN --profile mfa