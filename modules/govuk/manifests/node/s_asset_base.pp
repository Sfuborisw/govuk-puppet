# FIXME: This class needs better documentation as per https://docs.puppetlabs.com/guides/style_guide.html#puppet-doc
class govuk::node::s_asset_base ( $assets_uploads_disk = undef ) inherits govuk::node::s_base{
  include assets::user
  include clamav

  # FIXME remove once cleaned up everywhere
  package { 'tika':
    ensure => purged,
  }
  class { 'govuk_java::oracle7::jdk':
    ensure => absent,
  }

  $directories = [
    '/mnt/uploads',
    '/mnt/uploads/whitehall',
    '/mnt/uploads/whitehall/attachment-cache',
    '/mnt/uploads/whitehall/bulk-upload-zip-file-tmp',
    '/mnt/uploads/whitehall/carrierwave-tmp',
    '/mnt/uploads/whitehall/clean',
    '/mnt/uploads/whitehall/draft-clean',
    '/mnt/uploads/whitehall/draft-incoming',
    '/mnt/uploads/whitehall/draft-infected',
    '/mnt/uploads/whitehall/fatality_notices',
    '/mnt/uploads/whitehall/incoming',
    '/mnt/uploads/whitehall/infected',
  ]

  file { $directories:
    ensure  => directory,
    owner   => 'assets',
    group   => 'assets',
    mode    => '0775',
    purge   => false,
    require => [
      Group['assets'],
      User['assets'],
      Govuk::Mount['/mnt/uploads']
    ],
  }

  file { '/etc/exports':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => '/mnt/uploads     10.0.0.0/8(rw,fsid=0,insecure,no_subtree_check,async,all_squash,anonuid=2900,anongid=2900)',
    require => File['/mnt/uploads'],
    notify  => Service['nfs-kernel-server'],
  }

  ufw::allow { 'Allow all access from backend machines':
    from => '10.3.0.0/16',
  }

  package { 'nfs-kernel-server':
    ensure => installed,
  }

  service { 'nfs-kernel-server':
    ensure    => running,
    hasstatus => true,
    require   => Package['nfs-kernel-server'],
  }

  collectd::plugin { 'nfs':
    require   => Package['nfs-kernel-server'],
  }

  file { '/usr/local/bin/virus_scan.sh':
    source => 'puppet:///modules/govuk/node/s_asset_base/virus_scan.sh',
    mode   => '0755',
  }

  # FIXME remove once cleaned up.
  file { '/usr/local/bin/extract_text_from_files.rb':
    ensure => absent,
  }

  file { '/usr/local/bin/sync-assets.sh':
    source => 'puppet:///modules/govuk/node/s_asset_base/sync-assets.sh',
    mode   => '0755',
  }

  cron { 'tmpreaper-bulk-upload-zip-file-tmp':
    command => '/usr/sbin/tmpreaper -am 24h /mnt/uploads/whitehall/bulk-upload-zip-file-tmp/',
    user    => 'root',
    hour    => 5,
    minute  => 5,
  }
  cron { 'tmpreaper-carrierwave-tmp':
    command => '/usr/sbin/tmpreaper -T300 --mtime 7d /mnt/uploads/whitehall/carrierwave-tmp/',
    user    => 'root',
    hour    => 5,
    minute  => 15,
  }
  cron { 'tmpreaper-attachment-cache':
    command => '/usr/sbin/tmpreaper -T300 --mtime 14d /mnt/uploads/whitehall/attachment-cache/',
    user    => 'root',
    hour    => 5,
    minute  => 25,
  }
}
