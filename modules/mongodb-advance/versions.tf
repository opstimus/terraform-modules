terraform {
  required_version = ">= 1.3.0"
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = ">= 2.5.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}
