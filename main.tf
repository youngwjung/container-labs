# 요구되는 테라폼 제공자 설정
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.1"
    }
  }
}

module "intro_container" {
  source = "./intro-container"
}

module "swarm_cluster" {
  source = "./swarm-cluster"
}

module "kubernetes" {
  source = "./kubernetes"
}