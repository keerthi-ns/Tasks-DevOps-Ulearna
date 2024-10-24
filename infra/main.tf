#VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  assign_generated_ipv6_cidr_block = true
  tags = { Name = "terra_vpc" }
}

#Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
}

#Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1d"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1e"
  map_public_ip_on_launch = false
}

#internet gateway
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "terra_igw" }
}

#Public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
  tags = { Name = "terra_public_route" }
}

#Associate public subnets with route table
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# NAT Gateway for Private Subnets
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = { Name = "terra_nat_eip" }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = { Name = "terra_private_route" }
}

#Associate Private Subnets with Route Table
resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Route 53 Hosted Zone for Custom Domain
resource "aws_route53_zone" "main_zone" {
  name = var.domain_name  
  tags = {    Name = "MainHostedZone"  }
}

# Load Balancer 
resource "aws_lb" "main_lb" {
  name               = "main-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  tags = {  Name = "Main-LB" }
}


# Security groups for bastion
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.main.id
  name   = "bastion_sg" 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {   Name = "Bastion-SG"  }
}

#Security Group for LB
resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.main.id
  name   = "lb_sg" 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {    Name = "LoadBalancer-SG"  }
}

# Security Group for EKS
resource "aws_security_group" "eks_sg" {
  vpc_id = aws_vpc.main.id
  name   = "eks_sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {    Name = "EKS-SG"  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id
  name   = "rds_sg"  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups =  [aws_security_group.eks_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {    Name = "RDS-SG"  }
}

#S3 Bucket
resource "aws_s3_bucket" "terra_bucket" {
  bucket = "my-nextjs-terra-bucket090"  
  acl    = "public-read"
  tags = {  Name = "Next.js Bucket"  }
}

#Cloudfront
resource "aws_cloudfront_distribution" "my_distribution" {
  origin {
    domain_name = aws_s3_bucket.terra_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"
    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port             = 80
      https_port            = 443
      origin_ssl_protocols  = ["TLSv1.2"]
    }
  }
  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"
  default_cache_behavior {
    target_origin_id = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.keerthi_cert.arn
    ssl_support_method  = "sni-only"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {  Name = "CloudFront Distribution-next"  }
}

# ACM Certificate
resource "aws_acm_certificate" "keerthi_cert" {
  domain_name       = var.domain_name  
  validation_method = "DNS"
  tags = {  Name = "ACM Certificate-next"  }
}

# A Record set in Route 53
resource "aws_route53_record" "CloudFront_record" {
  zone_id = aws_route53_zone.main_zone.zone_id
  name    = "www.${var.domain_name}"  
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.my_distribution.domain_name 
    zone_id                = aws_cloudfront_distribution.my_distribution.hosted_zone_id  
    evaluate_target_health = true
  }
}

# DNS Validation for ACM Certificate 
resource "aws_route53_record" "cert_validation_record" {
  count = length(aws_acm_certificate.keerthi_cert.domain_validation_options)
  zone_id = aws_route53_zone.main_zone.id
  name     = aws_acm_certificate.keerthi_cert.domain_validation_options[count.index].resource_record_name
  type     = aws_acm_certificate.keerthi_cert.domain_validation_options[count.index].resource_record_type
  ttl      = 60
  records   = [aws_acm_certificate.keerthi_cert.domain_validation_options[count.index].resource_record_value]
}