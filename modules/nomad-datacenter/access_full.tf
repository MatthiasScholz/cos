# Add policy to the already created iam role of the nomad clients in the nomad cluster module.
# Policy-attachment that grants full access to all AWS services for nomad clients
resource "aws_iam_role_policy_attachment" "irpa_full_access" {
  role       = "${module.data_center.iam_role_id}"
  policy_arn = "${aws_iam_policy.ip_full_access.arn}"
}

resource "aws_iam_policy" "ip_full_access" {
  name   = "${var.stack_name}-${var.datacenter_name}${var.unique_postfix}-full"
  policy = "${file("${path.module}/access_full.json")}"
}
