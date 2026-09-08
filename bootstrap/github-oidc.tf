variable "github_repo" {
  description = "usuario/repositorio en GitHub"
  type        = string
  # ejemplo: "tuusuario/lab-terraform-aws"
}

# Proveedor de identidad: AWS confiará en los tokens que emite GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
}

# Rol que asumirá el pipeline: SOLO desde este repositorio
resource "aws_iam_role" "github_actions" {
  name = "github-actions-terraform-lab"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
        StringLike   = { "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*" }
      }
    }]
  })
}

# Para el laboratorio usamos una política amplia. En producción: política
# acotada a los servicios y recursos que el pipeline realmente gestiona.
resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "role_arn" {
  description = "Cópielo en el secreto AWS_ROLE_ARN del repositorio"
  value       = aws_iam_role.github_actions.arn
}
