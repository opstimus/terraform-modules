resource "mongodbatlas_project" "main" {
  name   = "${var.project}-${var.environment}-${var.name}"
  org_id = var.atlast_org_id

  tags = {
    project     = var.project
    environment = var.environment
    name        = var.name
  }
}

resource "random_password" "main" {
  length           = 16
  special          = true
  override_special = "!%*?"
}

resource "aws_secretsmanager_secret" "main" {
  name = "${var.project}-${var.environment}-${var.name}-db"
}
resource "aws_secretsmanager_secret_version" "main" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = random_password.main.result
}

resource "mongodbatlas_advanced_cluster" "main" {
  project_id                     = mongodbatlas_project.main.id
  name                           = "${var.project}-${var.environment}-${var.name}"
  cluster_type                   = var.cluster_type
  mongo_db_major_version         = var.db_version
  backup_enabled                 = var.backup_enabled
  termination_protection_enabled = var.termination_protection_enabled
  replication_specs {
    region_configs {
      electable_specs {
        instance_size = var.instance_size
        node_count    = 3
        disk_size_gb  = var.disk_size_gb
      }
      provider_name = var.provider_name
      priority      = 7
      region_name   = var.region
    }
  }
}

resource "mongodbatlas_database_user" "main" {
  username           = var.db_username
  password           = random_password.main.result
  project_id         = mongodbatlas_project.main.id
  auth_database_name = "admin"

  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }

  roles {
    role_name     = "readWrite"
    database_name = var.db_name
  }

  scopes {
    name = mongodbatlas_advanced_cluster.main.name
    type = "CLUSTER"
  }
}

resource "mongodbatlas_project_ip_access_list" "main" {
  for_each   = var.witelist_ip_addresses
  project_id = mongodbatlas_project.main.id
  cidr_block = each.value
  comment    = each.key
}


