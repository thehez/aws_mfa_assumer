# MFA Get Session Token

## Overview

This is a simple script that enables you to quickly update your AWS credentials with an MFA token. The script calls the AWS STS endpoint to retrieve a session token for use with an MFA profile and updates your ~/.aws/credentials file. The script will also optionally allow you to assume a role using the MFA profile if required.

NOTE - Requires JQ to be installed

## Use

Retrieve the ARN of your MFA profile from your security credentials within the AWS console and follow the prompts to update your profile. 
