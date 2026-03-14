module "vpc" {
  source = "../modules/vpc"
}

module "ecr" {
  source = "../modules/ecr"
}

module "alb" {
  source            = "../modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "ecs" {
  source                = "../modules/ecs"
  repository_url        = module.ecr.repository_url
  vpc_id                = module.vpc.vpc_id
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  private_subnet_ids    = module.vpc.private_subnet_ids
}

module "oidc" {
  source = "../modules/oidc"
}