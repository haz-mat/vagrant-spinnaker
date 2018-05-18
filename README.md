# vagrant-spinnaker
Includes a Vagrantfile and provisioning script for deploying a "localdebian"
installation with AWS as a cloud provider.

Requires a config file in the same directory as the Vagrantfile named `cfg.yml`
with important parameters defined.

## Example `cfg.yml`
```yaml
---
spinnaker_version: 1.7.1 # Optional. Defaults to 1.7.1.
aws_account_id: 012345678910
aws_access_key_id: AKIAIOSFODNN7EXAMPLE
aws_secret_access_key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
base_url: http://localhost # Optional. Defaults to http://localhost.
deck_port: 9000 # Optional. Defaults to 9000.
gate_port: 8084 # Optional. Default to 8084.
```
