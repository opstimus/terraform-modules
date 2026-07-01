output "state_machine_arn" {
  value       = aws_sfn_state_machine.main.arn
  description = "ARN of the Step Function state machine that runs the task."
}

output "state_machine_name" {
  value       = aws_sfn_state_machine.main.name
  description = "Name of the Step Function state machine."
}

