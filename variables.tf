# Variables for the ETL Infrastructure

# Resource Group Names
variable "dev_rg" {
  type        = string
  description = "Name of the resource group for the development environment"
}

variable "qa_rg" {
  type        = string
  description = "Name of the resource group for the quality environment"
}

variable "prod_rg" {
  type        = string
  description = "Name of the resource group for the production environment"
}

# Azure Data Factory
variable "adf_name" {
  type        = string
  description = "Name of the Azure Data Factory instance"
}

variable "adf_location" {
  type        = string
  default     = "North Europe"
  description = "Location of the Azure Data Factory instance"
}

# Azure Databricks
variable "databricks_name" {
  type        = string
  description = "Name of the Azure Databricks workspace"
}

variable "databricks_location" {
  type        = string
  default     = "North Europe"
  description = "Location of the Azure Databricks workspace"
}

# Azure SQL Database
variable "sql_db_name" {
  type        = string
  description = "Name of the Azure SQL Database instance"
}

variable "sql_db_location" {
  type        = string
  default     = "North Europe"
  description = "Location of the Azure SQL Database instance"
}

# Azure Key Vault
variable "kv_name" {
  type        = string
  description = "Name of the Azure Key Vault instance"
}

variable "kv_location" {
  type        = string
  default     = "North Europe"
  description = "Location of the Azure Key Vault instance"
}

# Monitoring and Alerting
variable "monitor_name" {
  type        = string
  description = "Name of the Azure Monitor instance"
}

variable "monitor_location" {
  type        = string
  default     = "North Europe"
  description = "Location of the Azure Monitor instance"
}

# Other variables
variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {
    environment = "dev"
  }
}

variable "public_ip_allowed_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.0.0/8"]
  description = "CIDR blocks to allow for public IP access"
}

variable "private_ip_allowed_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.0.0/8"]
  description = "CIDR blocks to allow for private IP access"
}
variable "env_suffix" {
  description = "Suffix to add to environment resources."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "The Azure region to deploy resources."
  type        = string
  default     = "north europe"
}

variable "etl_pipeline_interval" {
  description = "The interval (in minutes) to run the ETL pipeline."
  type        = number
  default     = 60
}

variable "etl_pipeline_start_time" {
  description = "The start time (in UTC) to run the ETL pipeline."
  type        = string
  default     = "00:00:00"
}

variable "etl_pipeline_end_time" {
  description = "The end time (in UTC) to run the ETL pipeline."
  type        = string
  default     = "23:59:59"
}

variable "etl_db_server_name" {
  description = "The name of the Azure SQL server for the ETL database."
  type        = string
}

variable "etl_db_name" {
  description = "The name of the Azure SQL database for the ETL."
  type        = string
}

variable "etl_db_username" {
  description = "The username to use when authenticating to the ETL database."
  type        = string
}

variable "etl_db_password" {
  description = "The password to use when authenticating to the ETL database."
  type        = string
}

variable "storage_account_tier" {
  description = "The tier of the storage account to use for the data warehouse."
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "The replication type of the storage account."
  type        = string
  default     = "LRS"
}