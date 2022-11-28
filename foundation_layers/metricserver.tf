resource "helm_release" "metrics" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.version_metrics-server


  values = [
    file("./foundationlayer_values/metric-server/metrics-server-values.yaml")
  ]

}