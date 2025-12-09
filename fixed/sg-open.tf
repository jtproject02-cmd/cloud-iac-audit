resource "aws_security_group" "secure_sg" {
  name = "secure-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]   # restricted private network
  }
}

