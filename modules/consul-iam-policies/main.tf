# -------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# -------------------------------------------------------------------------------------------------------------------

terraform {
  # This module is now only being tested with Terraform 0.13.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 0.13.x code.
  required_version = ">= 0.12.26"
}

# -------------------------------------------------------------------------------------------------------------------
# ATTACH AN IAM POLICY THAT ALLOWS THE CONSUL NODES TO AUTOMATICALLY DISCOVER EACH OTHER AND FORM A CLUSTER
# -------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "auto_discover_cluster" {
  name   = "${var.cluster_tag_value}-auto-discover-cluster"
  role   = var.iam_role_id
  policy = data.aws_iam_policy_document.auto_discover_cluster.json
}

data "aws_iam_policy_document" "auto_discover_cluster" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
    ]

    resources = ["*"]
  }
}

# -------------------------------------------------------------------------------------------------------------------
# ATTACH AN IAM POLICY THAT ALLOWS TO CONNECT TO THE CONSUL NODES USING AWS SSM
# -------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = var.iam_role_id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
