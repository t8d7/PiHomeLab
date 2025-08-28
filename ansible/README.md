# Kubernetes Cluster Setup with Ansible

This Ansible configuration prepares a Raspberry Pi cluster for Kubernetes and configures it for Terraform management.

## Prerequisites

- Raspberry Pi cluster with Ubuntu Server 20.04+ or Raspberry Pi OS
- SSH access to all nodes with sudo privileges
- Ansible 2.9+ installed on control machine
- Python 3.6+ on all target nodes

## Quick Start

1. **Update inventory**: Edit `inventory/hosts.yml` with your Pi IP addresses
2. **Configure SSH**: Ensure SSH key-based authentication is set up
3. **Run the playbook**:
   ```bash
   cd ansible
   ansible-playbook playbooks/k8s-prep.yml
   ```

## Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── inventory/
│   └── hosts.yml           # Inventory with Pi cluster details
├── group_vars/
│   ├── all.yml             # Global variables
│   ├── k8s_masters.yml     # Master node variables
│   └── k8s_workers.yml     # Worker node variables
├── playbooks/
│   ├── k8s-prep.yml        # Main playbook
│   ├── tasks/              # Task files
│   └── templates/          # Jinja2 templates
└── README.md
```

## Configuration

### Inventory Setup

Edit `inventory/hosts.yml` to match your cluster:

```yaml
k8s_masters:
  hosts:
    pi-master-01:
      ansible_host: 192.168.1.100  # Your master Pi IP
k8s_workers:
  hosts:
    pi-worker-01:
      ansible_host: 192.168.1.101  # Your worker Pi IPs
    pi-worker-02:
      ansible_host: 192.168.1.102
```

### Variables

Key variables in `group_vars/all.yml`:
- `k8s_version`: Kubernetes version (default: "1.28")
- `container_runtime`: Container runtime (default: "containerd")
- `pod_network_cidr`: Pod network CIDR (default: "10.244.0.0/16")
- `cni_plugin`: CNI plugin (default: "flannel")

## What the Playbook Does

### System Preparation
- Updates packages and installs dependencies
- Disables swap permanently
- Configures kernel modules and sysctl parameters
- Sets up NTP for time synchronization

### Container Runtime
- Installs and configures containerd
- Sets up systemd cgroup driver
- Configures Docker repository for containerd

### Kubernetes Installation
- Adds Kubernetes repository
- Installs kubelet, kubeadm, kubectl
- Holds packages at current version
- Configures kubelet

### Master Node Setup
- Initializes Kubernetes cluster with kubeadm
- Configures kubeconfig for admin access
- Generates join command for worker nodes
- Installs Flannel CNI plugin

### Worker Node Setup
- Joins worker nodes to the cluster
- Applies node labels and taints

### Terraform Prerequisites
- Creates dedicated terraform user
- Sets up service account with cluster-admin permissions
- Generates kubeconfig for Terraform provider
- Copies kubeconfig to terraform directory

## Usage

### Full Cluster Setup
```bash
# Run complete setup
ansible-playbook playbooks/k8s-prep.yml

# Run specific sections
ansible-playbook playbooks/k8s-prep.yml --tags system-prep
ansible-playbook playbooks/k8s-prep.yml --tags k8s-install
```

### Verification
```bash
# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces

# Verify Terraform setup
kubectl get serviceaccount terraform -n kube-system
```

### Troubleshooting

**Common Issues:**

1. **SSH Connection Failed**
   - Verify SSH keys are properly configured
   - Check firewall settings on Pi nodes

2. **Kubernetes Init Failed**
   - Ensure swap is disabled: `sudo swapoff -a`
   - Check system resources and network connectivity

3. **Worker Nodes Not Joining**
   - Verify join command in `k8s-join-command.sh`
   - Check network connectivity between nodes

4. **CNI Plugin Issues**
   - Verify pod network CIDR doesn't conflict with node network
   - Check Flannel pod status: `kubectl get pods -n kube-flannel`

## Integration with Terraform

After running this playbook:

1. The `kubeconfig.yaml` file will be copied to `../terraform/`
2. Terraform can now manage Kubernetes resources
3. Use the terraform configuration in the `terraform/` directory

```bash
cd ../terraform
terraform init
terraform plan
terraform apply
```

## Security Considerations

- The terraform user has cluster-admin privileges
- Kubeconfig files contain sensitive authentication data
- Consider using more restrictive RBAC for production environments
- Regularly rotate service account tokens

## Customization

### Adding Custom Tasks
Create new task files in `playbooks/tasks/` and include them in the main playbook.

### Modifying CNI Plugin
To use a different CNI plugin, update the `cni_plugin` variable and modify `tasks/network-plugin.yml`.

### Additional Node Configuration
Add custom configurations in the respective group_vars files or create new task files.
