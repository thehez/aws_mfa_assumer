# MFA Get Session Token

NOTE - Requires JQ to be installed

This is a simple script to call the AWS STS endpoint to retrieve a session token for use with an MFA profile and update your ~/.aws/credentials file. Will also optionally allow you to assume a role with the MFA profile if required.

Retrieve the ARN of your MFA profile from you security credentials within the AWS console and follow the prompts to update your profiles. 