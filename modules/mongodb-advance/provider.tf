provider "mongodbatlas" {
  public_key  = var.atlas_api_public_key
  private_key = var.atlas_api_private_key
}

provider "aws" {
  region = "me-south-1"
}
