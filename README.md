# requirements:
brew install terraform
brew install ansible

# terraform the base cluster
./create_cluster.sh

# provision base systems using ansible
cd ansible
./run_playbook.sh

# connect to bastion host and get kubernetes cluster set up
ssh -F ssh.cfg illume-bastion
./00_rke_up.sh
./01_taint_control_nodes.sh
kubectl create -f 02_nvidia-device-plugin.yml
./03_taint_gpu_nodes.sh
./04_label_kube-system_namespace.sh
kubectl create -f 05_illume-namespace.yml
kubectl create -f 06_allow-namespace-illume.yml
kubectl create -f 07_allow-dns-access.yml
kubectl create -f 08_allow-public-internet.yml
kubectl create -f 09_rook-operator.yaml
./10_wait_for_operator.sh
./11_label_storage_nodes.sh
kubectl create -f 12_rook-cluster.yml
./13_wait_for_rook-cluster.sh
kubectl create -f 14_storage_pool_and_class.yml

kubectl create -f 15_rook-tools.yml
kubectl -n rook exec -it rook-tools bash
rookctl status
ceph df
rados df
exit
kubectl delete -f 15_rook-tools.yml

kubectl create -f 16_example-ubuntu-host.yml
kubectl -n illume get pods
