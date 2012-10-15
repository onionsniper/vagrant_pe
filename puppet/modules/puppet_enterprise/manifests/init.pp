# Class: puppet_enterprise
#
# Handles puppet enterprise installation
# Include it to install and run pe
# It defines package, service, main configuration file.
#
#
class puppet_enterprise (
    $isMaster = 'false',
    $master_ip = '127.0.0.1',
    $master_name = 'puppet.localhost',
    $puppet_runinterval ='1800',
) {

    # Load the variables used in this module. Check the params.pp file
    require puppet_enterprise::params

    staging::file { "${puppet_enterprise::params::pe_installer_tarball}":
        source => "puppet:///modules/puppet_enterprise/${puppet_enterprise::params::pe_installer_tarball}",
    }

    staging::extract { "${puppet_enterprise::params::pe_installer_tarball}":
        target  => '/var/tmp',
        require => Staging::File["${puppet_enterprise::params::pe_installer_tarball}"],
    }

    file { 'pe_answers':
        ensure  => present,
        owner   => $puppet_enterprise::params::pe_answers_owner,
        group   => $puppet_enterprise::params::pe_answers_group,
        mode    => $puppet_enterprise::params::pe_answers_mode,
        content => template("puppet_enterprise/${puppet_enterprise::params::pe_answers_file}"),
        path    => $puppet_enterprise::params::pe_answers_path,
        require => File["${staging::path}"],
    }

    exec { 'pe_install_cmd':
        require => [File['pe_answers'], Staging::Extract["${puppet_enterprise::params::pe_installer_tarball}"],],
        unless  => $puppet_enterprise::params::pe_check_installed,
        command => $puppet_enterprise::params::pe_install_cmd,
        timeout => 600,
    }
}
