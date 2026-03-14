variable "repository_url" {
  description = "The URL of the ECR repository to pull the nginx image from"
  type        = string  
}

variable "vpc_id" {
  
}

variable "alb_security_group_id" {
  
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets for the ECS tasks"
  type        = list(string)
}

variable "target_group_arn" {
  description = "The ARN of the target group to attach the ECS service to"
  type        = string
}