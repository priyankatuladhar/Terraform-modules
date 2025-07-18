# Terraform VPC Module

This module creates a Virtual Private Cloud (VPC) in AWS along with associated networking components such as subnets, route tables, and internet gateways.

## Overview

The Terraform VPC module allows you to easily create and manage a VPC in AWS. It provides a flexible way to define your network architecture and customize it according to your needs.

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "vpc" {
  source = "path_to_your_module"

  # Required variables
  vpc_cidr = "10.0.0.0/16"

  # Optional variables
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}
```

## Inputs

| Name                   | Description                                     | Type          | Default       |
|------------------------|-------------------------------------------------|---------------|---------------|
| `vpc_cidr`             | The CIDR block for the VPC                      | `string`      | n/a           |
| `enable_dns_support`   | Enable DNS support in the VPC                   | `bool`        | `true`        |
| `enable_dns_hostnames` | Enable DNS hostnames in the VPC                 | `bool`        | `true`        |
| `tags`                 | A map of tags to assign to the VPC              | `map(string)` | `{}`          |

## Outputs

| Name        | Description                          |
|-------------|--------------------------------------|
| `vpc_id`    | The ID of the created VPC           |
| `subnet_ids`| The IDs of the created subnets       |

## Examples

For examples of how to use this module, please refer to the `examples` directory in the repository. 

## License

This module is licensed under the MIT License. See the LICENSE file for more information.