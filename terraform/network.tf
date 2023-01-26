module "network" {
  source               = "./network"
  vpc_tag              = "vpc"
  vpc_cidr             = "10.0.0.0/16"
  public-subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
  private-subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
  azs                  = ["us-east-1a", "us-east-1b"]
}