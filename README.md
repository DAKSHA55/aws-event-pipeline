# AWS Event-Driven CSV Processing Pipeline

This project implements a serverless, event-driven data pipeline using AWS services and is fully provisioned using Terraform.

## Overview

- Upload a `.csv` file to the **input S3 bucket**
- Automatically triggers an AWS Lambda function
- Lambda processes the file, counts the number of rows
- Writes a summary report to the **output S3 bucket**

## AWS Services Used

- **Amazon S3** – Storage for input files and output reports
- **AWS Lambda** – Executes processing logic
- **IAM** – Defines execution role and permissions
- **S3 Event Notifications** – Triggers the Lambda function
- **Terraform** – Infrastructure as Code (IaC) to automate deployment

## Files

- `main.tf` – Provisions S3 buckets, Lambda, IAM roles, and event triggers
- `lambda/lambda_function.py` – Python code for the Lambda function
- `function.zip` – Packaged Lambda function code (auto-generated)
