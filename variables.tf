variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

#variable "api_token" {
#  description = "API token for Grafana provider"
#  type        = string
#}
#
#variable "grafana_url" {
#  description = "URL of the Grafana instance"
#  type        = string
#}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
  default     = "us-east-1a"
}

variable "key_pair_name" {
  default = "bibinaws123"
}

variable "security_group_name" {
  description = "Name for the security group"
  type        = string
  default     = "example_sg"
}

variable "security_group_description" {
  description = "Description for the security group"
  type        = string
  default     = "Example security group"
}

variable "monitoring_ami" {
  description = "AMI ID for Grafana instance"
  type        = string
  default     = "ami-04a0ae173da5807d3" # Replace with the appropriate Grafana AMI ID
}

variable "instance_type" {
  description = "Instance type for Grafana instance"
  type        = string
  default     = "t2.micro"
}


