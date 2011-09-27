require 'spec_helper'

describe SameErrorsController do

  render_views

  before do
    @user = make_user
    @project = make_project_with_admin(@user)
    2.of {
      error = Factory(:error, :project => @project, :resolved => true)
      add_embedded_error(error)
      error.save
    }
    @project.reload
  end

  describe 'with an anonymous user' do
    it 'should not access to see an error' do
      get :show, :project_id => @project.id,
        :error_id => @project.error_reports.first.id,
        :id => @project.error_reports.first.same_errors.first.id
      response.should redirect_to(new_user_session_path)
    end
  end

  describe 'with a user logged' do
    before :each do
      sign_in @user
    end
    describe 'GET show' do
      it 'should see an error' do

        error = @project.error_reports.first
        get :show, :project_id => @project.id,
          :error_id => error.id,
          :id => error.same_errors.first.id
        response.should be_success
      end

      it 'should not see an error in a project where user is not member' do
        project = Factory(:project)
        error = Factory(:error, :project => project)
        add_embedded_error(error)
        get :show, :project_id => project.id,
          :error_id => error.id,
          :id => error.same_errors.first.id
        response_is_401
      end

    end
  end

end
