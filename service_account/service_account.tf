data "aws_partition" "current" {}

# data "aws_eks_cluster" "example" {
#   name = var.cluster_name
# }
variable "eks_oidc_root_ca_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

# Resource: AWS IAM Open ID Connect Provider
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.${data.aws_partition.current.dns_suffix}"]
  thumbprint_list = [var.eks_oidc_root_ca_thumbprint]
  url             = data.aws_eks_cluster.controlplane.identity[0].oidc[0].issuer

}

output "aws_iam_openid_connect_provider_arn" {
  description = "AWS IAM Open ID Connect Provider ARN"
  value       = aws_iam_openid_connect_provider.oidc_provider.arn
}

# Extract OIDC Provider from OIDC Provider ARN
locals {
  aws_iam_oidc_connect_provider_extract_from_arn = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider.arn}"), 1)
}

# Output: AWS IAM Open ID Connect Provider
output "aws_iam_openid_connect_provider_extract_from_arn" {
  description = "AWS IAM Open ID Connect Provider extract from ARN"
  value       = local.aws_iam_oidc_connect_provider_extract_from_arn
}


resource "aws_iam_role" "eks_EBS_CSI" {
  name = "${var.env}_EKS_EBS_CSI_DRIVER"


  assume_role_policy = jsonencode({

    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : aws_iam_openid_connect_provider.oidc_provider.arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider.arn}"), 1)}:aud" : "sts.amazonaws.com",
            "${element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider.arn}"), 1)}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
    }
  )
  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_EBS_CSI.name
}

resource "kubernetes_service_account_v1" "eks_EBS_CSI_sa" {
  depends_on = [aws_iam_role_policy_attachment.eks-s3_read_access]
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_EBS_CSI.arn
    }
  }
}

#---
resource "aws_iam_role" "eks_s3_access" {
  name = "${var.env}_s3_read_access"


  assume_role_policy = jsonencode({

    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          #"Federated": "arn:aws:iam::649502456029:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/A174A424549D545AF3B401C8B68020C1"
          "Federated" : aws_iam_openid_connect_provider.oidc_provider.arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            #"${element(split("oidc-provider/", "oidc.eks.us-east-2.amazonaws.com/id/A174A424549D545AF3B401C8B68020C1"), 1)}:sub": "system:serviceaccount:default:s3-read-access-sa"
            "${element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider.arn}"), 1)}:sub" : "system:serviceaccount:kube-system:s3-read-access-sa"
          }
        }
      }
    ]
    }
  )
  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy_attachment" "eks-s3_read_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.eks_s3_access.name
}

resource "kubernetes_service_account_v1" "s3_readaccess_sa" {
  depends_on = [aws_iam_role_policy_attachment.eks-s3_read_access]
  metadata {
    name      = "s3-read-access-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_s3_access.arn
    }
  }
}


# Resource: Kubernetes Job
resource "kubernetes_job_v1" "s3_read_access_job" {
  metadata {
    name      = "s3-read-access"
    namespace = "kube-system"
  }
  depends_on = [
    kubernetes_service_account_v1.s3_readaccess_sa
  ]
  spec {
    template {
      metadata {
        labels = {
          app = "s3-read-access"
        }
      }
      spec {
        service_account_name = "s3-read-access-sa"
        container {
          name  = "s3-read-access"
          image = "amazon/aws-cli:latest"
          args  = ["s3", "ls"]
          #args = ["ec2", "describe-instances", "--region", "${var.aws_region}"] # Should fail as we don't have access to EC2 Describe Instances for IAM Role
        }
        restart_policy = "Never"
      }
    }
  }
}


