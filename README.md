# terraform-aws-easy-fargate

Sometimes you have an idea of a script you want to run on AWS. There's a public docker image you can use that has everything you need, and you know the command you want to run. But getting all the boilerplate up and running can be a pain. Enter: Easy Fargate.

Features:

* Sane Defaults
* Looks up Default VPC/Subnets/SecurityGroups/etc unless told otherwise
* Create a TaskDefinition
* Optionally creates a schedule to run the job

## Usage

### Variables

#### Required

* `name` - A plaintext name for named resources, compatible with task definition family names and cloudwatch log groups.
* `container_definitions` - Container configuration in the form of a json-encoded list of maps. Required sub-fields are: 'name', 'image'; the rest will attempt to use sane defaults

#### Optional

* `enabled` - Default `true`; Enable or Disable all resources in the module.
* `task_cpu` - Default `256`; How much CPU should be reserved for all of the containers combined (in aws cpu-units).
* `task_memory` - Default `512`; How much Memory should be reserved for all of the containers combined(in MB).
* `data_aws_iam_policy_document` - Default `""`; A JSON formated IAM policy providing the running container with permissions.
* `schedule_expression` - Default `""`; How often Cloudwatch Events should kick off the task. See AWS documentation for [schedule expression rules](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html).
* `ecs_cluster_arn` - ARN of the ECS cluster to run the scheduled task. Only required if a `schedule_expression` is set.
* `subnet_ids` - Default `[]`; Only used if `schedule_expression` is set; default is the subnets in the default VPC. If no default vpc exists, this field is required.
* `security_group_ids` - Default `[]`; Only required if `schedule_expression` is set; default is nothing. Will create an outbound permissive SG if none is provided.
* `assign_public_ip` - Default `true`; Set to true if subnet is 'public' with IGW, false is subnet is 'private' with NAT GW. Defaults to true, as required by default vpc.
* `log_retention_in_days` - Default `"60"`; The number of days you want to retain log events in the log group.
* `efs_configs` - Default adds no volume mounts; List of {file_system_id, root_directory, container_path} EFS mounts
* `ecs_platform_version` - Default `1.4.0`; Options at time of writing are `1.4.0` and `LATEST`
* `tags` - Default is no tags; Map of key-value tags to apply to all applicable resources
* `tags_ecs_task_definition` - Default is no tags; Map of key-value tags to apply to the ecs task definition
* `tags_security_group` - Default is no tags; Map of key-value tags to apply to the security group
* `schedule_enabled` - Setting this to false will disable the CloudWatch Event

### Simple Example

A barebones deployment that results in a task that runs every 7 days.

```terraform
module "simple-task" {
  source                = "USSBA/easy-fargate/aws"
  version               = "~> 3.0"
  name                  = "easy-fargate-simple"
  container_definitions = [
    {
      name    = "my-simple-ubuntu"
      image   = "ubuntu:latest"
      command = ["echo", "\"Hello, world.\""]
    }
  ]
  schedule_expression = "rate(2 minutes)"
}
```

### Complex Example

You may also have a desire to do something a little more complex, such as running an awscli command within your account (which requires IAM permissions), or running a task that needs secrets or environment variables.

```terraform
module "my-fargate-task" {
  source                = "USSBA/easy-fargate/aws"
  version               = "~> 3.0"
  enabled               = true
  name                  = "my-fargate-task"
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
      environment = [
        {
          name  = "FOO"
          value = "bar"
        }
      ]
      secrets = [
        {
          name      = "FOO_SECRET"
          valueFrom = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/foo_secret"
        }
      ]
    }
  ]
  schedule_expression = "rate(7 days)"
  ecs_cluster_arn     = "arn:aws:ecs:us-east-1:123456789012:cluster/my-ecs-cluster"
  efs_configs = [
    {
      container_name = "example"
      file_system_id = "fs-12341234"
      root_directory = "/path/on/efs"
      container_path = "/path/within/container"
    }
  ]
  data_aws_iam_policy_document = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:ListBucket",
            "s3:ListAllMyBuckets"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
    }
  )
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
