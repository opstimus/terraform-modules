# terraform-modules

Monorepo of opstimus Terraform modules, organized by provider.

## Layout

Modules live flat under `modules/<key>/`. The key carries the provider prefix
(`aws-vpc`, `oci-vcn`); provider-less modules keep their bare name (`postgresql`).

## Usage

```hcl
module "vpc" {
  source = "git::https://github.com/opstimus/terraform-modules.git//modules/aws-vpc?ref=aws-vpc/v2.2.0"
}
```

Pin `?ref=` to a per-module tag of the form `<key>/vX.Y.Z`.

## Releasing

Run the **Release module** workflow (Actions → Release module), choose the
module and bump level. The job requires approval via the `prod` environment.

## Modules

See `modules/` for the full list. (Populated as modules are migrated.)
