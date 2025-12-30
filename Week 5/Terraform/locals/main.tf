resource "local_file" "pujan" {
  content  = "foo!"
  filename = "${path.module}/${var.filename}.txt"
}
resource "local_file" "pujan1" {
  content  = "foo!"
  filename = "${path.module}/pujan1.txt"
}

locals {
  fruitname = "Suntala"
}