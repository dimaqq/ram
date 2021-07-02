

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    project = "ram"
  }
}

resource "aws_s3_bucket" "input_data" {
  bucket = "research-ram-source-data"
}

resource "aws_s3_bucket" "research_data" {
  bucket = "research-ram-data"
}

resource "aws_athena_database" "research" {
  name   = "research"
  bucket = aws_s3_bucket.research_data.bucket
}

resource "aws_athena_workgroup" "research_ram" {
  name = "research-ram"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.research_data.bucket}/output/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

resource "aws_athena_named_query" "test_iris" {
  name      = "test-usernames"
  workgroup = aws_athena_workgroup.research_ram.id
  database  = aws_athena_database.research.id
  query     = "SELECT * FROM \"${aws_glue_catalog_table.parquet_test.name}\" limit 10;"
}

resource "aws_glue_catalog_table" "parquet_test" {
  database_name = aws_glue_catalog_database.research.name
  name          = "research-parquet-test"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
    classification        = "parquet"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.input_data.bucket}/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }
    # column names are important: you get a blank column upon a mistake
    # column order is not important
    # column types are important: you get errors upon a mistake
    columns {
      name = "id"
      type = "int"
    }
    columns {
      name = "bool_col"
      type = "boolean"
    }
    columns {
      name = "tinyint_col"
      type = "tinyint"
    }
    columns {
      name = "smallint_col"
      type = "smallint"
    }
    columns {
      name = "int_col"
      type = "int"
    }
    columns {
      name = "bigint_col"
      type = "bigint"
    }
    columns {
      name = "float_col"
      type = "float"
    }
    columns {
      name = "double_col"
      type = "double"
    }
    columns {
      name = "date_string_col"
      type = "binary"
    }
    columns {
      name = "string_col"
      type = "string"
    }
    columns {
      name = "timestamp_col"
      type = "timestamp"
    }
  }
}

resource "aws_glue_catalog_database" "research" {
  name = "research-ram"
}
