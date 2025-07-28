variable "docker_image" {}
variable "execution_role" {}
variable "subnets" {
  type = list(string)
}
variable "security_group" {}

