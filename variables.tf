
#
# NETWORK
#

variable "subnet_ids" {
  description = "Required: A set of subnet_ids."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Required: A set of security_group_ids."
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Optional: Allow the automatic assignment of public-ips to the task when it starts."
  type        = bool
  default     = false
}

#
# ECS TASK DEFINITION
#

variable "task_family" {
  description = "Required: The name of the Fargate task family."
  type        = string
}

variable "task_cpu" {
  description = "Optional: The number of VCPUs allocated to the Fargate task. Default is 256."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Optional: The amount of Virtual Memory in MiB allocated to the Fargate task. Default is 512."
  type        = number
  default     = 512
}

variable "task_runtime_platform" {
  description = "Optional: The containers runtime_platform. Default is LINUX"
  type        = string
  default     = "LINUX"
}

variable "task_cpu_architecture" {
  description = "Optional: The type of CPU architecture in which to run the Fargate under. Default is X86_64."
  type        = string
  default     = "X86_64"
}

variable "task_exec_inline_policies" {
  description = "Optional: Additional IAM policies applied to the execution role (e.g. the role used to start the container) of the Fargate task."
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}

variable "task_inline_policies" {
  description = "Optional: Additional IAM policies applied to the role (e.g. the role used after the container starts) of the Fargate task."
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}

variable "task_container_definitions" {
  description = "Required: A json encoded string containing a set of container definitions for the given Fargate task."
  type        = string
  validation {
    condition     = length(var.task_container_definitions) > 0
    error_message = "task_container_definitions -> must container at least 1 container definition"
  }
}

variable "task_ephemeral_storage_size_in_gib" {
  description = "Optional: The ephemeral_storage size in GiB that is allocated to the task at runtime."
  type        = number
  default     = 0
}

variable "task_count" {
  description = "Optional: The number of task to start when the event is triggered."
  type        = number
  default     = 1
}

# POSIBLE FUTURE USE CASE
#variable "task_container_overrides" {
#  description = "A json encoded string reflecting a set of command layer overrides. `containerOverrides = [{name='container-name',command=['command']}]`"
#  type        = string
#  default     = ""
#}

#
# ECS
#

variable "ecs_cluster_arn" {
  description = "Required: The designated ECS cluster ARN in which the task will run."
  type        = string
}

variable "ecs_execute_command_enabled" {
  description = "Optional: Add statements to the IAM role of the task allowing `aws ecs execute-command' commands to function properly. By default is false."
  type        = bool
  default     = false
}

variable "ecs_platform_version" {
  description = "Optional: The ECS platform version used to launch the Fargate container."
  type        = string
  default     = "LATEST"
}


#
# CLOUDWATCH EVENT RULE/TARGET
#

variable "schedule_expression" {
  description = "Required: A cron() or rate() at which the event will take place."
  type        = string
}

variable "schedule_state" {
  description = "Optional: The running state (e.g. ENABLED or DISABLED) of the event."
  type        = string
  default     = "ENABLED"
}
