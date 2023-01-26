module "compute" {
  source                = "./compute"
  bastion_avail_zone    = "us-east-1a"
  bastion_pub_subnet_id = module.network.public-subnet-ids[0]
  bastion_pub_subnet_cidr = ["10.0.0.0/24", "10.0.1.0/24"]
  instance_type         = "t2.micro"
  key_name              = "test"
  vpc_id                = module.network.vpc-id
  vpc_cidr              = module.network.vpc-cidr
  private_subnet_ids    = module.network.private-subnet-ids
  public_subnet_ids     = module.network.public-subnet-ids
}