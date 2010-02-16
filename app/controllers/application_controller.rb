# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # helper :all # include all helpers, all the time
  # We can't use protect_from_forgery because we don't use some data
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  rescue_from Mongo::InvalidObjectID do
    render_404
  end

  rescue_from  MongoMapper::DocumentNotFound do
    render_404
  end

  def render_404
    render :status => 404, :file => Rails.root.join('public/404.html')
  end

  def render_401
    render :status => 401, :file => Rails.root.join('public/404.html')
  end


end
