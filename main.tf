#EC2 Instance
resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.public.ids[0]
  associate_public_ip_address = true
  security_groups             = [aws_security_group.my_security_group.id]
  key_name                    = var.keypair

  user_data = <<-EOF
            #!/bin/bash
            echo "export AWS_DEFAULT_REGION=${var.region}" >> /etc/profile
            mkdir -p /home/ec2-user/.aws
            echo "[default]" > /home/ec2-user/.aws/config
            echo "region = ${var.region}" >> /home/ec2-user/.aws/config
            chown -R ec2-user:ec2-user /home/ec2-user/.aws
            while [ ! -e /dev/xvdb ]; do
              echo "Waiting for EBS volume to be attached..."
              sleep 10
            done

            sudo mkfs -t ext4 /dev/xvdb
            sudo mkdir /mydata
            sudo mount /dev/xvdb /mydata/
            EOF

  tags = {
    Name = var.ec2name
  }
}

#EC2 Security Group
resource "aws_security_group" "my_security_group" {
  name_prefix = "${var.name}-ec2-ebs-sg"
  description = "Allow SSH"
  vpc_id      = var.vpc_id

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

  lifecycle {
    create_before_destroy = true
  }
}

#EBS Volume
resource "aws_ebs_volume" "volume1" {
  availability_zone = aws_instance.public.availability_zone
  type              = "gp3"
  size              = 1
  iops              = 3000
  throughput        = 125

  tags = {
    Name = "${var.name}-ebs-volume"
  }
}

output "volume_id" {
  value = aws_ebs_volume.volume1.id
}

# Attaching the EBS
resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.volume1.id
  instance_id = aws_instance.public.id

}
