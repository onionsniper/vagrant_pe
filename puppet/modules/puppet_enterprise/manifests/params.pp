# Class: puppet_enterprise::params
# Defines parameters for the puppet enterprise module

class puppet_enterprise::params {

    $pe_installer_owner = 'root'
    $pe_installer_group = 'root'
    $pe_installer_mode  = '0755'
    $pe_installer_dir = $::operatingsystem ? {
        /(CentOS|RedHat|Scientific)/ => $::operatingsystemrelease ? {
            /^5.\d+$/ => $::architecture ? {
                x86_64  => 'puppet-enterprise-2.5.3-el-5-x86_64',
                default => undef,
            },
            /^6.\d+$/ => $::architecture ? {
                x86_64  => 'puppet-enterprise-2.5.3-el-6-x86_64',
                default => undef,
            },
            default => undef,
        },
        ubuntu => $::operatingsystemrelease ? {
            /10.04/   => $::architecture ? {
                amd64 => 'puppet-enterprise-2.5.3-ubuntu-10.04-amd64',
                default => undef,
            },
            /12.04/   => $::architecture ? {
                amd64 => 'puppet-enterprise-2.5.3-ubuntu-12.04-amd64',
                default => undef,
            },
            default => undef,
        },
        default => undef,
    }

    $pe_installer_tarball = "${pe_installer_dir}.tar.gz"

    $pe_install_path    = "${dropdir}/${pe_installer_dir}"

    if $puppet_enterprise::isMaster == 'false' {
      $pe_answers_file = 'node_answerfile.erb'
    }
    else {
      $pe_answers_file = 'master_answerfile.erb'
    }

    $pe_answers_owner   = 'root'
    $pe_answers_group   = 'root'
    $pe_answers_mode    = '0600'
    $pe_answers_path    = "${staging::path}/pe_installer_answer_file"

    $pe_install_cmd     = "${staging::path}/${pe_installer_dir}/puppet-enterprise-installer -a ${pe_answers_path}"
    $pe_check_installed = '/usr/bin/dpkg -s pe-puppet-enterprise-release > /dev/null 2>&1'
}
