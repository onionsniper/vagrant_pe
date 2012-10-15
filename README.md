Set up Vagrant for testing & developing Puppet Enterprise

Grab Vagrant from http://vagrantup.com/
Grab other base boxes from http://www.vagrantbox.es/

I'm using boxes from Vagrantboxes.es 
For the configs here to work, you need to use the same titles as I have.

Install the software and the boxes.
At the moment, the Vagrantfile only references 64bit boxes. Feel free to download others, though. 
$ gem install vagrant
$ vagrant box add precise64 http://files.vagrantup.com/precise64.box
$ vagrant box add lucid64 http://files.vagrantup.com/lucid64.box       

Make sure you've set up your machine to access git. Follow the instructions in the Client set-up section of the Development page.

Create an area to run Vagrant from, and check out the Vagrant Puppet Enterprise configuration & code from git:
$ mkdir /Users/someuser/vagrant
$ cd /Users/someuser/vagrant
$ git clone gitserver:/srv/git/vagrant_pe.git

We don't store the actual tar files distributed by puppet in git. There is, however, a script to download them in git. Let's run it:
$ pwd
/Users/someuser/vagrant
$ cd vagrant_pe/puppet/modules/puppet_enterprise/files
$ ls -1
download.pe.files
$ bash download.pe.files 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0 74.0M    0  666k    0     0   219k      0  0:05:45  0:00:03  0:05:42  275k

Once this completes:
$ ls -1
download.pe.files
puppet-enterprise-2.5.3-el-5-x86_64.tar.gz
puppet-enterprise-2.5.3-el-6-x86_64.tar.gz
puppet-enterprise-2.5.3-ubuntu-10.04-amd64.tar.gz
puppet-enterprise-2.5.3-ubuntu-12.04-amd64.tar.gz

Now you've got all the code, and the Puppet Enterprise installers, to build a virtual PE dev environment.

Start up your boxes
Change back to the directory with the Vagrantfile and check the status of your boxes:
$ pwd
/Users/someuser/vagrant/vagrant_pe
$ vagrant status
Current VM states:

precise_node             not created
lucid_node               not created
precise_master           not created

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.

Start the puppet master

First, we're going to start the master. When we start the node, it's going to try to register itself to the master, so that's why we need the master up first:
$ vagrant up precise_master
[precise_master] Importing base box 'precise64'...
Followed by a lot of information. Once you see this:
[precise_master] Booting VM...
[precise_master] Waiting for VM to boot. This can take a few minutes.
[precise_master] VM booted and ready for use!
You can actually ssh into the box. But the box isn't fully configured yet. You'll see more text - the output of the initial Puppet run. Vagrant comes with a local copy of Puppet (2.7.x). We use this local Puppet to install Puppet Enterprise.

Once the box is booted, it takes about 5 minutes to complete the PE installation. You will see the following (and be returned to a command prompt) when the process is complete:
notice: /Stage[main]/Puppet_enterprise/Exec[pe_install_cmd]/returns: executed successfully
notice: Finished catalog run in 214.18 seconds

If you run vagrant status you should see that precise_master is now in a running state.

You can ssh into the box via the command vagrant ssh precise_master. You'll be in the box as the vagrant user. You can use sudo su - to become root. You should see a lot of processes if you run ps -ef | grep puppet.

Since this box is the puppet master, it's obviously running the PE Dashboard. We'll want to access it from our local machine. Add the following to your hosts file:
127.0.0.1 localhost puppet.vagrant

You can now access your own Dashboard via https://puppet.vagrant:3000
The default username & password are root@localhost.localdomain and tgTiN76ZQpie6kcU

You'll notice, on the left, that there are no nodes...

Start the puppet node

Just as before, start it up and wait for it to complete. It should be a bit quicker as the PE installer is quicker for a node than a master.

$ vagrant up precise_node
[precise_node] Importing base box 'precise64'...

As before, vagrant status should show the new box as running.

If you ssh into the box (vagrant ssh precise_node, you should only see puppet agent and mcollectived processes, instead of all the others you saw on the precise_master.

Let's ssh over to precise_master. We should see a puppet certificate waiting to be signed.

$ vagrant ssh precise_master
Welcome to Ubuntu 12.04 LTS (GNU/Linux 3.2.0-23-generic x86_64)
$ sudo su - 
# puppet cert list
  "precise-node.internal.somedomain.com" (8B:D6:4B:5B:56:D4:FE:BA:62:90:3F:3C:92:07:9B:84)
# puppet cert list
  "precise-node.internal.somedomain.com" (8B:D6:4B:5B:56:D4:FE:BA:62:90:3F:3C:92:07:9B:84)
# puppet cert sign precise-node.internal.somedomain.com
notice: Signed certificate request for precise-node.internal.somedomain.com
notice: Removing file Puppet::SSL::CertificateRequest precise-node.internal.somedomain.com at '/etc/puppetlabs/puppet/ssl/ca/requests/precise-node.internal.somedomain.com.pem'


Bug Workaround
There is a bug in the current PE installer that does not set the port correctly on the reporturl in the puppet config file. You need to manually update it on the puppet master:
In the file /etc/puppetlabs/puppet/puppet.conf under the [master] settings,
Change this line:
reporturl = https://localhost:/reports/upload
To read as this:
reporturl = https://localhost:3000/reports/upload
Bug Workaround


We could wait for 30 minutes for the node to do a puppet run, or we can kick it off manually:
vagrant@precise-node:~$ sudo puppet agent --test
info: Retrieving plugin
info: Loading facts in /var/opt/lib/pe-puppet/lib/facter/facter_dot_d.rb
info: Loading facts in /var/opt/lib/pe-puppet/lib/facter/root_home.rb
info: Loading facts in /var/opt/lib/pe-puppet/lib/facter/puppet_vardir.rb
info: Caching catalog for precise-node.internal.somedomain.com
info: Applying configuration version '1350081352'
notice: Finished catalog run in 0.05 seconds


Once again, check out https://puppet.vagrant:3000 and you should see your new node in the list!