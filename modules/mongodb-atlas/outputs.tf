output "project_id" {
  value = mongodbatlas_project.project.id
}

output "cluster_id" {
  value = mongodbatlas_cluster.cluster.id
}

output "private_endpoint_id" {
  value = mongodbatlas_privatelink_endpoint.pe_east.id
}

# output "s3_bucket_name" {
#   value = aws_s3_bucket.atlas_logs.bucket
# }