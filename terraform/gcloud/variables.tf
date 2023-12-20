variable "gcloud_project" {
  description = "Google Cloud Project where resources will be created"
}

variable "gcloud_zone" {
  description = "Google Cloud Zone where resources will be created"
}

variable "name_prefix" {
  description = "Prefix to distinguish the instance"
  default     = "ace-box"
}

variable "acebox_size" {
  description = "Size (machine type) of the ace-box instance"
  default     = "n2-standard-8"
}

variable "acebox_user" {
  description = "Initial user when ace-box is created"
  default     = "ace"
}

variable "acebox_os" {
  description = "Ubuntu version to use"
  default     = "ubuntu-minimal-2004-lts"
}

variable "custom_domain" {
  description = "Set to overwrite custom domain"
  default     = ""
}

variable "managed_zone_name" {
  description = "Name of GCP managed zone"
  default     = ""
}

variable "skip_domain_workspace_alignment" {
  description = "Set to true if your custom domain shall not be aligned with the currently active Terraform workspace. ATTENTION: This will result in conflicts when the same custom domain is used in multiple workspaces!"
  default     = false
}

variable "disk_size" {
  description = "Size of disk that will be available to ace-box instance"
  default     = "60"
}

variable "dt_tenant" {
  description = "Dynatrace tenant in format of https://[environment-guid].live.dynatrace.com OR https://[managed-domain]/e/[environment-guid]"
}

variable "dt_api_token" {
  description = "Dynatrace API token in format of 'dt0c01. ...'"
}

variable "ingress_protocol" {
  description = "Ingress protocol"
  default     = "http"
}

variable "use_case" {
  type        = string
  description = "Use cases the ACE-Box will be enabled for."
  default     = "demo_default"
}

variable "extra_vars" {
  type    = string
  default = "{}"
}

variable "dashboard_user" {
  type        = string
  description = "ACE-Box dashboard user."
  default     = "dynatrace"
}

variable "dashboard_password" {
  type        = string
  description = "ACE-Box dashboard password."
  default     = ""
}

variable "ace_box_version" {
  type = string
}
