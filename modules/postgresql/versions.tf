terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.26"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7"
    }
  }
}
