variable "cluster_name" {}
variable "env" {}
variable "region" {}
variable "foundationlayer_namespace" {
  type = list(object({
    namespace_name = string
  }))
}
variable "app_namespace" {
  type = list(object({
    namespace_name = string
  }))
}

variable "version_argocd" {}
variable "version_aws-load-balancer-controller" {}
variable "version_aws-ebs-csi-driver" {}
variable "version_metrics-server" {}
variable "version_istio_istiod" {}
variable "version_istio_base" {}
variable "version_istio_ingress" {}
variable "version_external_dns" {}
