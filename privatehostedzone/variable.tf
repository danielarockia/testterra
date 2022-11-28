variable "domain" {}

variable "records" {
  type = list(any)
}

variable "cluster_name" {
  type = string
}
