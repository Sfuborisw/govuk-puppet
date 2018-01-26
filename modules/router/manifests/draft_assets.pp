# = Class: router::draft_assets
#
# Configure vhost for serving draft assets.
#
# === Parameters
#
# [*real_ip_header*]
#   Uses the Nginx realip module (http://nginx.org/en/docs/http/ngx_http_realip_module.html)
#   to change the client IP address to the one in the specified HTTP header.
#
# [*vhost_name*]
#   Primary vhost for draft assets
#

class router::draft_assets(
  $real_ip_header = '',
  $vhost_name = 'draft-assets',
) {
    $enable_ssl = hiera('nginx_enable_ssl', true)

    if $::aws_migration {
    $app_domain = hiera('app_domain_internal')
    $upstream_ssl = true
  } else {
    $app_domain = hiera('app_domain')
    $upstream_ssl = $enable_ssl
  }

  nginx::config::site { 'draft-assets':
    content => template('router/draft-assets.conf.erb'),
  }
}
