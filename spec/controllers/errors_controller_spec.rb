require 'spec_helper'

describe ErrorsController do

  integrate_views

  def error_request(api_key, hash={})
    {'api_key' => api_key,
    'version' => '0.1.0',
    'error' => {'message' => /\w+/.gen,
      'raised_at' => hash.key?(:raised_at) ? hash[:raised_at] : 2.days.ago,
      'backtrace' => 3.of { /\w+ \w+ \w+/.gen },
      'request' => {
        'rails_root' => '/path/to/project',
        'url' => 'http://localhost/failure?id=123',
        'params' => {
          'action' => 'index',
          'id' => '123',
          'controller' => 'groups'}},
      'environment' => {
        'SERVER_NAME' => 'localhost',
        'HTTP_ACCEPT_ENCODING' => 'gzip,deflate',
        'HTTP_USER_AGENT' => 'Mozilla/5.0',
        'PATH_INFO' =>  '/',
        'HTTP_ACCEPT_LANGUAGE' => 'en-us,en;q=0.5',
        'HTTP_HOST' => 'localhost'},
      'data' => {}}}
  end

  before do
    @user = make_user
    @project = make_project_with_admin(@user)
    @resolveds = 2.of { Factory(:error, :project => @project, :resolved => true) }
    @un_resolveds = 2.of { Factory(:error, :project => @project, :resolved => false) }
  end

  describe 'POST #create', :shared => true do
    it 'should success with a good request' do
      lambda do
        post :create, error_request(@project.api_key)
      end.should change(Error, :count)
      response.should be_success
    end

    it 'should render 404 if bad API_KEY' do
      post :create, error_request("4b72f1b3ac2a926c98000002")
      response.code.should == "404"
    end

    it 'should render 422 if avoid raised_at' do
      post :create, error_request(@project.api_key, :raised_at => nil)
      response.code.should == "422"
      response.body.should == "Raised at can't be empty"
    end
  end


  describe 'with an anonymous user' do
    it_should_behave_like 'POST #create'

    it 'should not access to see an error' do
      get :show, :project_id => @project.id, :id => @resolveds.first.id
      response.should redirect_to(new_user_session_path('unauthenticated' => true))
    end

    it 'should not access to see all errors' do
      get :index, :project_id => @project.id
      response.should redirect_to(new_user_session_path('unauthenticated' => true))
    end

    it 'should not update an error' do
      put :update, :id => @un_resolveds.first.id, :error => {:resolved => true}
      response.should redirect_to(new_user_session_path('unauthenticated' => true))
    end
  end

  describe 'with a user logged' do
    before :each do
      sign_in @user
    end
    it_should_behave_like 'POST #create'

    describe 'GET show' do
      it 'should see an error' do
        get :show, :project_id => @project.id, :id => @project.error_reports.first.id
        response.should be_success
      end

      it 'should not see an error in a project where user is not member' do
        project = Factory(:project)
        error = Factory(:error, :project => project)
        get :show, :project_id => project.id, :id => error.id
        response.status.should == "401 Unauthorized"
      end

    end

    describe 'GET #index' do
      it 'should render 404 if bad project_id' do
        get :index, :project_id => '123'
        response.code.should == "404"
      end

      it 'should works if no errors on this project' do
        get :index, :project_id => @project.id
        response.should be_success
        assert_equal @project.error_reports, assigns[:errors]
      end

      it 'should works if several errors on this project' do
        2.times { Factory(:error, :project => @project) }
        get :index, :project_id => @project.id
        response.should be_success
      end

      it 'should limit to resolved errors if resolved=y params send' do
        get :index, :project_id => @project.id, :resolved => 'y'
        assert_equal @resolveds.map(&:id).sort, assigns[:errors].map(&:id).sort
      end

      it 'should limit to un_resolved errors if resolved=n params send' do
        get :index, :project_id => @project.id, :resolved => 'n'
        assert_equal @un_resolveds.map(&:id).sort, assigns[:errors].map(&:id).sort
      end

      it 'should not limit to resolved errors if resolved= with empty value params send' do
        get :index, :project_id => @project.id, :resolved => nil
        assert_equal @project.error_reports.map(&:id).sort, assigns[:errors].map(&:id).sort
      end

      it 'should limit to errors having one of the given search word in their keywords' do
        word = 'someVeryUniqueWord'
        message = "toto #{word} titi"
        error = Factory(:error, :project => @project, :message => message)
        error.reload
        get :index, :project_id => @project.id, :resolved => nil, :search => word
        response.should be_success
        assigns[:errors].should == [error]
      end

      it "should return no errors if words doesn't exist" do
        Factory(:error, :project => @project)
        get :index, :project_id => @project.id, :resolved => nil, :search => "Nonexistent666666"
        response.should be_success
        assert_equal assigns[:errors].map(&:id).length, 0
      end

    end

    describe 'PUT update' do
      it 'should mark resolved an error' do
        error = @un_resolveds.first
        put :update, :id => error.id, :error => {:resolved => true}
        response.should redirect_to(project_error_path(@project, error))
        assert error.reload.resolved
      end

      it 'should mark un_resolved an error' do
        error = @resolveds.first
        put :update, :id => error.id, :error => {:resolved => false}
        response.should redirect_to(project_error_path(@project, error))
        assert !error.reload.resolved
      end

      it 'should not update an error in project where user is not member' do
        project = Factory(:project)
        error = Factory(:error, :project => project)
        put :update, :id => error.id, :error => {:resolved => true}
        response.status.should == '401 Unauthorized'
      end
    end

    describe 'POST #comment' do
      it 'should create a comment on error' do
        @error = @project.error_reports.first
        lambda do
          post :comment,
            :project_id => @project.id,
            :id => @error.id,
            :text => 'foo'
          @error.reload
        end.should change(@error.reload.comments, :size)
        response.should redirect_to(project_error_url(@project, @error))
        flash[:notice].should == I18n.t('controller.errors.comments.flash.success')
      end

      it 'should not create empty create on error' do
        @error = @project.error_reports.first
        lambda do
          post :comment,
            :project_id => @project.id,
            :id => @error.id,
            :text => ''
        end.should_not change(@error.comments, :size)
        response.should redirect_to(project_error_url(@project, @error))
        flash[:notice].should == I18n.t('controller.errors.comments.flash.failed')
      end
    end

  end



end
