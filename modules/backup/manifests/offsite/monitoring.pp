class backup::offsite::monitoring {

  $offsite_fqdn = 'offsite-backup.production.alphagov.co.uk'
  $offsite_hostname = 'offsite-backup'

  icinga::host { $offsite_fqdn:
    hostalias => $offsite_fqdn,
    address   => $offsite_fqdn,
  }

  icinga::check { "check_disk_${offsite_hostname}":
    check_command       => 'check_nrpe_1arg!check_xvda1',
    service_description => 'high disk usage',
    use                 => 'govuk_high_priority',
    host_name           => $offsite_fqdn,
  }

  icinga::check { "check_ssh_${offsite_hostname}":
    check_command       => 'check_ssh',
    use                 => 'govuk_high_priority',
    service_description => 'unable to ssh',
    host_name           => $offsite_fqdn,
  }

}
