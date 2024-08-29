# terraform-aws-easy-fargate

If running a container on a schedule we have the solution for you.

## Variables

**assign_public_ip**  
Optional: If the running task is behind NAT then this value should remain **false** as set by default; however, when running in a DMZ and the task needs to communicate with the WWW then this value should be **true**.

**ecs_cluster_arn**  
Required: An existing ECS cluster where the task will be started.

**ecs_execute_command_enabled**  
Optional: Add statements to the IAM role of the task allowing `aws ecs execute-command' commands to function properly.

**ecs_platform_version**  
Optional: By default the `LATEST` version of the ECS platform will be used.

**schedule_expression**  
Required: A cron() or rate() at which the event will be triggered.

**schedule_state**  
Optional: The operational state of the event; can be one of ENABLED or DISABLED.

**security_group_ids**  
Required: A set of security group ids assigned to the task by the event.

**subnet_ids**  
Required: A set of subnet ids assigned to the task by the event.

**task_container_definitions**  
Required: A json encoded string containing a set of container definitions for the given Fargate task. See the example below and/or the [ContainerDefinition Documentation](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html).

**task_count**  
Optional: The number of task to start when the event is triggered; by default 1 task will start.

**task_cpu**  
Optional: The number of vCPU allocated to the task; by default 256 or 1/4 vCPU will be allocated.

**task_memory**  
Optional: The amount of Virtual Memory in MiB allocated to the Fargate task; by default 512 MiB is allocated.

**task_cpu_architecture**  
Optional: The CPU architecture used to lauch the task. One of X86_64 or ARM64; by default X86_64 is assigned.

**task_ephemeral_storage_size_in_gib**  
Optional: The ephemeral_storage size in GiB that is allocated to the task at runtime; by default no additional storage is allocated.

**task_exec_inline_policies**  
Optional: A set of additional IAM polcies assigned to the execution (start up) role.

```
task_exec_inline_policies = [
  { name = "inline-policy-name", policy = "json-encoded-iam-policy" },
]
```

**task_inline_policies**  
Optional: A set of additional IAM polcies assigned to the task (running) role.

```
task_exec_inline_policies = [
  { name = "inline-policy-name", policy = "json-encoded-iam-policy" },
]
```

**task_family**  
Required: The name given to the ECS Task Definition and used in convention for other provisioned resources.

**task_runtime_platform**  
Optional: The runtime platform of the container; by default `LINUX` will be used.

## Examples

The following is a basic example.

```terraform

module "your_module_name" {
  source  = "USSBA/easy-fargate/aws"
  version = "~> 5.0"

  subnet_ids         = data.aws_subnets.target.ids
  security_group_ids = data.aws_security_groups.target.ids

  task_family = "${terraform.workspace}-your-service-name"
  task_cpu    = 256
  task_memory = 512

  ecs_execute_command_enabled = false
  ecs_cluster_arn             = data.aws_ecs_cluster.target.arn
  schedule_expression         = "cron(0 5 ? * * *)"

  task_container_definitions = jsonencode([
    {
      name      = "main"
      image     = "your-image"
      command   = ["your", "command"]
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.your_log_group.name
          awslogs-region        = "your-region"
          awslogs-stream-prefix = "your-prefix"
        }
      }
      environment = [
        { name = "AWS_DEFAULT_REGION", value = "your-default-region" },
      ]
    },
  ])
  task_inline_policies = [
    {
      name   = "your-policy-name"
      policy = data.aws_iam_policy_document.your_policy.json
    }
  ]
}

resource "aws_cloudwatch_log_group" "your_log_group" {
  name              = "${terraform.workspace}-your-log-group-name"
  retention_in_days = 90
}

data "aws_iam_policy_document" "your_policy" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["s3:Get*"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = ["us-west-2"]
    }
  }
}
```

## Contributing

We welcome contributions.
To contribute please read our [CONTRIBUTING](CONTRIBUTING.md) document.

All contributions are subject to the [license](LICENSE.md) and in no way imply compensation for contributions.

### Terraform 0.12

Our code base now exists in Terraform 0.13 and we are halting new features in the Terraform 0.12 major version.  If you wish to make a PR or merge upstream changes back into 0.12, please submit a PR to the `terraform-0.12` branch.

## Code of Conduct

We strive for a welcoming and inclusive environment for all SBA projects.

Please follow this guidelines in all interactions:

* Be Respectful: use welcoming and inclusive language.
* Assume best intentions: seek to understand other's opinions.

## Security Policy

Please do not submit an issue on GitHub for a security vulnerability.
Instead, contact the development team through [HQVulnerabilityManagement](mailto:HQVulnerabilityManagement@sba.gov).
Be sure to include **all** pertinent information.
