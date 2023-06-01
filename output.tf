
output "public_ip" {
   value = aws_instance.bastion[0].public_ip

}

output "private_ip" {
   value = aws_instance.web3[0].private_ip

}

