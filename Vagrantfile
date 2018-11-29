# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "u1and0/archlinux"
  config.vm.box_version = "1.0.1"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 22, host: 2222, id: "ssh", auto_correct: true
  config.vm.network "forwarded_port", guest: 8888, host: 8888,  auto_correct: true

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.synced_folder "~", "/home/u1and0", owner: "vagrant", group: "vagrant"
  config.vm.synced_folder "~/Dropbox", "/home/vagrant/Dropbox", owner: "vagrant", group: "vagrant"
  config.vm.synced_folder "~/BoxSync", "/home/vagrant/BoxSync", owner: "vagrant", group: "vagrant"
  config.vm.synced_folder "~/Data", "/home/vagrant/Data", owner: "vagrant", group: "vagrant"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    # クリップボードの共有: 双方向
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
  end

  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Cach plugin
  # `vagrant plugin install vagrant-cachier`
  # packageのキャッシュをディスクに保存
  # 次回vagrant up時にpackage更新が早い
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.enable :pacman
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # run as root=>True, run as user=>False
  config.vm.provision :shell, :path => "bootstrap.sh", :privileged => false
  config.vm.provision "shell", inline: <<-SHELL
    ln -fs /home/{u1and0,vagrant}/.zsh_history
    ln -fs /home/{u1and0,vagrant}/yankring_history_v2.txt
    ln -fs /home/{u1and0,vagrant}/.fasd
  SHELL
  config.ssh.insert_key=false  # root user ssh for sharing with windows machine
end
