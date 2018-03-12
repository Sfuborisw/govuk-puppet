# == Class: govuk::apps::government_frontend
#
# Government Frontend is an app to serve content pages form the content store
#
# === Parameters
#
# [*vhost*]
#   Virtual host used by the application.
#   Default: 'datagovuk_find'
#
# [*port*]
#   What port should the app run on?
#
# [*sentry_dsn*]
#   The URL used by Sentry to report exceptions
#
# [*secret_key_base*]
#   The key for Rails to use when signing/encrypting sessions.
#
class govuk::apps::datagovuk_find(
  $vhost = 'datagovuk_find',
  $port = '3215',
  $sentry_dsn = undef,
  $secret_key_base = undef,
) {
  Govuk::App::Envvar {
    app => 'government-frontend',
  }

  if $secret_key_base != undef {
    govuk::app::envvar { "${title}-SECRET_KEY_BASE":
      varname => 'SECRET_KEY_BASE',
      value   => $secret_key_base,
    }
  }
  govuk::app { 'datagovuk_find':
    app_type              => 'rack',
    port                  => $port,
    sentry_dsn            => $sentry_dsn,
    vhost_ssl_only        => true,
    health_check_path     => '/healthcheck',
    asset_pipeline        => true,
    asset_pipeline_prefix => 'datagovuk_find',
    vhost                 => $vhost,
  }
}
