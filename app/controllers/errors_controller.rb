class ErrorsController < ApplicationController

  before_filter :authenticate_user!, :except => [:create]
  before_filter :load_project, :only => [:show, :index, :comment, :backtrace, :request_info, :session_info, :data, :similar_error]
  before_filter :load_error, :only => [:update]
  before_filter :check_api_key, :only => [:create]

  def index
    params[:per_page] ||= 10
    params[:resolved] = 'a' unless params.key?(:resolved)
    @errors = @project.paginate_errors_with_search(params)
  end

  def create
    @error = @project.error_with_message_and_backtrace(params[:error][:message],
                                                       params[:error][:backtrace])
    if @error.update_attributes(params[:error])
      render :status => 200, :text => 'error create'
    else
      render :status => 422, :text => @error.errors.full_messages.first
    end
  end

  def show
    @root_error = @error = @project.error_reports.find(params[:id])
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

  [:backtrace, :request_info, :session_info, :data, :similar_error].each do |resum|
    define_method(resum) do
      @root_error = @error = @project.error_reports.find(params[:id])
    end
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

  def check_api_key
    @project = Project.first({:api_key => params[:api_key]})
    render(:status => 404, :text => 'Bad API key') unless @project
  end

end
