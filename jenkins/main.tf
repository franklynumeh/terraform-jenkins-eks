# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "devops-vpc"
  cidr = var.vpc_cidr

  azs                     = data.aws_availability_zones.azs.names
  public_subnets          = var.public_subnets
  map_public_ip_on_launch = true

  enable_dns_hostnames = true

  tags = {
    Name        = "devops-vpc"
    Terraform   = "true"
    Environment = "dev"
  }

  public_subnet_tags = {
    Name = "devops-public-subnet"
  }
}

# SG
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "security group for jenkins server "
  vpc_id      = module.vpc.vpc_id


  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = {
    Name = "jenkins-sg"
  }
}

# EC2
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Jenkins-Server"

  instance_type               = var.instance_type
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = "Jenkins_Server-client-keypair"
  monitoring                  = true
  vpc_security_group_ids      =[module.sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  # user_data                   = file("jenkins-install.sh")
  availability_zone           = data.aws_availability_zones.azs.names[0]

  tags = {
    Name        = "Jenkins-Server"
    Terraform   = "true"
    Environment = "dev"
  }
}


# 1. 🔧 module "ec2_instance"
# 	•	This is a Terraform-local label
# 	•	Used only inside your code for referencing outputs or inputs
# 	•	Example:
  
#   output "instance_id" {
#   value = module.ec2_instance.id
# }

# 	•	✅ Doesn’t affect AWS at all

# ⸻

# 2. 🧠 name = "Jenkins-Server" (module input)
# 	•	This is passed into the module — and the module uses it to generate names internally
# 	•	So you might see resources in AWS named like:
# 	•	Jenkins-Server
# 	•	Jenkins-Server-eni
# 	•	Jenkins-Server-volume

# (Assuming the module is written to use that name for resource names or tags.)

# ⸻

# 3. 🏷️ tags = { Name = "Jenkins-Server" }
# 	•	This is the AWS resource tag
# 	•	This is what you see in the AWS Console under the “Name” column
# 	•	Used for filtering, grouping, billing, etc.

# ⸻

# 🧠 Example Recap