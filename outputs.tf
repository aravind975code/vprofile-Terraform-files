output "rds_endpoint" {
    description = "RDS Endpoint"
    value       = aws_db_instance.vprofile-rds.endpoint
}
output "Memecache_endpoint" {
    description = "Memcached Endpoint"
    value       = aws_elasticache_cluster.vprofile-cache.configuration_endpoint
 
}
output "RabbitMQ_endpoint" {
    description = "RabbitMQ Endpoint"
    value       = aws_mq_broker.vprofile-rmq.instances.0.endpoints
  
}