# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # helper :all # include all helpers, all the time
  # We can't use protect_from_forgery because we don't use some data
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_filter :check_application

  def check_application
    authenticate_or_request_with_http_basic do |user_name, password|
      @api_key = user_name
      user_name == password
    end
  end

end
