variable "ecr_repo_uri" {}
variable "build_number" {}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "vpc_id" {}
