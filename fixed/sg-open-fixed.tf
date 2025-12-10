resource "aws_security_group" "restricted_sg" {
  name        = "restricted-ssh-sg"
  description = "Allow SSH only from corporate subnet"
  vpc_id      = "vpc-12345678" # example VPC ID placeholder

  ingress {
    description = "SSH from corporate office"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]  # internal subnet only
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "restricted-ssh-sg"
  }
}
