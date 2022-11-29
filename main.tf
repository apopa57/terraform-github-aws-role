terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.36"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-1"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  # this value was obtained as explained in https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
  # The certificate of the top intermediate CA for token.actions.githubusercontent.com is in certificate.crt
  # the thumbprint can be obtained using the following command: openssl x509 -in certificate.crt -fingerprint -noout | sed -e 's/.*=//' | tr -d : | tr [A-Z] [a-z]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github" {
  name = "github-workflows"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:apopa57/terraform-github-aws-role:*"
          }
        }
      }
    ]
  })

  inline_policy {
    name = "allow-s3"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["s3:*"]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

output "openid_connect_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}

output "role_arn" {
  value = aws_iam_role.github.arn
}
