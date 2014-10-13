require 'csv'
require 'rspec-puppet'
require 'puppet'
require 'hiera-puppet-helper'

# For testing functions.
require 'puppetlabs_spec_helper/module_spec_helper'

HERE = File.expand_path(File.dirname(__FILE__))

class Puppet::Resource
  # If you test a class which has a default parameter, but don't
  # explicitly pass the parameter in, puppet explodes because it tries
  # to automatically inject parameter values from hiera and gets
  # confused due to hiera-puppet-helper's antics. This monkey patch
  # disables automatic parameter injection to stop that happening.
  # TODO: perhaps push this upstream to hiera-puppet-helper?
  def lookup_external_default_for(param, scope)
    nil
  end
end

RSpec.configure do |c|
  c.mock_framework = :rspec

  c.manifest    = File.join(HERE, 'manifests', 'site.pp')
  c.module_path = [
    File.join(HERE, 'modules'),
    File.join(HERE, 'vendor', 'modules')
  ].join(':')

  c.order = 'rand'

  # Sensible defaults to satisfy modules that perform OS checking. These
  # keys can be overridden by more specific `let(:facts)` in spec contexts.
  c.default_facts = {
    :osfamily                => 'Debian',
    :operatingsystem         => 'Ubuntu',
    :operatingsystemrelease  => '12.04',
    :lsbdistid               => 'Debian',
    :lsbdistcodename         => 'Precise',
  }

end
