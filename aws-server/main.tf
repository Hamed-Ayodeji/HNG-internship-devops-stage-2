module "vpc" {
  source        = "./modules/vpc"
  project       = var.project
  vpc_cidr      = var.vpc_cidr
}

module "sg" {
  source        = "./modules/sg"
  vpc_id        = module.vpc.vpc_id
  project_name  = module.vpc.project_name

  depends_on    = [ module.vpc ]
}

module "ec2" {
  source        = "./modules/ec2"
  project_name  = module.vpc.project_name
  instance_type = var.instance_type
  sg_id         = module.sg.sg_id
  subnet_id     = module.vpc.subnet_id
  volume_size   = var.volume_size

  depends_on    = [ module.sg ]
}