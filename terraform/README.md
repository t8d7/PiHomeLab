# Terraform Kubernetes Configuration

This Terraform configuration manages Kubernetes resources on your Pi cluster after it has been prepared with Ansible.

## Prerequisites

- Kubernetes cluster set up using the Ansible playbook in `../ansible/`
- Terraform 1.0+ installed
- `kubeconfig.yaml` file present (automatically copied by Ansible)

## Quick Start

```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Apply configuration
terraform apply
```

## Configuration Files

- `providers.tf` - Terraform and Kubernetes provider configuration
- `main.tf` - Main Kubernetes resources (deployment, service)
- `variables.tf` - Input variables with defaults
- `outputs.tf` - Output values after apply
- `kubeconfig.yaml` - Kubernetes authentication (created by Ansible)

## Variables

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `k8s_namespace` | Kubernetes namespace | `default` | string |
| `app_name` | Application name | `t8d-webapp` | string |
| `app_image` | Container image | `t8d-webapp-image:latest` | string |
| `app_replicas` | Number of replicas | `3` | number |
| `app_port` | Container port | `3000` | number |
| `service_type` | Service type | `NodePort` | string |
| `node_port` | NodePort number | `30080` | number |

## Usage Examples

### Basic Deployment
```bash
terraform apply
```

### Custom Configuration
```bash
terraform apply \
  -var="app_replicas=5" \
  -var="app_image=myapp:v1.2.0" \
  -var="node_port=30090"
```

### Using Variables File
Create `terraform.tfvars`:
```hcl
app_name = "my-webapp"
app_image = "my-registry/webapp:latest"
app_replicas = 2
service_type = "LoadBalancer"
```

Then apply:
```bash
terraform apply -var-file="terraform.tfvars"
```

## Outputs

After successful apply, Terraform outputs:
- `deployment_name` - Name of the Kubernetes deployment
- `service_name` - Name of the Kubernetes service
- `service_type` - Type of service created
- `node_port` - NodePort for external access (if applicable)
- `cluster_ip` - Internal cluster IP
- `namespace` - Kubernetes namespace used

## Accessing Your Application

### NodePort Service (Default)
Access your application at: `http://<any-node-ip>:30080`

### Port Forward (Development)
```bash
kubectl port-forward service/t8d-webapp 8080:80
# Access at http://localhost:8080
```

## Troubleshooting

### Common Issues

1. **Provider Authentication Failed**
   ```
   Error: Unauthorized
   ```
   - Verify `kubeconfig.yaml` exists and is valid
   - Check if Ansible setup completed successfully
   - Ensure terraform user has proper RBAC permissions

2. **Image Pull Errors**
   ```
   Error: ErrImagePull
   ```
   - Verify the container image exists and is accessible
   - Check image registry authentication if using private registry
   - Update `app_image` variable with correct image name

3. **Port Conflicts**
   ```
   Error: NodePort already in use
   ```
   - Change `node_port` variable to an unused port (30000-32767)
   - Check existing services: `kubectl get svc --all-namespaces`

4. **Resource Constraints**
   ```
   Error: Insufficient resources
   ```
   - Reduce `app_replicas` for resource-constrained clusters
   - Check node resources: `kubectl describe nodes`

### Debugging Commands

```bash
# Check Terraform state
terraform show

# Verify Kubernetes resources
kubectl get deployments,services,pods -n default

# Check pod logs
kubectl logs -l app=t8d-webapp

# Describe resources for detailed info
kubectl describe deployment t8d-webapp
kubectl describe service t8d-webapp
```

## Advanced Configuration

### Multiple Environments
Create environment-specific variable files:

`dev.tfvars`:
```hcl
app_replicas = 1
app_image = "webapp:dev"
node_port = 30081
```

`prod.tfvars`:
```hcl
app_replicas = 5
app_image = "webapp:v1.0.0"
service_type = "LoadBalancer"
```

Apply with:
```bash
terraform apply -var-file="dev.tfvars"
```

### Custom Namespaces
```bash
terraform apply -var="k8s_namespace=my-app"
```

### Health Checks and Probes
The deployment includes:
- Liveness probe on `/` endpoint
- Readiness probe on `/` endpoint
- Rolling update strategy

## Integration with CI/CD

### GitLab CI Example
```yaml
deploy:
  stage: deploy
  script:
    - terraform init
    - terraform apply -auto-approve -var="app_image=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA"
  only:
    - main
```

### GitHub Actions Example
```yaml
- name: Deploy to Kubernetes
  run: |
    terraform init
    terraform apply -auto-approve \
      -var="app_image=ghcr.io/${{ github.repository }}:${{ github.sha }}"
```

## Security Best Practices

1. **Least Privilege**: Consider creating more restrictive RBAC instead of cluster-admin
2. **Secret Management**: Use Kubernetes secrets for sensitive data
3. **Network Policies**: Implement network policies for pod-to-pod communication
4. **Image Security**: Use specific image tags, not `latest`
5. **Resource Limits**: Set resource requests and limits

## Cleanup

To remove all resources:
```bash
terraform destroy
```

This will remove the Kubernetes deployment and service but leave the cluster intact.
