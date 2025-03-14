variable "backend_server_count" {
  type = number
}

variable "ipv4_nameservers" {
  type = list(string)
}

variable "labels" {
  type = map(string)
}

variable "project_id" {
  type = string
}
