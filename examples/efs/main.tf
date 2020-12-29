module "efs-task" {
  #source              = "USSBA/easy-fargate/aws"
  #version             = "~> 2.0"
  source = "../../"

  name            = "easy-fargate-efs-task"
  container_image = "ubuntu:latest"
  container_command = ["bash", "-cx", <<-EOT
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
      file_system_id = aws_efs_file_system.efs-one.id
      root_directory = "/"
      container_path = "/mnt/one_a"
    },
    {
      file_system_id = aws_efs_file_system.efs-one.id
      root_directory = "/"
      container_path = "/mnt/one_b"
    },
    {
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
