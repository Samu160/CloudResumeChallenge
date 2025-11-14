import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('resume-visitor-counter')

def lambda_handler(event, context):
    try:

        # get current views
        response = table.get_item(Key={
            'counterID': '1'
        })
        views = int(response['Item']['views'])
        views = views + 1
        print(views)

        # update views
        table.put_item(Item={'counterID': '1', 
        'views': views
        })

        # return HTTP response
        return {
            "statusCode": 200,
            "headers": {
                "content-type": "application/json",
                "access-control-allow-origin": "*"
            },
            "body": json.dumps({
                "views": views
            })
        }

    except Exception as e:
        # return a readable error message
        return {
            "statusCode": 500,
            "headers": {"content-type": "application/json"},
            "body": json.dumps({
                "error": str(e)
            })
        }