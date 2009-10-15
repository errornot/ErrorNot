class LoggersController < ApplicationController

  def create
    MLogger.create(params[:mlogger])
  end

  def index
    @mloggers = MLogger.all
  end

end
