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

See [`modules/`](modules/) for the full list. Each module lives at
`modules/<key>/` with its own README, and is versioned independently — pin
`?ref=` to that module's tag (`<key>/vX.Y.Z`).
