# Changelog

## v6.0.0
- The `inline_policy` attribute of IAM roles will be deprecated and has been replaced with `aws_iam_role_policies_exclusive` resource in union with the `aws_iam_role_policy` resource.
- May require a `terraform init -upgrade` depending on the AWS provider version being so we are incrementing the major version.

## v5.0.0

- This is a major overhaul of the module itself and may require prior versions to be destroyed, reconfigured, and re-deployed using v5.x of this module.
- The module is no longer:
  - Responsible for the [container definitions](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html) of the task.
  - Use the default VPC, Subnets and SecurityGroups by default.
  - Using the default VPC by default.
  - Creating a security group or log groups.
- The vpc-id, subnet-ids, security-group-ids and cluster-arn must be provided.
- The task Runtime Platform and CPU architecture are now configurable.
- Inline IAM policies can be configured on both the task and task-execution roles.

## v4.2.0

- Terraform provider is now `~> 5.0`
- Fixed warnings on deprecated attributes.
- ECS platform version now defaults to `LATEST`

## v4.1.0

- Adding variable `schedule_enabled`. Setting this to false will disable the CloudWatch Event.

## v4.0.0

- **BREAKING CHANGES:**
  - Terraform version has been bumped to `~> 1.0`
  - Terraform provider has been bumped to `~> 4.0`
  - Security group egress traffic has been changed from an inline rule to the resource `aws_security_group_rule`

## v3.1.0

- Adding `tags`, `tags_ecs_task_definition`, `tags_security_group` maps to allow for configuring resource level tags

## v3.0.0

- **BREAKING CHANGES:**
  - `container_definitions` is the new location for all container definitions for the ECS Task Definition. This was done to enable the support of multiple containers in the task.
  - `container_image` has been REMOVED, use `container_definitions[].image` instead.
  - `container_environment_variables` has been REMOVED, use `container_definitions[].environment` instead.
  - `container_secrets` has been REMOVED, use `container_definitions[].secrets` instead.
  - `container_command` has been REMOVED, use `container_definitions[].command` instead.
  - `container_cpu` has been changed to `task_cpu` and its value will be divided evenly across containers unless explicitly set in the container definitions.
  - `container_memory` has been changed to `task_memory` and its value will be divided evenly across containers unless explicitly set in the container definitions.

## v2.2.1

- BUGFIX: Adding `ecs_platform_version` to ensure full compatibility with EFS
- Added a default ecs_cluster_arn value to provide a clear error message when it is omitted but needed

## v2.2.0

- Adding `efs_configs` to allow multiple EFS mounts.

## v2.1.2

- Bugfix: Grant task execution role permissions to the taskdefinition family vs specific numbers. This prevents policy replacement during task-definition version bumps

## v2.1.1

- Bugfix: Plumb `container_secrets` into container 🤭

## v2.1.0

- Output `security_group_ids`
- Output `log_group`
- Configurable `log_group` name
- Configurable `stream_prefix` name

## v2.0.1

- **Terraform 13** initial release

## v1.1.0

- Output `security_group_ids`
- Output `log_group`
- Configurable `log_group` name
- Configurable `stream_prefix` name

## v1.0.1

- Making `container_command` and `enabled` optional

## v1.0.0

- Initial release, supporting only 0.12
