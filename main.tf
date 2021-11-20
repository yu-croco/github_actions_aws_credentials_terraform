resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  // see: https://stackoverflow.com/questions/69247498/how-can-i-calculate-the-thumbprint-of-an-openid-connect-server
  thumbprint_list = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e"]
}

resource "aws_iam_role" "github_actions" {
  name                  = "github-actions"
  assume_role_policy    = data.aws_iam_policy_document.github_actions.json
  description           = "for GitHub Actions OIDC"
}

data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github_actions.arn
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      # Add Target GitHub Repo here
      # e.g. repo:octo-org/octo-repo:ref:*
      values   = []
    }
  }
}

# Add Policies for handling AWS Resources from GitHub Actions
# e.g. Push Docker images to ECR
data "aws_iam_policy_document" "github_actions_additional" {
  // ECR Push
  statement {
    actions = [
      "xxxxxx",
    ]
    resources = ["xxxxxx"]
  }
}

resource "aws_iam_policy" "github_actions_additional" {
  name        = "github-actions-additional"
  description = "github-actions OIDC"

  policy = data.aws_iam_policy_document.github_actions_additional.json
}

resource "aws_iam_role_policy_attachment" "github_actions_additional" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_additional.arn
}
