class LoggersController < ApplicationController

  def create
    MLogger.create(params[:mlogger])
  end

end
