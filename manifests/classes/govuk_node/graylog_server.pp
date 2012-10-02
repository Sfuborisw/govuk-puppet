class govuk_node::graylog_server inherits govuk_node::base {
  include elasticsearch
  include nagios::client
  include nginx

  if $::govuk_provider == 'sky' {
    $es_heap_size = '8g'
  } else {
    $es_heap_size = '4g'
  }

  class { 'logstash::server':
    es_heap_size => $es_heap_size,
  }

  case $::govuk_provider {
    sky: {
      nginx::config::vhost::proxy {
        "logging":
          to      => ['localhost:9292'],
          aliases => ["graylog.*"],
      }
    }
    default: {
      nginx::config::vhost::proxy {
        "logging.${::govuk_platform}.alphagov.co.uk":
          to      => ['localhost:9292'],
          aliases => ["graylog.${::govuk_platform}.alphagov.co.uk"],
      }
    }
  }
}
