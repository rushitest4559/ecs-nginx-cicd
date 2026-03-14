import boto3
import os
import sys
from botocore.exceptions import ClientError

# Configuration
BUCKET_NAME = "rushi-nginx-terraform-state-bucket-4559"
# Get region from Environment Variable
REGION = "us-east-1"  # Default region if not set

s3 = boto3.client("s3", region_name=REGION)

def bucket_exists():
    try:
        s3.head_bucket(Bucket=BUCKET_NAME)
        return True
    except ClientError:
        return False

def delete_resources():
    confirm = input(f"Confirm deletion of S3 Bucket: {BUCKET_NAME}? (y/n): ")
    if confirm.lower() != 'y':
        print("Deletion aborted.")
        return

    if bucket_exists():
        print("Cleaning and deleting bucket...")
        res = boto3.resource("s3", region_name=REGION)
        bucket = res.Bucket(BUCKET_NAME)
        # S3 buckets must be empty (including all versions) to be deleted
        bucket.object_versions.delete()
        bucket.delete()
        print("Bucket deleted successfully.")
    else:
        print("Bucket does not exist.")

def create_resources():
    if not bucket_exists():
        print(f"Creating bucket: {BUCKET_NAME} in {REGION}...")
        location = {'LocationConstraint': REGION} if REGION != 'us-east-1' else {}
        
        if REGION == 'us-east-1':
            s3.create_bucket(Bucket=BUCKET_NAME)
        else:
            s3.create_bucket(Bucket=BUCKET_NAME, CreateBucketConfiguration=location)
        
        # 1. Enable Versioning (Crucial for state recovery)
        s3.put_bucket_versioning(
            Bucket=BUCKET_NAME,
            VersioningConfiguration={'Status': 'Enabled'}
        )
        
        # 2. Block Public Access (Security Best Practice)
        s3.put_public_access_block(
            Bucket=BUCKET_NAME,
            PublicAccessBlockConfiguration={
                'BlockPublicAcls': True,
                'IgnorePublicAcls': True,
                'BlockPublicPolicy': True,
                'RestrictPublicBuckets': True
            }
        )
        print("Bucket created with versioning enabled and public access blocked.")
    else:
        print("Bucket already exists.")

if __name__ == "__main__":
    if not REGION:
        print("Error: Please set the AWS_REGION environment variable.")
        sys.exit(1)

    if bucket_exists():
        choice = input(f"Bucket '{BUCKET_NAME}' already exists. (D)elete or (S)kip? ").lower()
        if choice == 'd':
            delete_resources()
        else:
            print("No changes made.")
    else:
        create_resources()