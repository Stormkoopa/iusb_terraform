output "bucket_name" {
  value = aws_s3_bucket.insecure_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.insecure_bucket.arn
}

output "security_group_id" {
  value = aws_security_group.open_sg.id
}

output "iam_role_name" {
  value = aws_iam_role.overprivileged_role.name
}