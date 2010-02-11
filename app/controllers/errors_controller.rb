class ErrorsController < ApplicationController

  before_filter :authenticate_user!, :except => [:create]
  before_filter :load_project, :only => [:show, :index, :comment]
  before_filter :load_error, :only => [:update]

  def index
    error_search = {}
    if params.key?(:resolved) && params[:resolved]
      error_search[:resolved] = (params[:resolved] == 'y')
    end
    @errors = @project.error_reports.all(error_search)
  end

  def create
    @project = Project.find(params[:api_key])
    @error = @project.error_with_message_and_backtrace(params[:error][:message],
                                                       params[:error][:backtrace])
    if @error.update_attributes(params[:error])
      render :status => 200, :text => 'error create'
    else
      render :status => 422, :text => @error.errors.full_messages
    end
  end

  def show
    @error = @project.error_reports.find(params[:id])
  end

  def update
    @error.resolved = params[:error][:resolved]
    @error.save
    redirect_to(project_error_path(@error.project, @error))
  end

  def comment
    @error = @project.error_reports.find(params[:id])
    @error.comments.build(:text => params[:text],
                          :user => current_user)
    if @error.save
      flash[:notice] = t('controller.errors.comments.flash.success')
    else
      flash[:notice] = t('controller.errors.comments.flash.failed')
    end
    redirect_to project_error_url(@project, @error)
  end

  private

  def load_project
    @project = Project.find!(params[:project_id])
    render_401 unless @project.member_include?(current_user)
  end

  def load_error
    @error = Error.find(params[:id])
    render_401 unless @error.project.member_include?(current_user)
  end

end
