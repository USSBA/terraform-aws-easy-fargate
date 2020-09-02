# Get the Region
data "aws_region" "current" {}
locals {
  region        = data.aws_region.current.name
  enabled_count = var.enabled ? 1 : 0
}

resource "aws_iam_role_policy" "this" {
  count  = local.enabled_count
  name   = "${var.name}_task_role_policy"
  policy = var.data_aws_iam_policy_document
  role   = aws_iam_role.this[0].id
}

resource "aws_iam_role" "this" {
  count              = local.enabled_count
  name               = "${var.name}_task_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role[0].json
}

resource "aws_cloudwatch_log_group" "this" {
  count             = local.enabled_count
  name              = length(var.log_group_name) > 0 ? var.log_group_name : var.name
  retention_in_days = var.log_retention_in_days
}

resource "aws_ecs_task_definition" "this" {
  count              = local.enabled_count
  family             = var.name
  task_role_arn      = aws_iam_role.this[0].arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role[0].arn
  # Fargate Settings
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  network_mode             = "awsvpc"
  # /Fargate
  container_definitions = jsonencode(
    [
      {
        name         = "container"
        portMappings = []
        cpu          = var.container_cpu
        memory       = var.container_memory
        image        = var.container_image
        environment  = var.container_environment_variables
        command      = var.container_command
        essential    = true
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = var.name
            awslogs-region        = local.region
            awslogs-stream-prefix = var.log_group_stream_prefix
          }
        }
      },
    ]
  )
}

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  count = local.enabled_count
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Allow ECS to run tasks with ECR images; write logs
data "aws_iam_policy_document" "ecs_task_execution_role_policy" {
  count = local.enabled_count
  statement {
    sid    = "GrantAccessToStartEcsTask"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
  dynamic "statement" {
    # If the container_secrets variable is populated, create a single `statement {` dynamic block
    # in order to add permissions for all the required secrets
    for_each = length(var.container_secrets) > 0 ? ["secrets_included"] : []
    content {
      sid    = "GrantAccessToRequiredSecrets"
      effect = "Allow"
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
      ]
      resources = var.container_secrets.*.valueFrom
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  count              = local.enabled_count
  name               = "${var.name}_ecs_taskex_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role[0].json
}
resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  count  = local.enabled_count
  name   = "${var.name}_ecs_taskex_role_policy"
  role   = aws_iam_role.ecs_task_execution_role[0].id
  policy = data.aws_iam_policy_document.ecs_task_execution_role_policy[0].json
}
