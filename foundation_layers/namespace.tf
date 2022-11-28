

resource "kubernetes_namespace" "app_namespace" {
  for_each = { for i, v in var.app_namespace : i => v }
  metadata {
    annotations = {
      name = var.app_namespace[each.key].namespace_name
    }
    labels = {
      istio-injection = "enabled"
    }
    name = var.app_namespace[each.key].namespace_name
  }
}

resource "kubernetes_namespace" "system_namespace" {
  for_each = { for i, v in var.foundationlayer_namespace : i => v }
  metadata {
    annotations = {
      name = var.foundationlayer_namespace[each.key].namespace_name
    }

    name = var.foundationlayer_namespace[each.key].namespace_name
  }
}