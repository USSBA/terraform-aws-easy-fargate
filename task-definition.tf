resource "aws_ecs_task_definition" "task" {
  container_definitions    = var.task_container_definitions
  cpu                      = tostring(var.task_cpu)
  execution_role_arn       = aws_iam_role.exec.arn
  family                   = var.task_family
  memory                   = tostring(var.task_memory)
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task.arn

  dynamic "ephemeral_storage" {
    for_each = var.task_ephemeral_storage_size_in_gib > 0 ? [1] : []
    content {
      size_in_gib = var.task_ephemeral_storage_size_in_gib
    }
  }

  runtime_platform {
    operating_system_family = var.task_runtime_platform
    cpu_architecture        = var.task_cpu_architecture
  }
}

