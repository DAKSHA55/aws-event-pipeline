# AWS Event-Driven CSV Processing Pipeline

This project implements an event-driven pipeline using AWS services and Terraform.

## Overview

- Upload a `.csv` file to the `input` S3 bucket
- Triggers a Lambda function
- Lambda reads the file, counts rows, and writes a summary report to the `output` S3 bucket

## AWS Services Used

- Amazon S3
- AWS Lambda
- IAM (Role + Policy)
- S3 Event Notifications
- Terraform

## Files

- `main.tf`: Terraform script to deploy S3 buckets, Lambda, IAM roles, and triggers
- `lambda_function.py`: Code that runs when new CSV is uploaded
- `function.zip`: Zipped Lambda package
