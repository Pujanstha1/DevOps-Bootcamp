variable "bucket_name" {
	type = string
	description = "Name of the S3 Bucket"
}


variable "force_destroy" {
	type = bool
	default = false
}
