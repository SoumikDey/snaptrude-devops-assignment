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
