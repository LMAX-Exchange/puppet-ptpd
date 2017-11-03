source ENV['GEM_SOURCE'] || "https://rubygems.org"

def location_for(place, fake_version = nil)
  if place =~ /^(git[:@][^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

group :development, :unit_tests do
  gem 'json',                                                       :require => false
  gem 'puppet-lint-absolute_classname-check',                       :require => false
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check',  :require => false
  gem 'puppet-lint-leading_zero-check',                             :require => false
  gem 'puppet-lint-trailing_comma-check',                           :require => false
  gem 'puppet-lint-unquoted_string-check',                          :require => false
  gem 'puppet-lint-version_comparison-check',                       :require => false
  gem 'puppet_facts',                                               :require => false
  gem 'rspec-puppet-facts',                                         :require => false
  gem 'rspec-puppet-utils',                                         :require => false
  gem 'rspec-puppet', '>= 2.5.0',                                   :require => false
  gem 'simplecov',                                                  :require => false
  gem 'simplecov-console', '~> 0.4',                                :require => false if RUBY_VERSION.to_f >= 2.0
  gem 'simplecov-console', '0.3.1',                                 :require => false if RUBY_VERSION.to_f <= 1.9
  gem 'metadata-json-lint', '1.2.2',                                :require => false if RUBY_VERSION.to_f == 2.1
  gem 'metadata-json-lint', '1.1.0',                                :require => false if RUBY_VERSION.to_f <= 1.9
  gem 'rake', '< 11',                                               :require => false
  gem 'rspec', '< 3.2.0',                                           :require => false
  gem 'syck',                                                       :require => false if RUBY_VERSION.to_f >= 2.2
  gem 'rubocop', '0.33.0',                                          :require => false if RUBY_VERSION.to_f >= 1.9
  gem 'rubocop', '<= 0.5.0',                                        :require => false if RUBY_VERSION.to_f < 1.9
  gem 'i18n', '0.6.0',                                              :require => false if RUBY_VERSION.to_f < 1.9
  gem 'nokogiri', '1.6.8.1',                                        :require => false if RUBY_VERSION.to_f == 1.9
  gem 'nokogiri', '1.5.11',                                         :require => false if RUBY_VERSION.to_f < 1.9
  gem 'mime-types', '1.25.1',                                       :require => false if RUBY_VERSION.to_f <= 1.8
  gem 'mime-types', '2.99.3',                                       :require => false if RUBY_VERSION.to_f <= 1.9
  gem 'hocon', '0.1.0',                                             :require => false if RUBY_VERSION.to_f < 1.9
  gem 'addressable', '<= 2.3.8',                                    :require => false if RUBY_VERSION.to_f < 2.0
  gem 'hitimes', '<= 1.2.1',                                        :require => false if RUBY_VERSION.to_f < 1.9
  gem 'celluloid', '<= 0.10.0',                                     :require => false if RUBY_VERSION.to_f < 1.9
  gem 'highline', '<= 1.6.21',                                      :require => false if RUBY_VERSION.to_f < 1.9
  gem 'rest-client', '<= 1.6.9',                                    :require => false if RUBY_VERSION.to_f < 1.9
  gem 'json_pure', '<= 1.8.3',                                      :require => false if RUBY_VERSION.to_f < 1.9
  gem 'retriable', '<= 1.4.1',                                      :require => false if RUBY_VERSION.to_f < 1.9
  gem 'rainbow', '<= 1.99.2',                                       :require => false if RUBY_VERSION.to_f < 1.9
  gem 'tins', '<= 1.6.0',                                           :require => false if RUBY_VERSION.to_f < 1.9
  gem 'listen', '<= 3.0.7',                                         :require => false if RUBY_VERSION.to_f == 2.1
  gem 'listen', '<= 3.0.7',                                         :require => false if RUBY_VERSION.to_f == 2.0
  gem 'listen', '<= 3.0.7',                                         :require => false if RUBY_VERSION.to_f == 1.9
  gem 'listen', '<= 2.7.1',                                         :require => false if RUBY_VERSION.to_f < 1.9
  gem 'json_pure', '<= 1.8.3',                                      :require => false if RUBY_VERSION.to_f <= 1.9
  gem 'net-http-persistent', '<= 2.9.4',                            :require => false if RUBY_VERSION.to_f  < 2.1
  gem 'term-ansicolor', '<= 1.3.2',                                 :require => false if RUBY_VERSION.to_f < 1.9
  gem 'public_suffix', '<= 1.4.6',                                  :require => false if RUBY_VERSION.to_f == 1.9
  gem 'public_suffix', '<= 1.3.3',                                  :require => false if RUBY_VERSION.to_f < 1.9
  gem 'faraday', '<= 0.9.2',                                        :require => false if RUBY_VERSION.to_f < 1.9
  gem 'semantic_puppet', '<= 0.1.3',                                :require => false if RUBY_VERSION.to_f < 1.9
  gem 'semantic_puppet', '>= 1.0.0',                                :require => false if RUBY_VERSION.to_f >= 1.9
  gem 'puppetlabs_spec_helper',                                     :require => false if RUBY_VERSION.to_f >= 1.9
  gem 'puppetlabs_spec_helper', '<= 1.2.2',                         :require => false if RUBY_VERSION.to_f < 1.9
  gem 'parallel_tests', '>= 2.14.1',                                :require => false if RUBY_VERSION.to_f >= 2.0
  gem 'parallel_tests', '2.9.0',                                    :require => false if RUBY_VERSION.to_f == 1.9
  gem 'parallel_tests', '1.0.9',                                    :require => false if RUBY_VERSION.to_f == 1.8
  gem 'parallel', '1.3.3.1',                                        :require => false if RUBY_VERSION.to_f <= 1.8
  gem 'jwt',                                                        :require => false if RUBY_VERSION.to_f > 1.9
  gem 'jwt', '1.5.6',                                               :require => false if RUBY_VERSION.to_f <= 1.9
  gem 'google-api-client', '0.9.4',                                 :require => false if RUBY_VERSION.to_f <= 1.9
  gem 'net-ssh', '2.9.4',                                           :require => false if RUBY_VERSION.to_f <= 1.9
  gem 'beaker', '2.52.0',                                           :require => false if RUBY_VERSION.to_f <= 2.2
end

group :system_tests do
  if beaker_version = ENV['BEAKER_VERSION']
    gem 'beaker', *location_for(beaker_version)
  end
  if beaker_rspec_version = ENV['BEAKER_RSPEC_VERSION']
    gem 'beaker-rspec', *location_for(beaker_rspec_version)
  else
    gem 'beaker-rspec',  :require => false
  end
  gem 'serverspec',                    :require => false
  gem 'beaker-puppet_install_helper',  :require => false
end



if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', '~> 3.8', :require => false
end

# vim:ft=ruby
