class ProjectsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :load_project, :only => [:edit, :update]

  def index
    @projects = Project.access_by(current_user)
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

  def edit
  end

  def update
    if @project.update_attributes(params[:project])
      flash[:notice] = t('flash.projects.update.success')
      redirect_to(project_errors_url(@project))
    else
      render :edit
    end
  end

  private

  def load_project
    @project = Project.find(params[:id])
    render_401 unless @project.admin_member?(current_user)
  end
end
