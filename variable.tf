variable "environ" {
  description = "environment"
  type        = string
  default     = "dev"
}

variable "queue_name" {
  description = "SQS Queue Name"
  type        = string
  default     = "dev-queue" # Assumed the queue is already present
}
variable "subnet_ids" {
  description = "Subnet Ids"
  type = list(string)
  default = [ "subnet-0b9787a45292c548f", "subnet-04de3a54ccf0f851d" ]
  
}
variable "security_groups" {
  description = "Security Groups"
  type = list(string)
  default = [ "sg-0bd4033715c583e75" ]
  
}

variable "high_end_target_group_arn" {
  description = "High End Target Group Arn"
  type = string
  default =  "arn:aws:elasticloadbalancing:ap-southeast-1:167814279506:targetgroup/high-end-node-tg/4c41b0f7f697636c" 
  
}
variable "low_end_target_group_arn" {
  description = "Low End Target Group Arn"
  type = string
  default =  "arn:aws:elasticloadbalancing:ap-southeast-1:167814279506:targetgroup/low-end-node-tg/47eb294ec184ab68" 
  
}
variable "alb_listener_group_arn" {
  description = "ALB Listener Group Arn"
  type = string
  default =  "arn:aws:elasticloadbalancing:ap-southeast-1:167814279506:listener-rule/app/dev-snap-backend-alb/c21aa16bac5be01e/48900cbbaa7b5068/332694db298a81fc" 
  
}