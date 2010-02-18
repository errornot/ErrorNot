class ProjectsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :load_project, :only => [:edit, :update, :add_member, :leave, :destroy, :reset_apikey]
  before_filter :project_admin, :only => [:edit, :update, :add_member, :destroy, :reset_apikey]

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

  def add_member
    @project.add_member_by_email(params[:email])
    flash[:notice] = t('flash.projects.add_member.success')
    redirect_to edit_project_url(@project)
  end

  def leave
    if request.delete?
      # delete member of this project
      if !@project.admin_member?(current_user) &&
        @project.remove_member!(current_user)
        flash[:notice] = t('flash.projects.leave.success',
                           :project_name => @project.name)
      else
        flash[:notice] = t('flash.projects.leave.refused')
      end
      redirect_to projects_url
      return
    end
  end

  def reset_apikey
    if request.put?
      @project.gen_api_key!
      redirect_to edit_project_url(@project)
    end
  end

  def destroy
    @project.destroy
    flash[:notice] = t('flash.projects.destroy.notice', :default => 'Project was successfully destroyed.')
    redirect_to projects_url
  end

  private

  def load_project
    @project = Project.find(params[:id])
  end

  def project_admin
    render_401 unless @project.admin_member?(current_user)
  end
end
