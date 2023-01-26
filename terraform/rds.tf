module "rds" {
  source               = "./rds"
  db_name              = "MySQLDB"
  username             = "MySQLDB"
  password             = var.password
  rds_name             = "mysql-prod"
  private-subnet-cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
  rds_sg_tag           = "mysql-sg"
  vpc-id               = module.network.vpc-id
  private-subnet-ids   = module.network.private-subnet-ids
}