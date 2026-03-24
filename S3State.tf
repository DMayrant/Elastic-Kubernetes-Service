############################################
# S3 Bucket (NO prevent_destroy)
############################################

resource "aws_s3_bucket" "tf_state" {
  bucket = "tf-state-${random_id.suffix.hex}"

  tags = {
    Name = "tf-state"
  }
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