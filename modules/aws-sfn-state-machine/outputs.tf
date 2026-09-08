output "state_machine_arn" {
  value       = aws_sfn_state_machine.main.arn
  description = "The ARN of the state machine"
}

output "state_machine_name" {
  value       = aws_sfn_state_machine.main.name
  description = "The name of the state machine"
}
