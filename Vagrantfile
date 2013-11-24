Vagrant.configure("2") do |config|
  config.vm.box = "centos64-x64-minimal"
  config.vm.provision :shell, :path => "cookbooks/build-httpd/install.sh"
  config.vm.provision :shell, :path => "cookbooks/build-php/install.sh"
  config.vm.provision :shell, :path => "cookbooks/build-xdebug/install.sh"
  config.vm.provision :shell, :path => "cookbooks/build-mongodb/install.sh"
end
