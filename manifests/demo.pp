class rundeck::demo {
  require rundeck

  $parent_dirs = [
    '/var/rundeck/projects',
    '/var/rundeck/projects/Global',
    '/var/rundeck/projects/Global/etc',
  ]

  file { $parent_dirs:
    ensure => directory,
    owner  => 'rundeck',
    group  => 'rundeck',
    mode   => '0775',
  }

  file { '/var/rundeck/projects/Global/etc/project.properties':
    ensure  => file,
    replace => false,
    owner   => 'rundeck',
    group   => 'rundeck',
    mode    => '0660',
    source  => 'puppet:///modules/rundeck/global.project.properties',
  }
}
