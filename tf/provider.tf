terraform {
  required_version = "1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.90.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }

  backend "s3" {
    region = "us-east-1"
    key    = "terraform/eks.tfstate"
    bucket = "vdlg-tf"
  }

  # backend "local" {
  #   path   = "terraform.tfstate"
  # }
}


provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

provider "helm" {
  kubernetes {
    host                   = module.cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.cluster.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.cluster.cluster_name]
    }
  }
}
