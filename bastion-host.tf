data "aws_ami" "ubuntu22amiID"{
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "vprofile_bastion" {
  ami                     = data.aws_ami.ubuntu22amiID.id
  instance_type           = "t3.micro"
  count                   =  var.instance_count
  subnet_id               =  module.vpc.public_subnets[0]
  key_name                =  aws_key_pair.vprofilekey.key_name
  vpc_security_group_ids  =  [aws_security_group.vprofile_bastion_sg.id]



tags = {

    Name = "vprofile-bastion"
    PROJECT = "vprofile"
}

provisioner "file" {
    content     = templatefile("templates/db-deploy.sh", { rds_endpoint = aws_db_instance.vprofile-rds.address, dbuser = var.dbuser, dbpass = var.dbpass })
    destination = "/tmp/vprofile-dbdeploy.sh"
}

  connection {
    type     = "ssh"
    user     = var.USERNAME
    private_key = file(var.PRIV_KEY_PATH)
    host     = self.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/vprofile-dbdeploy.sh",
      "sudo /tmp/vprofile-dbdeploy.sh"
    ]
}


}