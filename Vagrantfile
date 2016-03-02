# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'etc'
 
Vagrant.configure("2") do |config|
  config.vm.box = "trusty64"
  config.vm.box_url = "https://atlas.hashicorp.com/ubuntu/boxes/trusty64/versions/20160222.0.0/providers/virtualbox.box"
  config.vm.hostname = "global-vagrant"

  # config.vm.provision :shell, :path => "bootstrap.sh", :args => Etc.getlogin
  config.vm.synced_folder ".", "/srv/projects", :nfs => ENV.fetch('MTR_VAGRANT_USE_NFS', false)

  # config.vm.network(:private_network, ip: "10.254.254.254") if ENV.fetch('MTR_VAGRANT_USE_NFS', false)
    config.vm.network :forwarded_port, guest: 80, host: 8000       # used by Apache dev server
  # config.vm.network :forwarded_port, guest: 9000, host: 9000       # used by Xdebug
  #config.vm.network :forwarded_port, guest: 3306, host: 3308       # used by MySQL dev server

  config.vm.provider :virtualbox do | vb |
    vb.name = "global-vagrant"
    vb.customize ["modifyvm", :id, "--rtcuseutc", "on"]
    vb.customize ["modifyvm", :id, "--memory", ENV.fetch('MTR_VAGRANT_RAM', 1024)]
    vb.customize ["modifyvm", :id, "--cpus", ENV.fetch('MTR_VAGRANT_CPUS', 1)]
  end
end

