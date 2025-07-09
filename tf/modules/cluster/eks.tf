data "aws_vpc" "name_vpc" {
  filter {
    name   = "tag:Name"
    values = ["vpc-vdlg"]
  }
}

data "aws_subnet" "name_subnet_a" {
  filter {
    name   = "tag:Name"
    values = ["vpc-vdlg-private-us-east-1a"]
  }
}

data "aws_subnet" "name_subnet_b" {
  filter {
    name   = "tag:Name"
    values = ["vpc-vdlg-private-us-east-1b"]
  }
}

resource "aws_security_group" "eks_security_group" {
  name        = "eks-security-group"
  description = "Secury Group for EKS Cluster"
  vpc_id      = data.aws_vpc.name_vpc.id
  ingress {
    description = "Allow all traffic from within the security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "vdlg-eks-cluster"
  role_arn = var.role_eks
  version  = "1.32"

  vpc_config {
    subnet_ids = [
      data.aws_subnet.name_subnet_a.id,
      data.aws_subnet.name_subnet_b.id,
    ]
    security_group_ids = [aws_security_group.eks_security_group.id]

  }

  depends_on = [aws_security_group.eks_security_group]
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = var.role_eks
  subnet_ids      = [data.aws_subnet.name_subnet_a.id, data.aws_subnet.name_subnet_b.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
}