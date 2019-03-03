resource "aws_ecr_repository" "repositories" {
  count = "${length(var.repositories_names)}"

  name = "${lower(element(var.repositories_names, count.index))}"
}
