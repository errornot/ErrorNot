class ErrorsController < ApplicationController

  before_filter :load_project, :only => [:show,:index]

  def index
    error_search = {}
    if params.key?(:resolved) && params[:resolved]
      error_search[:resolved] = (params[:resolved] == 'y')
    end
    @errors = @project.error_reports.all(error_search)
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

  def show
    @error = @project.error_reports.find(params[:id])
  end

  private

  def load_project
    @project = Project.find(params[:project_id])
  end

end
