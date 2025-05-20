output "instane_public_ip" {
    description = "the public ip of instance"
    value = aws_instance.my_instance.public_ip  
}