# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
  config.before(:each) do
    MongoMapper.database.collections.each do |coll|
      coll.remove
    end
  end
end

require 'blueprints'

require "devise/test_helpers"
class ActionController::TestCase
  include Devise::TestHelpers
end

class BSON::ObjectID
  def <=>(object)
    self.to_s <=> object.to_s
  end
end

def response_is_401
  response.status.should == "401 Unauthorized"
end

def response_is_404
  response.code.should == "404"
end