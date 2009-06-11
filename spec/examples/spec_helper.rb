require 'rubygems'
require 'spec'

RAILS_ENV = ENV['RAILS_ENV'] ||= 'test'
require File.join(File.dirname(__FILE__), '..', 'mock_app', 'config', 'environment.rb')

require 'spec/rails'

stdout = $stdout
$stdout = StringIO.new
ActiveRecord::Migrator.migrate(File.join(File.dirname(__FILE__), '..', '..', 'migrations'))
ActiveRecord::Migrator.migrate(File.join(File.dirname(__FILE__), '..', 'mock_app', 'db', 'migrate'))
$stdout = stdout

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
end

def stop_time!(now = Time.now)
  Time.stub!(:now).and_return(now)
  Time.zone.stub!(:now).and_return(now.in_time_zone(Time.zone))
end
