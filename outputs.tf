output "task_definition" {
  value = var.enabled ? aws_ecs_task_definition.this : null
}
output "task_role" {
  value = var.enabled ? aws_iam_role.this : null
}
output "task_execution_role" {
  value = var.enabled ? aws_iam_role.ecs_task_execution_role : null
}
output "security_group_ids" {
  value = local.security_group_ids
}
output "log_group" {
  value = try(aws_cloudwatch_log_group.this[0], null)
}
