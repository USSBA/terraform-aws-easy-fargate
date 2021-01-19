data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
module "simple-task" {
  #source              = "USSBA/easy-fargate/aws"
  #version             = "~> 3.0"
  source = "../../"

  name = "easy-fargate-simple"
  container_definitions = [
    {
      name    = "my-simple-ubuntu"
      image   = "ubuntu:latest"
      command = ["echo", "\"Hello, world.\""]
    }
  ]
  schedule_expression = "rate(2 minutes)"
  ecs_cluster_arn     = "arn:aws:ecs:us-east-1:${data.aws_caller_identity.current.account_id}:cluster/default"
}

output "validate-example" {
  value = "Logs will be streaming to the log group here: https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:log-groups/log-group/${module.simple-task.log_group.name}/log-events"
}
