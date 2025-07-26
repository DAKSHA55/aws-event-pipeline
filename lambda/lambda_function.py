import json
import csv
import boto3

def lambda_handler(event, context):
    s3 = boto3.client('s3')

    # Get file details from event
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    # Download file from S3
    local_file = '/tmp/input.csv'
    s3.download_file(bucket, key, local_file)

    # Read CSV and process
    total_rows = 0
    with open(local_file, 'r') as f:
        reader = csv.reader(f)
        for row in reader:
            total_rows += 1

    # Prepare output content
    result = f"Total rows in file '{key}': {total_rows}"

    # Save to output bucket
    output_bucket = 'csv-output-bucket-kshitij'
    output_key = key.replace('.csv', '_report.txt')
    s3.put_object(Bucket=output_bucket, Key=output_key, Body=result)

    return {
        'statusCode': 200,
        'body': json.dumps('Report generated successfully')
    }
