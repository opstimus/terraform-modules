# terraform-modules

Monorepo of opstimus Terraform modules, organized by provider.

## Layout

Modules live flat under `modules/<key>/`. The key carries the provider prefix
(`aws-vpc`, `oci-vcn`); provider-less modules keep their bare name (`postgresql`).

## Usage

```hcl
module "vpc" {
  source = "git::https://github.com/opstimus/terraform-modules.git//modules/aws-vpc?ref=aws-vpc/v2.2.1"
}
```

Pin `?ref=` to a per-module tag of the form `<key>/vX.Y.Z`.

## Modules

See `modules/` for the full list. (Populated as modules are migrated.)
