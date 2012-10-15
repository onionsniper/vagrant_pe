vagrant_pe
==========

Vagrant and Puppet Enterprise

http://vagrantup.com/
http://www.vagrantbox.es/

###############################################################################
# Vagrant installation & setup
###############################################################################

I'm using boxes from Vagrantboxes.es
For the configs here to work, you need to use the same titles as I have.

Install the boxes. At the moment, the Vagrantfile only references 64bit boxes.
Feel free to download others, though.

$ gem install vagrant
$ vagrant box add precise64 http://files.vagrantup.com/precise64.box
$ vagrant box add lucid64 http://files.vagrantup.com/lucid64.box

###############################################################################
# puppet prerequisites
###############################################################################
Add the puppet master to your hosts file:
127.0.0.1       localhost puppet.vagrant                                                                                        
