# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

require "devise/test_helpers"
require 'capybara/rspec'
require 'capybara/rails'
require 'blueprints'

RSpec.configure do |config|
  config.mock_with :mocha
  config.before(:each) do
    MongoMapper.database.collections.each do |coll|
      coll.remove
    end
  end
  config.include Devise::TestHelpers, :type => :controller
end

def response_is_401
  response.status.should == 401
end

def response_is_404
  response.status.should == 404
end