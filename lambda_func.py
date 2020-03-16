import boto3
import datetime

s3 = boto3.resource('s3')
content="One more hour have passed... "
s3.Object('the-bucket-head', 'new-time.txt').put(Body=content)
