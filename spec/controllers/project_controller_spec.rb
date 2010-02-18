require 'spec_helper'

describe ProjectsController do

  integrate_views

  describe 'with an anonymous user' do
    it 'should not see index' do
      get :index
      response.should redirect_to(new_user_session_path('unauthenticated' => true))
    end
    it 'should not see show' do
      get :show, :id => Factory(:project).id
      response.should redirect_to(new_user_session_path('unauthenticated' => true))
    end
    it 'should not can create project' do
      post :create, :project => { :name => 'My big project' }
      response.should redirect_to(new_user_session_path('unauthenticated' => true))
    end
    it 'should not can edit a project' do
      get :edit, :id => Factory(:project).id.to_s
      response.should redirect_to(new_user_session_path('unauthenticated' => true))
    end
    it 'should not be able to reset the key api of a project' do
      put :reset_apikey, :id => Factory(:project).id
      response.should redirect_to(new_user_session_path('unauthenticated' => true))
    end
  end

  describe 'with a user logged' do
    before do
      @user = make_user
      sign_in @user
    end

    describe 'GET #index' do
      it 'should success without project' do
        get :index
        response.should be_success
      end

      it 'should success with a lot of project' do
        2.times { Factory(:project) }
        get :index
        response.should be_success
      end

      it 'should see his project only' do
        user_project = make_project_with_admin(@user)
        non_user_project = Factory(:project)
        get :index
        assert_equal [user_project], assigns[:projects]
      end
    end

    describe 'GET #new' do
      it 'should be success' do
        get :new
        response.should be_success
      end
    end

    describe 'POST #create' do
      it 'should be create a project and redirect to errors on this project' do
        lambda do
          post :create, :project => { :name => 'My big project' }
        end.should change(Project, :count)
        response.should redirect_to(project_errors_path(Project.last(:order => 'created_at')))
        flash[:notice].should == 'Your project is create'
      end

      it 'should not redirect if bad project post' do
        lambda do
          post :create, :project => { :name => '' }
        end.should_not change(Project, :count)
        response.should be_success
      end
    end

    describe 'GET #edit' do
      it 'should edit a project where user is admin' do
        project = make_project_with_admin(@user)
        get :edit, :id => project.id.to_s
        response.should be_success
      end

      it 'should not edit a project where user is not admin' do
        project = make_project_with_admin(Factory(:user))
        get :edit, :id => project.id.to_s
        response_is_401
      end
    end

    describe 'PUT #update' do
      it 'should update project name if user is admin on this project' do
        project = make_project_with_admin(@user)
        put :update, :project => {:name => 'foo'}, :id => project.id
        response.should redirect_to(project_errors_url(project))
        project.reload.name.should == 'foo'
      end

      it 'should not update project name if user is not admin on this project' do
        project = make_project_with_admin(Factory(:user))
        put :update, :project => {:name => 'foo'}, :id => project.id
        response_is_401
        project.reload.name.should_not == 'foo'
      end
    end

    describe 'PUT #add_member' do
      it 'should redirect_to edit with flash[:notice] if user is admin of project' do
        project = make_project_with_admin(@user)
        put :add_member, :email => 'foo@bar.com', :id => project.id.to_s
        response.should redirect_to(edit_project_url(project))
        flash[:notice].should == I18n.t('flash.projects.add_member.success')
      end

      it 'should not add member in project because user is not admin on this project' do
        project = make_project_with_admin(Factory(:user))
        put :add_member, :email => 'foo@bar.com', :id => project.id.to_s
        response_is_401
      end
    end

    describe 'GET #leave' do
      describe 'user admin on this project' do
        it 'should not see a form because admin' do
          project = make_project_with_admin(@user)
          get :leave, :id => project.id.to_s
          response.should be_success
          response.should_not have_tag('form')
        end
      end
      describe 'user not admin on this project' do
        it 'should see a form' do
          project = make_project_with_admin(make_user)
          get :leave, :id => project.id.to_s
          response.should be_success
          response.should have_tag('form')
        end
      end
    end

    describe 'PUT #leave' do
      describe 'user admin on this project' do
        it 'should not leave this project' do
          project = make_project_with_admin(@user)
          lambda do
            delete :leave, :id => project.id.to_s
          end.should_not change(project.members, :count).by(-1)
          response.should redirect_to(projects_url)
        end
      end
      describe 'user not admin on this project' do
        it 'should leave this project' do
          project = saved_project_with_admins_and_users([make_user], [@user])
          lambda do
            delete :leave, :id => project.id.to_s
            project.reload
          end.should change(project.reload.members, :size).by(-1)
          response.should redirect_to(projects_url)
        end
      end
    end

    describe 'PUT #reset_apikey' do
      describe 'user admin on this project' do
        it 'should reset the key api' do
          project = make_project_with_admin(@user)
          lambda do
            put :reset_apikey, :id => project.id.to_s
            project.reload
          end.should change(project, :api_key)
        end
      end
      describe 'user not admin on this project' do
        it 'should not reset the key api' do
          project = make_project_with_admin(make_user)
          lambda do
            put :reset_apikey, :id => project.id.to_s
            project.reload
          end.should_not change(project, :api_key)
        end
      end
    end

    describe 'DELETE #destroy' do
      
      describe 'with the logged-in user admin on the project' do
        it 'should delete the project' do
          project = saved_project_with_admins_and_users([@user], [make_user])
          lambda do
            delete :destroy, :id => project.id
          end.should change(Project, :count).by(-1)
          Project.find(project.id).should be_nil
          response.should redirect_to(projects_url)
        end
      end
      describe 'with another user admin on the project' do
        it 'should delete the project anyway' do
          project = saved_project_with_admins_and_users([@user, make_user], [make_user])
          lambda do
            delete :destroy, :id => project.id
          end.should change(Project, :count).by(-1)
          Project.find(project.id).should be_nil
          response.should redirect_to(projects_url)
        end
      end
      describe 'with the logged-in user not admin on the project' do
        it 'should not destroy the project' do
          project = saved_project_with_admins_and_users([make_user], [@user])
          lambda do
            delete :destroy, :id => project.id
          end.should change(Project, :count).by(0)
          Project.find(project.id).should be
          response.code.should eql '401'
        end
      end
    end

  end

end
