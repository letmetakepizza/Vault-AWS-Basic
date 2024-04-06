variable "vpc_cidrblock" {
  type    = string
  default = "10.100.0.0/16"
}
variable "freetier_instance_type" {
  type    = string
  default = "t2.micro"
}
variable "whitelisted_sg_outbound_cidr" {
  type    = string
  default = "0.0.0.0/0"
}
variable "instance_amount" {
  type    = string
  default = "3"
}