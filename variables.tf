# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#  REQUIRED
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
variable "name" {
  type        = string
  description = "A plaintext name for named resources, compatible with task definition family names and cloudwatch log groups"
}
variable "container_definitions" {
  #type        = any
  description = "Container configuration in the form of a json-encoded list of maps. Required sub-fields are: 'name', 'image'; the rest will attempt to use sane"
  validation {
    condition     = can(var.container_definitions.*.name)
    error_message = "VALIDATION FAILURE: Every element of container_definitions must include a 'name' field."
  }
  validation {
    condition     = can(var.container_definitions.*.image)
    error_message = "VALIDATION FAILURE: Every element of container_definitions must include an 'image' field."
  }
  validation {
    condition     = can(var.container_definitions[0])
    error_message = "VALIDATION FAILURE: Variable container_definitions must be a list."
  }
  validation {
    condition     = can(var.container_definitions[0])
    error_message = "VALIDATION FAILURE: Variable container_definitions must be a list."
  }
  validation {
    error_message = "VALIDATION FAILURE: Variable container_definitions.*.portMappings must all be unique."
    condition     = length(distinct([for def in var.container_definitions : def.portMappings[0].containerPort if can(def.portMappings[0].containerPort)])) == le
  }
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#  OPTIONAL
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

variable "enabled" {
  type        = bool
  description = "Enable or Disable all resources in the module"
  default     = true
}
variable "task_cpu" {
  type        = number
  description = "How much CPU should be reserved for the container (in aws cpu-units)"
  default     = 256
}
variable "task_memory" {
  type        = number
  description = "How much Memory should be reserved for the container (in MB)"
  default     = 512
}
variable "data_aws_iam_policy_document" {
  type        = string
  description = "A JSON formated IAM policy providing the running container with permissions"
  default     = ""
}
variable "schedule_expression" {
  type        = string
  description = "Setting this will create a cloudwatch rule schedule to kick off the fargate task periodically"
  default     = ""
}
variable "ecs_cluster_arn" {
  type        = string
  description = "Only required if a schedule_expression is set"
  default     = "ERROR: Must set var.ecs_cluster_arn when using a schedule_expression"
}
variable "subnet_ids" {
  type        = list(string)
  description = "Only used if a schedule_expression is set; default is the subnets in the default VPC.  If no default vpc exists, this field is required"
  default     = []
}
variable "security_group_ids" {
  type        = list(string)
  description = "Only required if a schedule_expression is set; default is nothing.  Will create an outbound permissive SG if none is provided."
  default     = []
}
variable "assign_public_ip" {
  type        = bool
  description = "Set to true if subnet is 'public' with IGW, false is subnet is 'private' with NAT GW. Defaults to true, as required by default vpc"
  default     = true
}
variable "log_retention_in_days" {
  type        = string
  description = "Optional; The number of days you want to retain log events in the log group.  Defaults to 60"
  default     = "60"
}
variable "log_group_name" {
  type        = string
  description = "Optional; The name of the log group. By default the `name` variable will be used."
  default     = ""
}
variable "log_group_stream_prefix" {
  type        = string
  description = "Optional; The name of the log group stream prefix. By default this will be `container`."
  default     = "container"
}
variable "efs_configs" {
  type = list(object({
    container_name = string
    file_system_id = string
    root_directory = string
    container_path = string
  }))
  description = "Optional; List of {file_system_id, root_directory, container_path} EFS mounts."
  default     = []
}
variable "ecs_platform_version" {
  type        = string
  description = "Optional; The ECS Platform version.  At time of writing, >= 1.4.0 is required for any EFS configurations"
  # TODO: when LATEST points to 1.4.0, change default to LATEST
  default = "1.4.0"
}
