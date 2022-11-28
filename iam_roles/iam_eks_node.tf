resource "aws_iam_role" "eks_workernode_role" {
  name = "${var.env}_EKSWorkerRole"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "eks-clusterautoscaler" {
  name = "${var.env}_ClusterAutoscaler"


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeTags",
          "autoscaling:DescribeTags",
          "autoscaling:*"
        ],
        "Resource" : "*"
      },
    ]
  })
}

resource "aws_iam_policy" "eks-External-DNS" {
  name = "${var.env}_External_DNS"


  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets"
        ],
        "Resource" : "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_workernode_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_workernode_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_workernode_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEBSCSIDriverPolicyVolume" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_workernode_role.name
}

resource "aws_iam_role_policy_attachment" "eks-clusterautoscaler" {
  policy_arn = aws_iam_policy.eks-clusterautoscaler.arn
  role       = aws_iam_role.eks_workernode_role.name
}

resource "aws_iam_role_policy_attachment" "eks-External-DNS" {
  policy_arn = aws_iam_policy.eks-External-DNS.arn
  role       = aws_iam_role.eks_workernode_role.name
}

resource "aws_iam_instance_profile" "profile" {
  name = aws_iam_role.eks_workernode_role.name
  role = aws_iam_role.eks_workernode_role.name
}
