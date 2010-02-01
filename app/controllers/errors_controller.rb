class ErrorsController < ApplicationController

  before_filter :load_project

  def index
    @errors = @project.errors
  end

  def load_project
    @project = Project.find(params[:project_id])
  end

end
