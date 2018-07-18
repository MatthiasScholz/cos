resource "aws_ecr_repository" "ecr_repositories" {
  count = "${length(var.ecr_repositories)}"
  name  = "${element(var.ecr_repositories, count.index)}"
}
