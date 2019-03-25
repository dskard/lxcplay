# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.define "lxdhost" do |instance|
        instance.vm.box = "bento/ubuntu-18.04"

        instance.vm.hostname = "lxdhost"

        instance.vm.network "private_network", ip: "192.168.225.20"

        instance.vm.provider :virtualbox do |v|
            v.customize [ "modifyvm", :id, "--memory", "1024" ]
        end

        scripts = [
            "provision/setup_lxd_host.sh",
        ]

        scripts.each do |script|
            instance.vm.provision :shell, :path => script
        end
    end

end

# -*- mode: ruby -*-
# vi: set ft=ruby :
