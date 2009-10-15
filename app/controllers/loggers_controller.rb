class LoggersController < ApplicationController

  def new
    @mlogger = MLogger.new
  end

  def create
    @mlogger = MLogger.new(params[:m_logger])
    if @mlogger.save
      render :text => 'ok'
    else
      render :new
    end
  end

  def index
    @mloggers = MLogger.all
  end

end
