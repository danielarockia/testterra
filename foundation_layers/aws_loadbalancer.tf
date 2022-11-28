resource "helm_release" "aws-load-balancer-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "lb"
  version    = var.version_aws-load-balancer-controller
  depends_on = [
    kubernetes_namespace.system_namespace
  ]
  values = [
    file("./foundationlayer_values/aws-loadbalancer-controller/aws-loadbalancer-controller-values.yaml")
  ]

}