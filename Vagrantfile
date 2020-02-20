# -*- mode: ruby -*-
# vi: set ft=ruby :
iN = 2  # // NUMBER OF VAULT INSTANCES UP TO 9 <= iN > 0
iC = 3  # // NUMBER OF CONSUL INSTANCES UP TO 9 <= iN > 0
sIP_CLASS_D='192.168.77'  # // NETWORK CIDR for Consul configs.
sIPS=''  # // IPs we'll construct based on IP D class + instance number
sVUSER='vagrant'  # // vagrant user
sHOME="/home/#{sVUSER}"  # // home path for vagrant user
sNET='en0: Wi-Fi (Wireless)'  # // network adaptor to use for bridged mdoe
sVADDR='http://127.0.0.1:8200'  # // VAULT_ADDR typically http://127.0.0.1:8500

(1..iC).each do |iY|  # // CONSUL Server Nodes IP's for join (concatenation)
  if iY < iC
     sIPS+="\"#{sIP_CLASS_D}.#{iY}\", "
  else
     sIPS+="\"#{sIP_CLASS_D}.#{iY}\""
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = "debian/buster64"  # // OS
  config.vm.box_version = "10.3.0"  # // OS Version

  config.vm.provider "virtualbox" do |v|
    v.memory = 1536  # // RAM / Memory
    v.cpus = 1  # // CPU Cores / Threads
  end

  # // CONSUL AGENT SCRIPTS to setup
  config.vm.provision "file", source: "2.install_consul.sh", destination: "#{sHOME}/install_consul.sh"
  config.vm.provision "shell", inline: "sed -i 's/\"__IPS-SET__\"/#{sIPS}/g' #{sHOME}/install_consul.sh"

  # // ESSENTIALS PACKAGES INSTALL & SETUP
  config.vm.provision "shell" do |s|
     s.path = "1.install_commons.sh"
  end

  # // CONSUL Server Nodes
  (1..iC).each do |iY|
    config.vm.define vm_name="consul#{iY}" do |consul_node|
      consul_node.vm.hostname = vm_name
      consul_node.vm.network "public_network", bridge: "#{sNET}", ip: "#{sIP_CLASS_D}.#{iY}"
#      vault_node.vm.network "forwarded_port", guest: 80, host: "5818#{iY}", id: "consul#{iY}"
      consul_node.vm.provision "shell", inline: "/bin/bash #{sHOME}/install_consul.sh"
    end
  end

  # // VAULT Server Nodes as Consule Clients as well.
  (1..iN).each do |iX|
    config.vm.define vm_name="vault#{iX}" do |vault_node|
      vault_node.vm.hostname = vm_name
      vault_node.vm.network "public_network", bridge: "#{sNET}", ip: "#{sIP_CLASS_D}.#{254-iX}"
      vault_node.vm.provision "file", source: "3.install_vault.sh", destination: "#{sHOME}/install_vault.sh"
#      vault_node.vm.network "forwarded_port", guest: 80, host: "5818#{iX}", id: "vault#{iX}"
      vault_node.vm.provision "shell", inline: "/bin/bash -c 'SETUP=client #{sHOME}/install_consul.sh'"
      vault_node.vm.provision "shell", inline: "/bin/bash -c '#{sHOME}/install_vault.sh'"
      vault_node.vm.provision "shell", inline: "/bin/bash -c 'if ! grep VAULT_ADDR #{sHOME}/.bashrc ; then printf \"\nexport VAULT_ADDR=#{sVADDR}\n\" >> #{sHOME}/.bashrc ; fi ;'"
#      vault_node.vm.provision "shell", inline: "/bin/bash -c 'if ! grep VAULT_SKIP_VERIFY #{sHOME}/.bashrc ; then printf \"\nexport VAULT_SKIP_VERIFY=true\n\" >> #{sHOME}/.bashrc ; fi ;'"
    end
  end

end
