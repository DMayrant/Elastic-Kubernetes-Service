############################################
# S3 Bucket (NO prevent_destroy)
############################################

resource "aws_s3_bucket" "tf_state" {
  bucket = "devops-tf-state-9711"
  force_destroy = true

  tags = {
    Name = "tf-state"
  }
}
#########################
# Block Public Access
#########################

resource "aws_s3_bucket_public_access_block" "tf_state_block" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################################
# Versioning (optional but safe)
############################################

resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

############################################
# DynamoDB Lock Table
############################################

resource "aws_dynamodb_table" "tf_locks" {
  name         = "tf-locks-simple"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}