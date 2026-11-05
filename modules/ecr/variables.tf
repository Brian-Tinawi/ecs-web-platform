variable "name" {
  description = "Repository name."
  type        = string
}

variable "keep_images" {
  description = "Number of images kept by the lifecycle policy."
  type        = number
  default     = 5
}
