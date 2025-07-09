output "cluster" {
  description = "values for the EKS cluster"
  value       = aws_eks_cluster.eks_cluster
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "cluster_certificate_authority_data" {
  description = "The certificate-authority-data for the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}