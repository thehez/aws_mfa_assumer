#!/bin/bash

## quick script to assume roles and pass details to aws config
## get role information
read -p 'Enter MFA ARN: ' mfa_arn
read -p 'Enter MFA Token: ' token
read -p 'Enter Profile to use: ' profile_name

# call role assumption
temp_role=$(aws sts get-session-token --serial-number $mfa_arn --token-code $token --profile $profile_name)


#temp_role=$(aws sts assume-role --role-arn $role_arn --role-session-name $role_session_name --profile $profile_name)

# update aws configuration
# export variables
export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)

# create new profile in config
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile mfa
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile mfa
aws configure set aws_session_token $AWS_SESSION_TOKEN --profile mfa