variable "whitelist" {
  type = list(string)
}
variable "web_instance_type" {
  type = string
}
variable "web_desired_capacity" {
  type = number
}
variable "web_max_size" {
  type = number
}
variable "web_min_size" {
  type = number
}
variable "vpc_id" {
  type = string
}
variable "vpc_public_subnets" {
  type = list
}
variable "vpc_private_subnets" {
  type = list
}