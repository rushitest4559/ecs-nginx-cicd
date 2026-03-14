resource "aws_security_group" "vpc_endpoints" {
  name        = "nginx-endpoint-sg"
  vpc_id      = aws_vpc.nginx-vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # Allow only your VPC's traffic to reach the endpoints
    cidr_blocks = [var.vpc_cidr]
  }
}