# Add policy to the already created iam role of the nomad clients in the nomad cluster module.
# Policy-attachment that grants read access to AWS ECR for nomad clients
resource "aws_iam_role_policy_attachment" "irpa_ecr_read_access" {
  # FIXME: Because of this constellation it is not possible to provide the ECR access configuration as module.
  role       = "${module.data_center.iam_role_id}"
  policy_arn = "${aws_iam_policy.ip_ecr_read_access.arn}"
}

resource "aws_iam_policy" "ip_ecr_read_access" {
  name   = "${var.stack_name}-${var.datacenter_name}${var.unique_postfix}"
  policy = "${data.aws_iam_policy_document.ipd_ecr_read_access.json}"
}

data "aws_iam_policy_document" "ipd_ecr_read_access" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = ["*"]
  }
}
