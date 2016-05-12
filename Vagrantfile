# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'etc'
 
Vagrant.configure("2") do |config|
  config.vm.box = "trusty64"
  config.vm.box_url = "https://atlas.hashicorp.com/ubuntu/boxes/trusty64/versions/20160406.0.0/providers/virtualbox.box"
  config.vm.hostname = "gloval-vagrant"
  config.vm.provision "shell", path: "increase_swap.sh"

  # config.vm.provision :shell, :path => "bootstrap.sh", :args => Etc.getlogin
  config.vm.synced_folder ".", "/srv/projects", id: "vagrant-root",
    owner: "vagrant",
    group: "www-data",
    mount_options: ["dmode=775", "fmode=764"], :nfs => ENV.fetch('MTR_VAGRANT_USE_NFS', false)

  # config.vm.network(:private_network, ip: "10.254.254.254") if ENV.fetch('MTR_VAGRANT_USE_NFS', false)
  config.vm.network :forwarded_port, guest: 80, host: 8000       # used by Apache dev server

  config.vm.provider :virtualbox do | vb |
    vb.name = "global-vagrant"
    vb.customize ["modifyvm", :id, "--rtcuseutc", "on"]
    vb.customize ["modifyvm", :id, "--memory", ENV.fetch('MTR_VAGRANT_RAM', 1024)]
    vb.customize ["modifyvm", :id, "--cpus", ENV.fetch('MTR_VAGRANT_CPUS', 1)]
  end
end
