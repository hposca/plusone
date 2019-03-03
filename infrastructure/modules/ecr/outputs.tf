output "repositories_urls" {
  description = "A map {'repository name' => 'repository url', ...} whose names are from 'var.repositories_names' and the URLs from the respectives ECR repos."
  value       = "${zipmap(var.repositories_names, aws_ecr_repository.repositories.*.repository_url)}"
}
