data "aws_caller_identity" "current" {}
module "simple-task" {
  #source              = "USSBA/easy-fargate/aws"
  #version             = "~> 2.0"
  source = "../../"

  name                = "my-simple-task"
  container_image     = "ubuntu:latest"
  container_command   = ["echo", "\"Hello, world.  The time is: `date`\""]
  schedule_expression = "rate(2 minutes)"
  ecs_cluster_arn     = "arn:aws:ecs:us-east-1:${data.aws_caller_identity.current.account_id}:cluster/default"
}
