output "sns_topic_arn" { value = aws_sns_topic.alerts.arn }
output "cloudtrail_bucket" { value = aws_s3_bucket.cloudtrail.bucket }
