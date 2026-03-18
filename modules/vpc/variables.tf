variable "project_name" {
  description = "terraform-devsecops"
}
 
variable "environment" {
  description = "The deployment environment"
  default     = "development"
}
 
variable "region" {
  description = "default region"
}
 
variable "availability_zones" {
  type        = list(any)
  description = "list of availability zones"
}
 
variable "vpc_cidr" {
  description = "CIDR block of vpc"
}
variable "public_subnet_az1_cidr" {
  description = "CIDR block of pub sub 1"
}
variable "public_subnet_az2_cidr" {
  description = "CIDR blcok of pub sub 2"
}
variable "private_app_subnet_az1_cidr" {
  description = "CIDR block of prv app sub 1"
}
variable "private_app_subnet_az2_cidr" {
  description = "CIDR block of prv app sub 2"
}
variable "private_data_subnet_az1_cidr" {
  description = "CIDR block of prv data sub 1"
}
variable "private_data_subnet_az2_cidr" {
  description = "CIDR block of prv data sub 2"
}
 
variable "public_subnets_cidr" {
  type        = list(any)
  description = "CIDR list of pub subs"
}
 
variable "private_subnets_cidr" {
  type        = list(any)
  description =  "CIDR list of orv subs"
}