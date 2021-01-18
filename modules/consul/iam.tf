# NOTE: This is taken from
# https://github.com/hashicorp/terraform-aws-consul/blob/bc8f83760cab2a29dbfceaebe30390c1dbeb3e48/modules/consul-cluster/main.tf
# but needed to be extended to support AWS SSM.

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = var.cluster_tag_value
  path        = "/"
  role        = aws_iam_role.instance_role.name

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = var.cluster_tag_value
  assume_role_policy = data.aws_iam_policy_document.instance_role.json

  # aws_iam_instance_profile.instance_profile in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# THE IAM POLICIES COME FROM THE CONSUL-IAM-POLICIES MODULE
# ---------------------------------------------------------------------------------------------------------------------

module "iam_policies" {
  source = "../consul-iam-policies"

  iam_role_id = aws_iam_role.instance_role.id
  cluster_tag_value = var.cluster_tag_value
}
