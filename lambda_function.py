import json


def lambda_handler(event, context):
    original_text = event.get("text", "")
    uppercased_text = original_text.upper()

    return {"statusCode": 200, "body": json.dumps({"original": original_text, "uppercased": uppercased_text})}
