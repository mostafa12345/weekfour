resource "aws_s3_bucket" "s3_bucket_01" {

   bucket = "mostaf1215sda4415"
   force_destroy = true
   object_lock_enabled = false 
   tags = {
    Name        = "s3_bucket_01"
    Environment = "terraformChamps"
  }
}

resource "aws_s3_object" "s3_directory_logs" {
  bucket = aws_s3_bucket.s3_bucket_01.bucket
  key    = "logs/"
  content_type = "application/x-directory"

  tags = {
    Environment = "terraformChamps"
  }
}

# IAM Role
resource "aws_iam_role" "ec2_s3_full_access_role" {
  name = "ec2_s3_full_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AmazonS3FullAccess policy to the role
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.ec2_s3_full_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_s3_full_access_profile"
  role = aws_iam_role.ec2_s3_full_access_role.name
}
# Reference to an existing VPC
data "aws_vpc" "existing_vpc" {
  id = "vpc-0fe62257f65181baf"
}

# Reference to an existing Subnet
data "aws_subnet" "public_subnet" {
  id = "subnet-0f2cb04ff4757d538" 
}

# Reference to an existing Security Group
data "aws_security_group" "public_sg" {
  id = "sg-051c83d4f01be8b42" 
}


# EC2 Instance
resource "aws_instance" "ec2" {
  ami           = "ami-08a0d1e16fc3f61ea"
  instance_type = "t2.micro"
  subnet_id            = data.aws_subnet.public_subnet.id
  vpc_security_group_ids = [data.aws_security_group.public_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = true

  tags = {
    Name = "EC2Withfullacces_s3"
  }

}
