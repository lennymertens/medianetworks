resource "aws_s3_bucket" "tfbucketvanlenny" {
  bucket = "tfbucketvanlenny"
  acl = "public-read"
}

resource "aws_s3_bucket_object" "tf_object" {
  bucket = "tfbucketvanlenny"
  key = "image.png"
  source = "image.png"
  acl = "public-read"
  depends_on = [aws_s3_bucket.tfbucketvanlenny]
}