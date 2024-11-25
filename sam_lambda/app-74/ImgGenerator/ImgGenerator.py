import base64
import boto3
import json
import random
import os

bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3")

MODEL_ID = os.environ.get("MODEL_ID", "amazon.titan-image-generator-v1")
BUCKET_NAME = os.environ["BUCKET_NAME"]
CANDIDATE_NUMBER = os.environ["CANDIDATE_NUMBER"]

def lambda_handler(event, context):
    body = json.loads(event["body"])
    prompt = body.get("prompt", "Default prompt")
    seed = random.randint(0, 2147483647)
    s3_image_path = f"{CANDIDATE_NUMBER}/generated_images/titan_{seed}.png"

    native_request = {
        "taskType": "TEXT_IMAGE",
        "textToImageParams": {"text": prompt},
        "imageGenerationConfig": {
            "numberOfImages": 1,
            "quality": "standard",
            "cfgScale": 8.0,
            "height": 512,
            "width": 512,
            "seed": seed,
        },
    } ## fdfsfw

    response = bedrock_client.invoke_model(
        modelId=MODEL_ID,
        body=json.dumps(native_request)
    )

    model_response = json.loads(response["body"].read())
    base64_image_data = model_response["images"][0]
    image_data = base64.b64decode(base64_image_data)

    s3_client.put_object(Bucket=BUCKET_NAME, Key=s3_image_path, Body=image_data)

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Image generated and uploaded to S3 successfully!"})
    }
