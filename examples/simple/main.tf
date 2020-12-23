module "simple-task" {
  #source              = "USSBA/easy-fargate/aws"
  #version             = "~> 2.0"
  source = "../../"

  name                = "my-simple-task"
  container_image     = "ubuntu:latest"
  container_command   = ["curl", "https://www.google.com"]
  schedule_expression = "rate(5 minutes)"
}
