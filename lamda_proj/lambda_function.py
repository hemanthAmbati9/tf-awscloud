import os
import json
import boto3
import datetime
import uuid

s3 = boto3.client('s3')
bucket = os.environ.get('S3_BUCKET')

def lambda_handler(event, context):
    """
    AWS Lambda handler to receive SNS messages and write them as JSON files to S3.
    """
    # The event may contain multiple Records when SNS batch delivers
    records = event.get('Records', [])
    saved = []
    for rec in records:
        # SNS message payload
        sns = rec.get('Sns', {})
        message_id = sns.get('MessageId', str(uuid.uuid4()))
        subject = sns.get('Subject', 'no-subject')
        message = sns.get('Message', '')
        timestamp = sns.get('Timestamp', datetime.datetime.utcnow().isoformat())

        obj = {
            "message_id": message_id,
            "subject": subject,
            "timestamp": timestamp,
            "message": message,
            "raw_sns": sns
        }

        key = f"sns-logs/{datetime.datetime.utcnow().strftime('%Y/%m/%d')}/{message_id}.json"
        try:
            s3.put_object(
                Bucket=bucket,
                Key=key,
                Body=json.dumps(obj),
                ContentType='application/json'
            )
            saved.append(key)
        except Exception as e:
            print(f"Failed to upload to s3: {e}")
            raise

    return {
        "statusCode": 200,
        "saved_keys": saved
    }
