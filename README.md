# Spoke Terraform Module

This module creates production stack infrastrucuture for Rewired hosted Spoke. It does _not_ deploy releases; that must be done manually using a script included in [`/bin`](#).

## Prerequisites

The wildcard domain must be configured in AWS Certificates prior to deployment. This will be of the form `*.spoke.[client].politicsrewired.dev`.

## Usage

In a dedicated production management folder, create a `main.tf` Terraform file referencing this module:

```
provider "aws" {
  access_key                    = "SomeAccessKey"
  secret_key                    = "ExtraSuperSecret"
  region                        = "us-east-2"
}

module "spoke" {
  source  = "/path/to/spoke-terraform"
}
```

The complete list of configuration options is available in [`variables.tf`](variables.tf).

Initialize and Run Terraform

```sh
$ terraform init
$ terraform apply
```

## Deploying Spoke Code

**Prerequisites**

You will need Claudia.js to package Spoke:

```sh
$ npm install -g claudia
```

**Run the build script**

This will compile and package the Spoke server- and client-side applications and provide you with the appropriate `terraform apply` command to run.

```sh
$ ./bin/build --path ../Spoke \
      --domain spoke.domain.com \
      --bucket spoke.domain.com \
      --region us-east-1
```

> **Note:** You must supply the same values for the domain, bucket name, and AWS region that you provided in the Terraform configuration file above.

For complete usage of the build script, see:

```sh
$ ./bin/build --help
```
