resource "aws_efs_file_system" "efs-task" {
  creation_token = "my-efs-task"

  tags = {
    Name = "my-efs-task"
  }
}

module "efs-task" {
  #source              = "USSBA/easy-fargate/aws"
  #version             = "~> 2.0"
  source = "../../"

  name              = "my-efs-task"
  container_image   = "ubuntu:latest"
  container_command = ["curl", "https://www.google.com"]
  efs_configs = [
    {
      file_system_id = aws_efs_file_system.efs-task.id
      root_directory = "/"
      container_path = "/mounted-efs"
    }
  ]
}
