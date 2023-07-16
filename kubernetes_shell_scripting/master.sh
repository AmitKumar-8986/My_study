echo "#### Common Installation script ######"
echo "##### Execute on Manager and worker nodes also ####"
sleep 5
sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
###Enable br_netfilter kernel module
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
touch /etc/sysctl.d/k8s.conf
echo 'net.bridge.bridge-nf-call-ip6tables = 1' > /etc/sysctl.d/k8s.conf
echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.d/k8s.conf
###Disable Swap
swapoff -a
###remove swap entry from /etc/fstab
sed -i '/swap/d' /etc/fstab
###Install Docker
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
##Start and enable docker service
systemctl start docker
systemctl enable docker
###Add kubernetes repository
cd /etc/yum.repos.d
touch kubernetes.repo
echo '[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg' > kubernetes.repo
yum install kubeadm kubectl kubelet -y
##start and enable kubelet service
systemctl start kubelet
systemctl enable kubelet
containerd config default | tee /etc/containerd/config.toml
sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" /etc/containerd/config.toml 
service containerd restart
service kubelet restart
echo "Adding Firewall Rules"
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload
sleep 3s
echo "#######Installation completed successfully #####"
echo "Creating Token for worker node"
kubeadm init
sleep 10s
touch /root/join-token
chmod u+x /root/join-token
nano /root/join-token
sleep 15s
read  -p "How many worker nodes want to create:" choice
i=1
while [ $i -le $choice ]; do
	read  -p "Please enter the ip:" ip
	scp /root/worker-kube.sh $ip:/root/
	ssh root@$ip "./worker-kube.sh" > /dev/null
	sleep 15s
	scp /root/join-token $ip:/root/
	ssh root@$ip "./join-token" > /dev/null
	((i++))
done
sleep 5s
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export kubever=$(kubectl version | base64 | tr -d '\n')
sleep 180s
echo "####### Clustering is DONE!!!! ######"
kubectl get pods --all-namespaces
kubectl get nodes
sleep 5s
#echo "####### Scanning and Hardening Start ######"
#sh /root/zephyrus.sh
