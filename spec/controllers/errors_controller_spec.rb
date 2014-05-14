require 'spec_helper'

describe ErrorsController do

  render_views

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

  shared_examples_for 'POST #create' do
    it 'should success with a good request' do
      lambda do
        post :create, error_request(@project.api_key)
      end.should change(Error, :count)
      response.should be_success
    end

    it 'should send an email the first time' do
      Error.any_instance.expects(:send_notify_task)
      post :create, error_request(@project.api_key)
      response.should be_success
    end

    it 'should not send an email at the second same request' do
      Error.any_instance.expects(:send_notify_task).once()
      req = error_request(@project.api_key)
      (1..2).each do
        post :create, req
        response.should be_success
      end
    end

    it 'should send an email when error marked as solved and reraised' do
      req = error_request(@project.api_key)
      err = @resolveds.first
      req['error']['backtrace'] = err.backtrace
      req['error']['message'] = err.message
      Error.any_instance.expects(:send_notify_task).once()
      post :create, req
      response.should be_success
    end

    it 'should render 404 if bad API_KEY' do
      post :create, error_request("4b72f1b3ac2a926c98000002")
      response.code.should == "404"
    end

    it 'should render 422 if avoid raised_at' do
      post :create, error_request(@project.api_key, :raised_at => nil)
      response.code.should == "422"
      response.body.should == "Raised at can't be blank"
    end
  end


  describe 'with an anonymous user' do
    it_should_behave_like 'POST #create'

    it 'should not access to see an error' do
      get :show, :project_id => @project.id, :id => @resolveds.first.id
      response.should redirect_to(new_user_session_path)
    end

    it 'should not access to see all errors' do
      get :index, :project_id => @project.id
      response.should redirect_to(new_user_session_path)
    end

    it 'should not update an error' do
      put :update, :id => @un_resolveds.first.id, :error => {:resolved => true}
      response.should redirect_to(new_user_session_path)
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
        response.status.should == 401
      end

    end

    describe 'GET #index' do
      it 'should render 404 if bad project_id' do
        get :index, :project_id => '123'
        response.code.should == "404"
      end

      it 'should works if no errors on this project' do
        @project.error_reports = []
        get :index, :project_id => @project.id
        response.should be_success
        assert_equal @project.error_reports.all(:sort => [[:raised_at, -1]]).map(&:id), assigns[:errors].map(&:id)
      end

      it 'should works if several errors on this project' do
        2.times { Factory(:error, :project => @project) }
        get :index, :project_id => @project.id
        response.should be_success
      end

      it 'should limit to resolved errors if resolved=y params send' do
        get :index, :project_id => @project.id, :resolved => 'y'
        @resolveds.should =~ assigns[:errors]
      end

      it 'should limit to un_resolved errors if resolved=n params send' do
        get :index, :project_id => @project.id, :resolved => 'n'
        @un_resolveds.should =~ assigns[:errors]
      end

      it 'should not limit to resolved errors if resolved= with empty value params send' do
        get :index, :project_id => @project.id, :resolved => nil
        @project.error_reports.should =~ assigns[:errors]
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

      describe "Sorted" do
        before do
          @project.error_reports = []
          make_error_with_data(:count => 9,
                               :nb_comments => 5,
                               :project => @project,
                               :resolved => true,
                               :raised_at => 2.days.ago)
          make_error_with_data(:count => 3,
                               :nb_comments => 7, :project => @project, :resolved => false, :raised_at => 4.days.ago)
          make_error_with_data(:count => 5,
                               :nb_comments => 2, :project => @project, :resolved => false, :raised_at => 1.days.ago)
          @project.reload
        end

        [:nb_comments, :count, :last_raised_at].each do |sorted_by|
          it "should return errors sorted  by #{sorted_by}" do
            get :index, :project_id => @project.id.to_s, :sort_by => sorted_by.to_s, :resolved => 'a' # by default asc_order -1
            assert_equal @project.error_reports.sort_by(&sorted_by).reverse.map(&:id), assigns[:errors].map(&:id)
          end

          it "should return errors sorted  by #{sorted_by} ascending order" do
            get :index, :project_id => @project.id.to_s, :sort_by => sorted_by.to_s, :asc_order => 1, :resolved => 'a'
            assert_equal @project.error_reports.sort_by(&sorted_by).map(&:id), assigns[:errors].map(&:id)
          end
        end
      end

    end

    describe 'PUT update' do
      it 'should mark resolved an error and should not call send_notify_task' do
        error = @un_resolveds.first
        Error.any_instance.expects(:send_notify_task).never
        put :update, :id => error.id, :error => {:resolved => true}
        response.should redirect_to(project_error_path(@project, error))
        assert error.reload.resolved
      end

      it 'should mark un_resolved an error and should not call send_notify_task' do
        error = @resolveds.first
        Error.any_instance.expects(:send_notify_task).never
        put :update, :id => error.id, :error => {:resolved => false}
        response.should redirect_to(project_error_path(@project, error))
        assert !error.reload.resolved
      end

      it 'should not update an error in project where user is not member' do
        project = Factory(:project)
        error = Factory(:error, :project => project)
        put :update, :id => error.id, :error => {:resolved => true}
        response.status.should == 401
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

      it 'should increment nb_comments' do
        @error = @project.error_reports.first
        lambda do
          post :comment,
            :project_id => @project.id,
            :id => @error.id,
            :text => 'foo'
          @error.reload
        end.should change(@error, :nb_comments).by(1)
      end
    end

  end



end
