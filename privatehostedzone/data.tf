data "aws_vpc" "defaultvpc" {

  default = true
}

data "aws_internet_gateway" "internatgateway" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.defaultvpc.id]
  }
}

data "aws_lb" "istiolb" {
  tags = {
    "kubernetes.io/service-name"                = "istio-ingress/istio-ingress"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}