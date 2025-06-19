require 'yaml'
require 'active_record'

require_relative '../app'  

ENV['RACK_ENV'] ||= 'development'

db_config = YAML.load_file(File.expand_path('../../config/database.yml', __FILE__), aliases: true)
ActiveRecord::Base.establish_connection(db_config[ENV['RACK_ENV']])

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

end
