resource "helm_release" "cluster-autoscaler_eks" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  #version = var.version_argocd
  namespace = "cluster-autoscaler"
  depends_on = [
    kubernetes_namespace.system_namespace
  ]

  values = [
    file("D:\\AWS-TF\\tf-helm-singsub-oidc\\infra-terraform-environments\\env\\dev\\dev\\ap-south-1\\eks\\eks_controlplane\\foundationlayer\\cluster-autoscaler\\cluster-autoscaler-values.yaml")
  ]

}