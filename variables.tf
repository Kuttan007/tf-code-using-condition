variable "instance_type" {

description="ec2 instance type"
type=string
default="t2.micro"
}
variable "most_recent"{
type = bool
default = true
}
variable "ec2_ami" {
  type = map

  default = {
    us-east-1 = "ami-03c7d01cf4dedc891"
  }
}

variable "region" {
default = "us-east-1"
}

variable "instance_count" {
description = " no of instances"
type=number
default=1
}

