resource "aws_iam_role" "exec" {
  name               = "${var.task_family}-ecs-exec"
  assume_role_policy = data.aws_iam_policy_document.principal.json
}
resource "aws_iam_role_policy" "exec" {
  name   = "inline1"
  role   = aws_iam_role.exec.id
  policy = data.aws_iam_policy_document.exec.json
}
resource "aws_iam_role_policy" "exec_inline" {
  count = length(var.task_exec_inline_policies)

  name   = "inline-${var.task_exec_inline_policies[count.index].name}"
  role   = aws_iam_role.exec.id
  policy = var.task_exec_inline_policies[count.index].policy
}
resource "aws_iam_role_policies_exclusive" "exec_inline" {
  role_name    = aws_iam_role.exec.name
  policy_names = concat([aws_iam_role_policy.exec.name], aws_iam_role_policy.exec_inline.*.name)
}
data "aws_iam_policy_document" "exec" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}
