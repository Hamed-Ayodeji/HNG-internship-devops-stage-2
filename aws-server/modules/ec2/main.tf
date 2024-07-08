resource "tls_private_key" "rsa_key" {
  algorithm               = "RSA"
  rsa_bits                = 4096
}

resource "aws_key_pair" "rsa_key_pair" {
  key_name                = "${var.project_name}-key"
  public_key              = tls_private_key.rsa_key.public_key_openssh

  depends_on              = [ tls_private_key.rsa_key ]
}

resource "local_file" "rsa_key_file" {
  content                 = tls_private_key.rsa_key.private_key_pem
  filename                = "${var.project_name}-key.pem"
  file_permission         = "0400"

  depends_on              = [ tls_private_key.rsa_key ]
}

resource "aws_instance" "server" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type
  key_name                = aws_key_pair.rsa_key_pair.key_name
  vpc_security_group_ids  = [var.sg_id]
  subnet_id               = var.subnet_id
  user_data               = file("${path.module}/installer.sh")

  root_block_device {
    volume_size           = var.volume_size
  }

  tags                    = {
    Name                  = "${var.project_name}-server"
  }

  depends_on              = [ aws_key_pair.rsa_key_pair ]
}