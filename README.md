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
* `container_image` - Docker Image tag to be used.
* `container_command` - Docker Command array to be passed to the container.

#### Optional

* `enabled` - Default `true`; Enable or Disable all resources in the module.
* `container_cpu` - Default `256`; How much CPU should be reserved for the container (in aws cpu-units).
* `container_memory` - Default `512`; How much Memory should be reserved for the container (in MB).
* `container_environment_variables` - Default `[]`; Environment Variables to be passed in to the container.
* `container_secrets` - Default `[]`; ECS Task Secrets stored in SSM to be passed in to the container and have permissions granted to read.
* `data_aws_iam_policy_document` - Default `""`; A JSON formated IAM policy providing the running container with permissions.
* `schedule_expression` - Default `""`; How often Cloudwatch Events should kick off the task. See AWS documentation for [schedule expression rules](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html).
* `ecs_cluster_arn` - Default `""`; ARN of the ECS cluster to run the scheduled task. Only required if a `schedule_expression` is set.
* `subnet_ids` - Default `[]`; Only used if `schedule_expression` is set; default is the subnets in the default VPC. If no default vpc exists, this field is required.
* `security_group_ids` - Default `[]`; Only required if `schedule_expression` is set; default is nothing. Will create an outbound permissive SG if none is provided.
* `assign_public_ip` - Default `true`; Set to true if subnet is 'public' with IGW, false is subnet is 'private' with NAT GW. Defaults to true, as required by default vpc.
* `log_retention_in_days` - Default `"60"`; The number of days you want to retain log events in the log group.

### Simple Example

A barebones deployment that results in a task that runs every 7 days.

```terraform
module "simple-task" {
  source              = "USSBA/easy-fargate/aws"
  version             = "~> 2.0"
  name                = "my-simple-task"
  container_image     = "ubuntu:latest"
  container_command   = ["curl", "https://www.google.com"]
  schedule_expression = "rate(7 days)"
```

### Complex Example

You may also have a desire to do something a little more complex, such as running an awscli command within your account (which requires IAM permissions), or running a task that needs secrets or environment variables.

```terraform
module "my-fargate-task" {
  source              = "USSBA/easy-fargate/aws"
  version             = "~> 2.0"
  enabled             = true
  name                = "my-fargate-task"
  container_image     = "ussba/cc-docker-git-aws"
  container_command   = ["aws", "s3", "ls"]
  schedule_expression = "rate(7 days)"
  ecs_cluster_arn     = "arn:aws:ecs:us-east-1:123456789012:cluster/my-ecs-cluster"
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
  container_environment_variables = [
    {
      name  = "FOO"
      value = "bar"
    }
  ]
  container_secrets = [
    {
      name      = "FOO_SECRET"
      valueFrom = "arn:aws:ssm:${local.region}:${local.account_id}:parameter/foo_secret"
    }
  ]
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
