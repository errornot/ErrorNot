class ProjectsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @projects = Project.all
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(params[:project])
    @project.add_admin_member(current_user)
    if @project.save
      flash[:notice] = 'Your project is create'
      redirect_to(project_errors_url(@project))
    else
      render :new
    end
  end
end
