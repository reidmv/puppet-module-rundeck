# Class to install and configure a basic Rundeck app.
#
# Edit the project.resources.file setting in the relevant
# $RDECK_BASE/projects/[PROJECT-NAME]/etc/project.properties file, and
# set it to "/var/rundeck/resources.yaml"
class rundeck (
  $serverurl = $::hostname,
  $port      = '4440',
) {

  yumrepo { 'rundeck-release-bintray':
    baseurl  => 'http://dl.bintray.com/rundeck/rundeck-rpm',
    descr    => 'Rundeck - Release',
    enabled  => '1',
    gpgcheck => '0',
  }

  package { 'rundeck':
    ensure  => installed,
    before  => Service['rundeck'],
    require => Yumrepo['rundeck-release-bintray'],
  }

  service { 'rundeck':
    ensure  => running,
    enable  => true,
    name    => 'rundeckd',
    require => File['/var/rundeck/resources.yaml'],
  }

  ini_setting { 'rundeck_grails_serverurl':
    ensure  => present,
    path    => '/etc/rundeck/rundeck-config.properties',
    section => '',
    setting => 'grails.serverURL',
    value   => "http://${serverurl}:${port}",
    require => Package['rundeck'],
    notify  => Service['rundeck'],
  }

  file { '/usr/local/bin/puppet-rundeck':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/rundeck/puppet-rundeck',
  }

  file { '/var/rundeck/resources.yaml':
    ensure  => file,
    owner   => 'rundeck',
    group   => 'rundeck',
    mode    => '0600',
    require => Package['rundeck'],
  }

  cron { 'puppet-rundeck':
    ensure  => present,
    command => '/usr/local/bin/puppet-rundeck > /var/rundeck/resources.yaml',
    user    => 'root',
    hour    => '*',
    minute  => [0, 10, 20, 30, 40, 50],
    require => [
      File['/var/rundeck/resources.yaml'],
      File['/usr/local/bin/puppet-rundeck'],
    ],
  }

  exec { 'rundeck-seed-resources.yaml':
    command  => '/usr/local/bin/puppet-rundeck > /var/rundeck/resources.yaml',
    creates  => '/var/rundeck/resources.yaml',
    provider => shell,
    before   => File['/var/rundeck/resources.yaml'],
    require  => File['/usr/local/bin/puppet-rundeck'],
    notify   => Service['rundeck'],
  }

}
