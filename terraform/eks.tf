module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  # Allow patch/minor upgrades within major version range so newer module
  # releases that move away from `inline_policy` can be used. Pinning too
  # strictly causes Terraform to keep older module code that triggers the
  # deprecation warning. Restrict to major < 21 to avoid unexpected major
  # breaking changes.
  version = ">= 19.16, < 21.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # Control plane logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)

  # EKS Managed Node Group
  eks_managed_node_groups = {
    default = {
      name            = "${var.cluster_name}-node-group"
      use_name_prefix = true
      capacity_type   = "ON_DEMAND"

      instance_types = [var.node_instance_type]

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      disk_size = 20

      # IAM role policy attachments
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }
    }
  }

  # Required tags for AWS Load Balancer Controller
  cluster_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  # WARNING: older module versions accepted `manage_aws_auth_configmap`,
  # `aws_auth_roles` and `aws_auth_users`. Those arguments have been removed
  # from newer releases of the `terraform-aws-modules/eks` module. Use the
  # `access_entries` input or manage the `aws-auth` ConfigMap yourself.
  #
  # Example (commented): add an access entry mapping for an IAM role or user
  # access_entries = {
  #   my_node_role = {
  #     principal_arn = "arn:aws:iam::123456789012:role/example-role"
  #     type          = "IAM_ROLE"
  #   }
  # }
}

# Fetch cluster auth for kubeconfig (defined in providers.tf)
