# vagrant-spinnaker
Includes a Vagrantfile and provisioning script for deploying a "localdebian"
installation with AWS as a cloud provider.

Requires a config file in the same directory as the Vagrantfile named `cfg.yml`
with important parameters defined.

## Usage
* Create a `cfg.yml` like the example below.
* `vagrant up`
* In the default configuration, the Deck UI should be reachable at
  http://localhost:9000.

## Example `cfg.yml`
```yaml
---
# Optional. Defaults to 1.7.1
spinnaker_version: 1.7.1.

# Required.
# AWS IAM user provided needs at least "PowerUserAccess".
# See https://www.spinnaker.io/setup/install/providers/aws/
aws_account_id: 012345678910
aws_access_key_id: AKIAIOSFODNN7EXAMPLE
aws_secret_access_key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

# Optional. Defaults to http://localhost.
base_url: http://localhost

# Port mappings are optional and can't collide with 9001, or other official
# ports. Values shown here are the defaults.
# See https://www.spinnaker.io/reference/architecture/#port-mappings.
deck_port: 9000
gate_port: 8084
```
