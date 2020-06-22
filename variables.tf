variable "enabled" {
  type = bool
  description = "Enable or Disable all resources in the module"
}
variable "name" {
  type        = string
  description = "A plaintext name for named resources, compatible with task definition family names and cloudwatch log groups"
}
variable "data_aws_iam_policy_document" {
  type = object({
    json = string
  })
  description = "The data.aws_iam_policy_document granting task permissions"
  default     = { json = "{}" }
}
variable "aws_iam_policy_task_execution_statements" {
  type        = list
  description = "An array of aws_iam_policy_document statements of all the permissions needed by the running task"
  default     = []
}

variable "container_cpu" {
  type        = number
  description = "How much CPU should be reserved for the container (in aws cpu-units)"
  default     = 256
}
variable "container_memory" {
  type        = number
  description = "How much Memory should be reserved for the container (in MB)"
  default     = 512
}
variable "container_image" {
  type        = string
  description = "Docker Image tag to be used"
}
variable "container_environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Environment Variables to be passed in to the container"
  default     = []
}
variable "container_secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "ECS Task Secrets to be passed in to the container and have permissions granted to read"
  default     = []
}
variable "container_command" {
  type        = list(string)
  description = "Docker Command array to be passed to the container"
}

variable "schedule_expression" {
  type        = string
  description = "Optional: Setting this will create a cloudwatch rule schedule to kick off the fargate task periodically"
  default     = ""
}
variable "ecs_cluster_arn" {
  type        = string
  description = "Optional: Only required if a schedule_expression is set"
  default     = ""
}
variable "subnet_ids" {
  type        = list(string)
  description = "Optional: Only used if a schedule_expression is set; default is the subnets in the default VPC.  If no default vpc exists, this field is required"
  default     = []
}
variable "security_group_ids" {
  type        = list(string)
  description = "Optional: Only required if a schedule_expression is set; default is nothing.  Will create an outbound permissive SG if none is provided."
  default     = []
}
variable "assign_public_ip" {
  type = bool
  description = "Optional: Set to true if subnet is 'public' with IGW, false is subnet is 'private' with NAT GW. Defaults to true, as required by default vpc"
  default = true
}
