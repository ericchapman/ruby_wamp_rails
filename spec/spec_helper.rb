require 'simplecov'
SimpleCov.start do
  add_filter 'spec/'
end

require_relative '../lib/wamp_rails'

require 'wamp_rails'

Dir[File.expand_path('spec/support/**/*.rb')].each { |f| require f }
