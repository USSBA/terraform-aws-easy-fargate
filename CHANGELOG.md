# Changelog

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
