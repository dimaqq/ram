

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_s3_bucket" "research" {
  bucket = "research"
}

resource "aws_athena_database" "research" {
  name   = "research"
  bucket = aws_s3_bucket.research.bucket
}

resource "aws_athena_workgroup" "research" {
  name = "example"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.research.bucket}/output/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

# It would be awesome to use aws timestream, a dedicated time series database
# however, data can only be inserted within the "active" window:
# from (now - retention_period) until (now + injestion period)
# also, data should be inserted in chronological order
# this, perhaps, disqualifies timestream from current task, processing historical data
