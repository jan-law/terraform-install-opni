terraform {
  required_providers {
    helm = {
      version = "1.3.2"
      source = "hashicorp/helm"
    }
    kubernetes = {
      version = "2.20.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  version          = "v1.10.0"
  values = [
    file("cert-manager-values.yaml")
  ]
  cleanup_on_fail = "true"
}

resource "helm_release" "opni-crd" {
  name = "opni-crd"
  repository = "https://raw.githubusercontent.com/rancher/opni/charts-repo"
  chart      = "opni-crd"
  namespace = "opni"
  create_namespace = "true"
  cleanup_on_fail = "true"
}

resource "helm_release" "opni-agent" {
  name = "opni-agent"
  repository = "https://raw.githubusercontent.com/rancher/opni/charts-repo"
  chart      = "opni-agent"
  version = "0.10.0"
  namespace = "opni"
  depends_on = [helm_release.opni-crd, helm_release.cert-manager]
  values = ["${file("values.yaml")}"]
  cleanup_on_fail = "true"
  timeout = "600"
}
