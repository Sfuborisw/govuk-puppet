# == Class: mongodb::server
#
# Setup a MongoDB server.
#
# === Parameters:
#
# [*version*]
# [*package_name*]
# [*replicaset*]
# [*dbpath*]
#
# [*development*]
#   Create a non-replSet node with journalling disabled and query profiling
#   enabled. Saves space at the expense of data integrity.
#   Default: false
#
class mongodb::server (
  $version,
  $package_name = 'mongodb-10gen',
  $replicaset = $govuk_platform,
  $dbpath = '/var/lib/mongodb',
  $development = false
) {
  validate_bool($development)

  $logpath = '/var/log/mongodb/mongod.log'

  anchor { 'mongodb::begin':
    before => Class['mongodb::repository'],
    notify => Class['mongodb::service'];
  }

  class { 'mongodb::repository': }

  class { 'mongodb::package':
    version      => $version,
    package_name => $package_name,
    require      => Class['mongodb::repository'],
    notify       => Class['mongodb::service'];
  }

  class { 'mongodb::config':
    replicaset  => $replicaset,
    dbpath      => $dbpath,
    logpath     => $logpath,
    development => $development,
    require     => Class['mongodb::package'],
    notify      => Class['mongodb::service'];
  }

  class { 'mongodb::logging':
    logpath => $logpath,
    require => Class['mongodb::config'],
  }

  class { 'mongodb::firewall':
    require => Class['mongodb::config'],
  }

  class { 'mongodb::service':
    require => Class['mongodb::logging'],
  }

  class { 'mongodb::monitoring':
    dbpath  => $dbpath,
    require => Class['mongodb::service'],
  }

  class { 'collectd::plugin::mongodb':
    require => Class['mongodb::config'],
  }

  # We don't need to wait for the monitoring class
  anchor { 'mongodb::end':
    require => Class[
      'mongodb::firewall',
      'mongodb::service'
    ],
  }
}
