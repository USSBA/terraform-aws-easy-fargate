# Get the Region
data "aws_region" "current" {}
locals {
  region        = data.aws_region.current.name
  enabled_count = var.enabled ? 1 : 0

  # Craft the efs_volumes config.  We need one element per "fs_id + directory", and
  # a volume ID that can be referenced from the mountpoints config below
  efs_volumes = distinct([for config in var.efs_configs : {
    vol_id         = "${config.file_system_id}_${md5(config.root_directory)}"
    file_system_id = config.file_system_id
    root_directory = config.root_directory
  }])

  # Craft the container mountpoint config. We need one element per mountpoint within
  # the container, referencing a volume ID from the volume config above
  efs_container_names = distinct(var.efs_configs.*.container_name)
  efs_mountpoints = { for name in local.efs_container_names : name => [for config in var.efs_configs : {
    containerPath = config.container_path
    sourceVolume  = "${config.file_system_id}_${md5(config.root_directory)}"
    readOnly      = false
  } if config.container_name == name] }

  container_definitions = var.container_definitions

  container_definitions_with_defaults = [for container_definition in local.container_definitions : merge(
    {
      essential = true
      cpu       = floor(var.task_cpu / length(local.container_definitions))
      memory    = floor(var.task_memory / length(local.container_definitions))
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this[0].name
          awslogs-region        = var.log_group_region != "" ? var.log_group_region : local.region
          awslogs-stream-prefix = container_definition.name
        }
      },
      stopTimeout = 5
      mountPoints = try(local.efs_mountpoints[container_definition.name], [])
    },
  container_definition)]

  extracted_container_secrets = flatten([for c in local.container_definitions : try(c.secrets, [])])
}

resource "aws_iam_role_policy" "this" {
  count  = var.data_aws_iam_policy_document != "" ? local.enabled_count : 0
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
  count                    = local.enabled_count
  family                   = var.name
  container_definitions    = jsonencode(local.container_definitions_with_defaults)
  execution_role_arn       = aws_iam_role.ecs_task_execution_role[0].arn
  task_role_arn            = aws_iam_role.this[0].arn
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  requires_compatibilities = ["FARGATE"]

  dynamic "volume" {
    iterator = volume
    for_each = local.efs_volumes
    content {
      name = volume.value.vol_id
      efs_volume_configuration {
        file_system_id     = volume.value.file_system_id
        root_directory     = volume.value.root_directory
        transit_encryption = "ENABLED"
      }
    }
  }
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
  # If secrets have been provided with the container defs, then an extra statement block will be created
  # that will allow the exec to pull those secrets and inject them into the container runtime.
  dynamic "statement" {
    for_each = length(local.extracted_container_secrets) > 0 ? ["enabled"] : []
    content {
      sid    = "ServiceSecrets"
      effect = "Allow"
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
      ]
      resources = local.extracted_container_secrets.*.valueFrom
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

