resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = var.version_external_dns
  namespace  = "external-dns"
  depends_on = [
    kubernetes_namespace.system_namespace
  ]

  values = [
    file("./foundationlayer_values/external-dns/externaldns-values.yaml")
  ]

}