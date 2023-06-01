
provider "aws" {
  region  = "us-east-1"
}



// VPC
data "aws_vpc" "vpc" {
  id = "vpc-0932ea0661895317f"

}

// PUBLIC SUBNETS
data aws_subnet "public_subnet" {
id = "subnet-032fbc0596079792f"
}
// PRIVATE SUBNETS
data "aws_subnet" "private_subnet" {
id = "subnet-0672ca0472b30baf7"
}

// IGW
data "aws_internet_gateway" "ig" {
filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.vpc.id]
  }


}
// EIP
data "aws_eip" "nat_eip" {
id = "eipalloc-0c054318ee8d1f200"
}


// NAT
data "aws_nat_gateway" "nat" {
  subnet_id     = "subnet-032fbc0596079792f"
  id =   "nat-0595e5517d9b20f20"

}


// PRIVATE ROUTE
data "aws_route_table" "private" {
route_table_id = "rtb-0c340ba7355120dff"
}

data "aws_route" "private_nat_gateway" {
route_table_id = "rtb-0c340ba7355120dff"
nat_gateway_id= "nat-0595e5517d9b20f20"
}


  data "aws_ami" "amzlinux2" {
  most_recent = var.most_recent
  #provider    = aws.oregon
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

}

resource "aws_key_pair" "terraform" {
  key_name   = "terraform"
  public_key = file("/root/.ssh/id_rsa.pub")
}
resource "aws_security_group" "ec2-sg" {
  vpc_id =  data.aws_vpc.vpc.id
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ec2-sg"
  }
}

 resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amzlinux2.id
count         = "${var.instance_type == "t2.micro" ? 1 : 0}"
   subnet_id     = data.aws_subnet.public_subnet.id
 vpc_security_group_ids = [aws_security_group.ec2-sg.id]
   instance_type = var.instance_type


  key_name = aws_key_pair.terraform.key_name
tags = {
    # The count.index allows you to launch a resource
    # starting with the distinct index number 0 and corresponding to this instance.
    Name = "bastion-${count.index}"
  }
}


resource "aws_instance" "web3" {
  ami = lookup(var.ec2_ami,var.region)

  count         = "${var.instance_type == "t2.micro" ? 1 : 0}"
  subnet_id     = data.aws_subnet.private_subnet.id
  key_name = aws_key_pair.terraform.key_name
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
   instance_type = var.instance_type
tags = {
    # The count.index allows you to launch a resource
    # starting with the distinct index number 0 and corresponding to this instance.
    Name = "web3-${count.index}"
  }
}
