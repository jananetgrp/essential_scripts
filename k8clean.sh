# Reset the cluster on this node
sudo kubeadm reset

# Purge the kube packages and all associated configuration files
sudo apt-get purge kubeadm kubectl kubelet kubernetes-cni -y

# Remove any unused dependencies that were installed with kubeadm
sudo apt-get autoremove -y

# Remove all remaining Kubernetes directories and files
sudo rm -rf ~/.kube
sudo rm -rf /etc/kubernetes/
sudo rm -rf /etc/cni/
sudo rm -rf /var/lib/etcd
sudo rm -rf /var/lib/kubelet

sudo dpkg --remove --force-remove-reinstreq kubeadm kubectl kubelet kubernetes-cni
sudo rm -rf /opt/containerd
