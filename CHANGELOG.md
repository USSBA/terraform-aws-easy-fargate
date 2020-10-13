# Changelog

## v2.1.2

- Bugfix: Grant task execution role permissions to the taskdefinition family vs specific numbers.  This prevents policy replacement during task-definition version bumps

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
