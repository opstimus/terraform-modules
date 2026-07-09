<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/assets/opstimus-logo-white.svg">
  <img src=".github/assets/opstimus-logo.svg" width="380" alt="Opstimus">
</picture>

<h3>Terraform Modules</h3>

<p>A single, versioned home for Opstimus' reusable Terraform modules — AWS, OCI, and more.</p>

[![Terraform](https://img.shields.io/badge/Terraform-%E2%89%A5%201.3-21327A?style=flat-square&logo=terraform&logoColor=white)](https://developer.hashicorp.com/terraform)
[![AWS](https://img.shields.io/badge/AWS-DA794F?style=flat-square&logo=amazonwebservices&logoColor=white)](modules/)
[![OCI](https://img.shields.io/badge/OCI-C6543C?style=flat-square&logo=oracle&logoColor=white)](modules/)
[![Modules](https://img.shields.io/badge/modules-43-1C255C?style=flat-square)](modules/)
[![License](https://img.shields.io/badge/license-Apache--2.0-363A66?style=flat-square)](LICENSE)

</div>

---

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
