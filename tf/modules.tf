module "cluster" {
  source = "./modules/cluster"


  cluster_name = var.cluster_name
  region       = var.region

  vpc_cidr = var.vpc_cidr
  azs      = var.azs

}