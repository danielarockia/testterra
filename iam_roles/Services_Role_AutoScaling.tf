resource "aws_iam_service_linked_role" "IAMServiceLinkedRole" {
  aws_service_name = "autoscaling.amazonaws.com"
}