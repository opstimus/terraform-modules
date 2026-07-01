output "codebuild_project_name" {
  description = "The name of the CodeBuild project acting as GitHub Actions runner"
  value       = aws_codebuild_project.github_runner.name
}

output "codebuild_project_arn" {
  description = "The ARN of the CodeBuild project"
  value       = aws_codebuild_project.github_runner.arn
}

output "runner_role_arn" {
  description = "The ARN of the IAM role used by the CodeBuild runner"
  value       = aws_iam_role.github_runner.arn
}

output "github_connection_arn" {
  description = "The CodeConnections ARN — pass to github_connection_arn if reusing this connection in another module instance"
  value       = local.github_connection_arn
}

output "runs_on_label" {
  description = "Static prefix for the GitHub Actions runs-on label. Append -GITHUB_RUN_ID-GITHUB_RUN_ATTEMPT in your workflow."
  value       = "codebuild-${aws_codebuild_project.github_runner.name}"
}
