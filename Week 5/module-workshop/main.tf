module "logs_bucket" {
	source = "./module/s3"
	bucket_name = "pujan-workshop-s3-bucket-adex-${count.index}"
	force_destroy = true
	count =2
}

