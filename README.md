# paw_ansible_role_certbot

## Description

This Puppet module was Converted from Ansible role: **ansible_role_certbot**

Installs and configures Certbot (for Let's Encrypt).

## Conversion Details

- **Converted on**: 2025-11-18
- **Original Author**: geerlingguy
- **License**: license (BSD, MIT)

## Usage

Include the module in your Puppet manifest:

```puppet
include paw_ansible_role_certbot
```

Or with custom parameters:

```puppet
class { 'paw_ansible_role_certbot':
  # Add your parameters here
}
```

## Parameters

See `manifests/init.pp` for the full list of available parameters.

## Requirements

- Puppet 6.0 or higher
- puppet_agent_runonce module for task execution
- Ansible installed on target nodes for task execution

## License

license (BSD, MIT)
