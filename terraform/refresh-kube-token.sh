TOKEN=$(ssh t8d@t8d-rpi5-1 sudo kubectl -n kube-system create token terraform-sa)
CA=$(ssh t8d@t8d-rpi5-1 sudo base64 -w 0 /var/lib/rancher/k3s/server/tls/server-ca.crt)

cat > kubeconfig.yaml <<EOF
apiVersion: v1
kind: Config
clusters:
- name: k3s
  cluster:
    server: https://t8d-rpi5-1:6443
    certificate-authority-data: $CA
users:
- name: terraform
  user:
    token: $TOKEN
contexts:
- name: default
  context:
    cluster: k3s
    user: terraform
current-context: default
EOF
