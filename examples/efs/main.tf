data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
module "efs-task" {
  #source              = "USSBA/easy-fargate/aws"
  #version             = "~> 3.0"
  source = "../../"

  name                = "easy-fargate-efs-task"
  schedule_expression = "rate(5 minutes)"
  container_definitions = [
    {
      name  = "example"
      image = "ubuntu:latest"
      command = ["bash", "-cx", <<-EOT
         apt update;
         apt install tree -y;
         tree /mnt;
         touch /mnt/one_a/foo-`date -Iminutes`;
         tree /mnt;
         touch /mnt/one_b/bar-`date -Iminutes`;
         tree /mnt;
         touch /mnt/two/baz-`date -Iminutes`;
         tree /mnt;
       EOT
      ]
    }
  ]
  ecs_cluster_arn = "arn:aws:ecs:us-east-1:${data.aws_caller_identity.current.account_id}:cluster/default"
  efs_configs = [
    # Mount 1: efs-one:/ => container:/mnt/one_a
    # Mount 2: efs-one:/ => container:/mnt/one_b
    #   Shares a task Volume with Mount 1
    # Mount 3: efs-two:/ => container:/mnt/two
    # Container will have access to directories:
    #   /mnt/one_a
    #   /mnt/one_b
    #   /mnt/two
    {
      container_name = "example"
      file_system_id = aws_efs_file_system.efs-one.id
      root_directory = "/"
      container_path = "/mnt/one_a"
    },
    {
      container_name = "example"
      file_system_id = aws_efs_file_system.efs-one.id
      root_directory = "/"
      container_path = "/mnt/one_b"
    },
    {
      container_name = "example"
      file_system_id = aws_efs_file_system.efs-two.id
      root_directory = "/"
      container_path = "/mnt/two"
    },
  ]
}

# Allow Fargate task into EFS
resource "aws_security_group_rule" "allow_fargate_into_efs" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = module.efs-task.security_group_ids[0]
}

output "validate-example" {
  value = "Logs will be streaming to the log group here: https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#logsV2:log-groups/log-group/${module.efs-task.log_group.name}/log-events"
}
