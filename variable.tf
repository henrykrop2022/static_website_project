variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}


variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "unique-bucket-name-2025"  # Ensure this is unique
}

variable "local_folder_path" {
  description = "The local folder path containing the files to be uploaded"
  type        = string
  default     = "C:\\Users\\henry\\OneDrive\\Desktop\\schoolstatic-main\\schoolstatic-main"  # Adjust the path as necessary
}



 