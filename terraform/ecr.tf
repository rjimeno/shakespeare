resource "aws_ecr_repository" "lookup" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false  # set to true if you want automatic scanning on push
  }

  tags = {
    Name = "${var.project_name}-ecr-repo"
  }
}

# ECR lifecycle policy to keep only recent images
resource "aws_ecr_lifecycle_policy" "lookup" {
  repository = aws_ecr_repository.lookup.name
  # Keep lifecycle policy simple and valid: expire images when image count
  # exceeds 10. The previous policy used unsupported fields such as
  # `countMoreThanDays` which caused API validation errors.
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
