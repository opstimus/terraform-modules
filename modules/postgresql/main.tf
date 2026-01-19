# Generate random password for database user
resource "random_password" "user_password" {
  length           = 16
  special          = true
  override_special = "!$&*+="
}

# Create PostgreSQL role/user
resource "postgresql_role" "user" {
  name     = var.database_user
  password = random_password.user_password.result
  login    = true
}

# Create PostgreSQL database
resource "postgresql_database" "database" {
  name  = var.database_name
  owner = postgresql_role.user.name
}

# Grant database privileges
resource "postgresql_grant" "database" {
  database    = postgresql_database.database.name
  role        = postgresql_role.user.name
  privileges  = ["ALL"]
  object_type = "database"
}

# Grant schema privileges
resource "postgresql_grant" "schema" {
  database    = postgresql_database.database.name
  role        = postgresql_role.user.name
  schema      = "public"
  privileges  = ["ALL"]
  object_type = "schema"
}

# Grant default privileges on tables
resource "postgresql_default_privileges" "tables" {
  database    = postgresql_database.database.name
  role        = postgresql_role.user.name
  schema      = "public"
  owner       = var.master_username
  privileges  = ["DELETE", "INSERT", "MAINTAIN", "REFERENCES", "SELECT", "TRIGGER", "TRUNCATE", "UPDATE"]
  object_type = "table"
}

# Grant default privileges on sequences
resource "postgresql_default_privileges" "sequences" {
  database    = postgresql_database.database.name
  role        = postgresql_role.user.name
  schema      = "public"
  owner       = var.master_username
  privileges  = ["SELECT", "UPDATE", "USAGE"]
  object_type = "sequence"
}

# Store user credentials in Secrets Manager
resource "aws_secretsmanager_secret" "user_credentials" {
  name = "${var.project}/${var.environment}/${var.service_name}/db-credentials"
}

resource "aws_secretsmanager_secret_version" "user_credentials" {
  secret_id = aws_secretsmanager_secret.user_credentials.id
  secret_string = jsonencode({
    username = postgresql_role.user.name
    password = random_password.user_password.result
    database = postgresql_database.database.name
    host     = var.host
  })
}

