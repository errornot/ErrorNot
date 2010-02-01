class ErrorsController < ApplicationController

  before_filter :load_project, :only => [:index]

  def index
    @errors = @project.error_reports
  end

  def create
    @project = Project.find(params[:api_key])
    @error = @project.error_reports.build(params[:error])
    if @error.save
      render :status => 200, :text => 'error create'
    else
      render :status => 422, :text => @error.errors.full_messages
    end
  end

  def load_project
    @project = Project.find(params[:project_id])
  end

end
