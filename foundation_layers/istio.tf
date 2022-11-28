resource "helm_release" "istio-base" {
  repository = local.istio_charts_url
  chart      = "base"
  name       = "istio-base"
  namespace  = "istio-system"
  version    = var.version_istio_base
  values     = [file("./istiovalues/base-values.yaml")]
  depends_on = [
    kubernetes_namespace.system_namespace
  ]
}

resource "helm_release" "istiod" {
  repository = local.istio_charts_url
  chart      = "istiod"
  name       = "istiod"
  namespace  = "istio-system"
  version    = var.version_istio_istiod
  values     = [file("./istiovalues/istiod-values.yaml")]
  depends_on = [helm_release.istio-base, kubernetes_namespace.system_namespace]
}

resource "helm_release" "istio-ingress" {
  repository = local.istio_charts_url
  chart      = "gateway"
  name       = "istio-ingress"
  namespace  = "istio-ingress"
  version    = var.version_istio_ingress
  values     = [file("./istiovalues/istiogateway-values.yaml")]
  depends_on = [helm_release.istiod, kubernetes_namespace.system_namespace]
}