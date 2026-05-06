######################################
# Misconfiguration 1:
# Public S3 bucket
######################################
resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "${var.project_name}-insecure-demo-10042026"
}

resource "aws_s3_bucket_ownership_controls" "insecure_bucket_ownership_controls" {
  bucket = aws_s3_bucket.insecure_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "insecure_bucket_public_access" {
  bucket = aws_s3_bucket.insecure_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "insecure_bucket_acl" {
  depends_on = [aws_s3_bucket_public_access_block.insecure_bucket_public_access]

  bucket = aws_s3_bucket.insecure_bucket.id
  acl    = "public-read"
}

######################################
# Misconfiguration 2:
# Versioning disabled
######################################

resource "aws_s3_bucket_versioning" "insecure_bucket_versioning" {
  bucket = aws_s3_bucket.insecure_bucket.id

  versioning_configuration {
    status = "Disabled"
  }
}

######################################
# Misconfiguration 3:
# No default encryption configured
######################################
# Intentionally omitted:
# aws_s3_bucket_server_side_encryption_configuration

######################################
# Misconfiguration 4:
# Public bucket policy
######################################

resource "aws_s3_bucket_policy" "public_bucket_policy" {
  bucket = aws_s3_bucket.insecure_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.insecure_bucket.arn}/*"
      }
    ]
  })
}

######################################
# Misconfiguration 5:
# Overly permissive IAM role and policy
######################################

resource "aws_iam_role" "overprivileged_role" {
  name = "${var.project_name}-overprivileged-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "admin_policy" {
  name        = "${var.project_name}-admin-policy"
  description = "Intentionally overprivileged policy for lab use only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_admin_policy" {
  role       = aws_iam_role.overprivileged_role.name
  policy_arn = aws_iam_policy.admin_policy.arn
}

resource "aws_iam_instance_profile" "overprivileged_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.overprivileged_role.name
}

######################################
# Misconfiguration 6:
# Security group open to the world
######################################

resource "aws_security_group" "open_sg" {
  name        = "${var.project_name}-open-sg"
  description = "Intentionally insecure security group"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH open to the world"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP open to the world"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS open to the world"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic allowed"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

######################################
# Misconfiguration 7:
# EC2 instance with public IP
# Misconfiguration 8:
# IMDSv1 allowed / IMDS not required to use v2
# Misconfiguration 9:
# Unencrypted root volume
######################################

resource "aws_instance" "insecure_ec2" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnet.default_first.id
  vpc_security_group_ids = [aws_security_group.open_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.overprivileged_profile.name

  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  root_block_device {
    encrypted   = false
    volume_type = "gp2"
    volume_size = 8
  }
}

######################################
# Misconfiguration 10:
# Disable AWS EBS encryption by default
######################################
resource "aws_ebs_encryption_by_default" "disabled" {
  enabled = false
}

######################################
# Misconfiguration 11:
# Unencrypted EBS volume and snapshot
######################################
resource "aws_ebs_volume" "insecure_volume" {
  availability_zone = data.aws_subnet.default_first.availability_zone
  size              = 1
  encrypted         = false
}

resource "aws_ebs_snapshot" "insecure_snapshot" {
  volume_id = aws_ebs_volume.insecure_volume.id
}

######################################
# Misconfiguration 12:
# Create a security group with dangerous database exposure
######################################
resource "aws_security_group" "db_open_sg" {
  name        = "${var.project_name}-db-open-sg"
  description = "Intentionally insecure database security group"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "MySQL open to the world"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "PostgreSQL open to the world"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

######################################
# Misconfiguration 13:
# Add an insecure RDS instance
######################################

resource "aws_db_subnet_group" "insecure_db_subnet_group" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

}

resource "aws_db_instance" "insecure_rds" {
  identifier             = "${var.project_name}-rds"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = "adminuser"
  password               = "InsecurePassw0rd123!"
  db_subnet_group_name   = aws_db_subnet_group.insecure_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_open_sg.id]

  publicly_accessible        = true
  storage_encrypted          = false
  backup_retention_period    = 0
  deletion_protection        = false
  skip_final_snapshot        = true
  multi_az                   = false
  auto_minor_version_upgrade = false
}

######################################
# Misconfiguration 14:
# Store a secret insecurely in SSM Parameter Store
######################################
resource "aws_ssm_parameter" "insecure_parameter" {
  name  = "/${var.project_name}/db_password"
  type  = "String"
  value = "SuperInsecurePlaintextPassword123!"
}

######################################
# Misconfiguration 15:
# Weak secret handling in AWS Secrets Manager
######################################
resource "aws_secretsmanager_secret" "insecure_secret" {
  name                    = "${var.project_name}-insecure-secret"
  recovery_window_in_days = 7

}

resource "aws_secretsmanager_secret_version" "insecure_secret_value" {
  secret_id = aws_secretsmanager_secret.insecure_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = "VeryWeakSecretValue123!"
  })
}