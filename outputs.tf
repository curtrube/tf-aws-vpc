output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the VPC."
}
