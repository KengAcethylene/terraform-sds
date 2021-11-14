resource "aws_s3_bucket" "nextcloud_s3" {
  bucket = "${var.bucket_name}-${random_id.bucket_name_random.hex}"
  acl = "private"
  force_destroy = true
  tags = {
    "Name" = "nextcloud-s3"
  }
}

resource "random_id" "bucket_name_random" {
  byte_length = 8
}

resource "aws_iam_user" "nextcloud" {
  name = "nextcloud"
  path = "/storage/"
}

resource "aws_iam_policy" "s3_policy" {
    name = "nextcloud-s3-all-control"
    policy = data.aws_iam_policy_document.policy.json  
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [ "s3:*" ]
    resources = [ aws_s3_bucket.nextcloud_s3.arn,"${aws_s3_bucket.nextcloud_s3.arn}/*"]
    effect = "Allow"
  }
  statement {
    actions = [
                "kms:Decrypt",
                "kms:GenerateDataKey",
                "kms:GenerateDataKeyWithoutPlaintext",
                "kms:GenerateDataKeyPairWithoutPlaintext",
                "kms:GenerateDataKeyPair"
              ]
    resources = ["*"]
    effect = "Allow"
  }
}

resource "aws_iam_user_policy_attachment" "attachment" {
    user = aws_iam_user.nextcloud.name
    policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_access_key" "nextcloud_key" {
  user = aws_iam_user.nextcloud.name
}