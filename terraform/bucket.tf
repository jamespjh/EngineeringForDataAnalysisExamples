resource "aws_s3_bucket" "nineteenth_century_books" {
  bucket = "nineteenth-century-books"

  tags = {
    Owner  = "ucgajhe"
    Method = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "nineteenth_century_books" {
  bucket = aws_s3_bucket.nineteenth_century_books.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_all_download" {
  bucket     = aws_s3_bucket.nineteenth_century_books.id
  policy     = data.aws_iam_policy_document.allow_all_download.json
  depends_on = [aws_s3_bucket_public_access_block.nineteenth_century_books]
}

data "aws_iam_policy_document" "allow_all_download" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.nineteenth_century_books.arn,
      "${aws_s3_bucket.nineteenth_century_books.arn}/*",
    ]
  }
}