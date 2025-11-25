# Terraform: Shakespeare Service on AWS EKS

This directory contains Terraform configuration to provision a minimal EKS cluster on AWS, along with ECR for container images.

## Prerequisites

1. **AWS Account** with appropriate credentials configured locally:
   ```bash
   aws configure
   # or set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN env vars
   ```

2. **Terraform** (>= 1.0):
   ```bash
   terraform version
   ```

3. **kubectl** (>= 1.20):
   ```bash
   kubectl version --client
   ```

4. **Docker** (to build and push images to ECR):
   ```bash
   docker --version
   ```

## Quick Start

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

This downloads required providers and modules.

### 2. Create Variables File

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars if you want to customize region, cluster name, node size, etc.
```

### 3. Plan

```bash
terraform plan -out=tfplan
```

Review the resources that will be created. For a minimal dev cluster, expect:
- VPC with public/private subnets across 2 AZs
- EKS cluster (managed Kubernetes control plane)
- 2 worker nodes (t3.small) in the managed node group
- 1 NAT gateway (optional; for private subnet outbound traffic)
- ECR repository for `lookup` image
- Security groups and IAM roles

**Cost estimate (ballpark, us-east-1):**
- 2 × t3.small on-demand: ~$0.04/hour each = ~$0.08/hour (~$60/month)
- EKS control plane: ~$0.10/hour (~$73/month)
- NAT gateway: ~$0.045/hour (~$32/month)
- **Total ~$165/month** for this minimal setup

### 4. Apply

```bash
terraform apply tfplan
```

This takes ~15–20 minutes. Once complete, you'll see outputs with cluster details and a `configure_kubectl` command.

### 5. Configure kubectl

After Terraform completes, run the output command:

```bash
aws eks update-kubeconfig --region us-east-1 --name ws-eks
```

Verify cluster access:

```bash
kubectl cluster-info
kubectl get nodes
```

## Building and Pushing the Image to ECR

Once the ECR repository is provisioned, build and push your Flask app:

### 1. Get ECR Repository URL

From Terraform output or AWS console:

```bash
aws ecr describe-repositories --repository-names lookup --region us-east-1 \
  --query 'repositories[0].repositoryUri' --output text
# Example output: 123456789012.dkr.ecr.us-east-1.amazonaws.com/lookup
```

### 2. Authenticate Docker to ECR

```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
```

### 3. Build and Tag

```bash
cd ../batch
docker build -t lookup-image:latest .
docker tag lookup-image:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/lookup:latest
```

### 4. Push

```bash
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/lookup:latest
```

### 5. Update Deployment YAML

Edit `kubernetes/deployment.yaml` and update the `image` field:

```yaml
      containers:
      - name: lookup-container
        image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/lookup:latest
        imagePullPolicy: IfNotPresent
        # ... rest of container spec
```

## Deploying Your Service

Once the image is in ECR and your kubeconfig is configured:

```bash
# Create the namespace
kubectl create namespace ws

# Apply Kubernetes manifests
kubectl apply -f ../kubernetes/service.yaml -n ws
kubectl apply -f ../kubernetes/deployment.yaml -n ws

# Verify
kubectl get pods -n ws
kubectl get svc -n ws
```

If the service is `type: LoadBalancer`, get the external IP:

```bash
kubectl get svc -n ws lookup-service -w
```

Once the `EXTERNAL-IP` is assigned, test:

```bash
curl http://<EXTERNAL-IP>/
curl "http://<EXTERNAL-IP>/lookup?word=the"
```

## Useful Commands

### View Outputs

```bash
terraform output
```

### Destroy (cleanup when done learning)

```bash
terraform destroy
```

**Warning:** This will delete the cluster and all resources. Make sure you're done with it first.

### Update Cluster

To scale nodes or change versions:

```bash
# Update terraform.tfvars
vim terraform.tfvars

# Plan and apply
terraform plan -out=tfplan
terraform apply tfplan
```

### Access Cluster Logs

EKS logs are sent to CloudWatch. View in AWS Console or via CLI:

```bash
aws logs describe-log-groups --region us-east-1 | \
  grep /aws/eks/ws-eks
```

## State Management

By default, Terraform state is stored locally in `.terraform/` and `terraform.tfstate*` files. For team collaboration or CI/CD, configure an S3 backend:

Uncomment the backend block in `providers.tf`, create an S3 bucket and DynamoDB table, then:

```bash
terraform init
```

Terraform will prompt you to migrate state to S3.

## Security Notes

- **Secrets**: The `imagePullSecrets` in Kubernetes manifests are not needed if nodes have IAM role with ECR read permissions (they do, by default).
- **Ingress**: For production, use an Ingress with AWS ALB. Install the AWS Load Balancer Controller helm chart.
- **RBAC**: By default, `aws-auth` ConfigMap allows cluster creator full access. Add additional IAM users/roles via `aws_auth_roles` and `aws_auth_users` variables.
- **Network Policy**: Consider adding Calico or Cilium for network policies in production.

## Next Steps

1. Deploy monitoring (Prometheus, CloudWatch Container Insights)
2. Set up autoscaling (HPA, Cluster Autoscaler)
3. Configure DNS with Route 53
4. Add CI/CD pipeline (GitHub Actions, GitLab CI, etc.)
5. Set up observability (ELK, Datadog, New Relic)

Enjoy your SRE learning journey!
