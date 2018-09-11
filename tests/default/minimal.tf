provider "aws" {
  region = "us-west-2"
}

resource "random_string" "rstring" {
  length  = 18
  upper   = false
  special = false
}

resource "aws_security_group" "test_sg1" {
  name        = "${random_string.rstring.result}-test-sg-1"
  description = "Test SG Group 1"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "test_sg2" {
  name        = "${random_string.rstring.result}-test-sg-2"
  description = "Test SG Group 2"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "vpc" {
  source              = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.2"
  az_count            = 2
  cidr_range          = "10.0.0.0/16"
  public_cidr_ranges  = ["10.0.1.0/24", "10.0.3.0/24"]
  private_cidr_ranges = ["10.0.2.0/24", "10.0.4.0/24"]
  vpc_name            = "${random_string.rstring.result}-test"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "test01" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id     = "${module.vpc.public_subnets[0]}"
}

resource "aws_instance" "test02" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id     = "${module.vpc.public_subnets[1]}"
}

module "clb" {
  source = "../../module"

  clb_name        = "${random_string.rstring.result}-test"
  security_groups = ["${aws_security_group.test_sg1.id}", "${aws_security_group.test_sg2.id}"]
  instances       = ["${aws_instance.test01.id}", "${aws_instance.test02.id}"]

  tags = [{
    "Right" = "Said"
  }]

  create_logging_bucket = false
  rackspace_managed     = false
  subnets               = "${module.vpc.public_subnets}"
}
