# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.8"

MOUNT_OPTIONS = if Vagrant::Util::Platform.linux? then
                  ['rw', 'vers=4', 'tcp', 'nolock']
                else
                  ['vers=3', 'udp']
                end
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.synced_folder "~/.aws", "/home/vagrant/.aws"
  config.vm.synced_folder "~/.ivy2", "/home/vagrant/.ivy2"
  config.vm.synced_folder "./", "/vagrant", type: "nfs", mount_options: MOUNT_OPTIONS

  config.vm.provider :virtualbox do |vb|
    vb.memory = 8192
    vb.cpus = 4
  end

  config.vm.network "private_network", ip: ENV.fetch("RV_PRIVATE_IP", "10.10.10.10")

  # Webpack Dev Server
  config.vm.network :forwarded_port, guest: 8284, host: 8284
  # API server
  config.vm.network :forwarded_port, guest: 9000, host: 9000
  # nginx
  config.vm.network :forwarded_port, guest: 9100, host: 9100

  # Change working directory to /vagrant upon session start.
  config.vm.provision "shell", inline: <<SCRIPT
    if ! grep -q "cd /vagrant" "/home/vagrant/.bashrc"; then
      echo "cd /vagrant" >> "/home/vagrant/.bashrc"
    fi
SCRIPT

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "deployment/ansible/pc-demo.yml"
    ansible.galaxy_role_file = "deployment/ansible/roles.yml"
  end
end
