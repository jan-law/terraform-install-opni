# terraform-install-opni
## How to install Opni 0.10.0 with Terraform

Warning: This method of installation is not supported at the time of writing. I've documented my findings here in case it might benefit anyone in the future.

### Pre reqs
1. Install Terraform: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
2. Provision a Kubernetes cluster on your preferred platform. This will be your upstream cluster for installing Opni. For example, https://ranchermanager.docs.rancher.com/pages-for-subheaders/deploy-rancher-manager
3. Provision any additional downstream clusters to monitor. The Opni Agent will be installed in these clusters.

### Installation steps

#### Install Opni
1. Read the Opni installation guide for "Installation with Helm" > "Chart Configuration" section. Create your own `values.yaml` and fill out the fields for the Opni `gateway`. You do not need the `opni-agent` or `opni-prometheus-crd` fields. https://opni.io/installation/opni/
2. Clone this repo and go to the upstream opni installation directory: `cd opni`
3. Set the `config_path` to your upstream cluster kubeconfig path, eg `~/.kube/config`. You will also need to set the kubeconfig in your terminal: ```export KUBECONFIG=~/.kube/config```
```
# terraform-install-opni/opni/main.tf
  provider "kubernetes" {
    config_path = "~/.kube/config"
  }
```
5. Paste your `values.yaml` file from step 2 into the `opni` directory
6. Add the Opni Helm repo
```
helm repo add opni https://raw.githubusercontent.com/rancher/opni/charts-repo
helm repo update
```
8. Run `terraform init`, `terraform plan` to see the proposed changes to your cluster.
9. Run `terraform apply`. This will install `cert-manager`, the Opni CRDs and Opni. It may take a few minutes to complete.
10. Follow the rest of the documentation to install Opni backends and other features: https://opni.io/installation/opni/

To upgrade Opni, change the "version" number of your upstream opni installation, eg "0.9.2" to "0.10.0" and run `terraform apply`

#### Install Opni Agent
1. Go to the `opni-agent` directory in this repository
2. Fill out the `values.yaml` file in this repo for the agent configuration. Refer to the Opni documentation for more info.
3. Using the same steps as above, set the `config_path` to your *downstream* cluster kubeconfig path, eg
```export KUBECONFIG=~/.kube/downstream-config```
```
# terraform-install-opni/opni-agent/main.tf
  provider "kubernetes" {
    config_path = "~/.kube/downstream-config"
  }
```
5. Run `terraform init`, `terraform plan` to see the proposed changes to your cluster.
6. Run `terraform apply`. This will install `cert-manager`, the Opni CRDs and the Opni agent.
7. Repeat the above steps for each of your downstream clusters.
8. Follow the rest of the documentation to learn how to use Opni: https://opni.io/installation/opni/

### Related Resources
Opni Wiki for additional documentation: https://github.com/rancher/opni/wiki

Opni Github: https://github.com/rancher/opni

Helm Provider Docs: https://registry.terraform.io/providers/hashicorp/helm/latest/docs

Alternative methods for k8s authentication: https://registry.terraform.io/providers/hashicorp/helm/latest/docs#authentication

Tutorial to Deploy Helm Charts with Terraform Module: https://www.bootiq.io/en/deploy-helm-charts-using-terraform-module/
