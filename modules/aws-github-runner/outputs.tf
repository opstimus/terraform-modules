output "instance_id" {
  description = "The ID of the GitHub runner EC2 instance"
  value       = aws_instance.github_runner.id
}
