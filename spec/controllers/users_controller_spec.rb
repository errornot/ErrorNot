
require 'spec_helper'

describe UsersController do

  integrate_views

  describe 'with anonymous user' do
    describe 'GET #new' do
      it 'should success' do
        get :new
        response.should be_success
      end
      it 'should fill email if email send by argument' do
        get :new, :email => 'foo@example.com'
        response.body.should have_tag('input[type=?][value=?]', 'text', 'foo@example.com')
      end
    end
  end

  describe 'with user logged' do
    before do
      @user = make_user
      @project = make_project_with_admin(@user)
      sign_in @user
    end

    describe 'GET #edit' do
      it 'should success' do
        get :edit
        response.should be_success
      end
    end

    describe 'POST #create' do
      it 'should redirect_to sign_in because user not verify' do
        post :create, :user => {:email => 'errornot@example.com',
          :password => 'tintinpouet',
          :password_confirmation => 'tintinpouet'}
        response.should redirect_to(new_user_session_url)
      end
    end

    describe 'PUT #update_notify' do
      describe 'update notify' do

        it 'should add project in notify because not before' do
          member = @project.member(@user)
          member.notify_by_email = false
          member.save
          assert !@project.reload.member(@user).notify_by_email?
          put :update_notify, 
              :project_notify_by_email => [@project.id.to_s],
              :project_notify_removal_by_email => [@project.id.to_s]
          response.should redirect_to(edit_user_path)
          assert @project.reload.member(@user).notify_by_email?
          assert @project.reload.member(@user).notify_removal_by_email?
        end

        it 'should not change notify to project already into before' do
          assert @project.reload.member(@user).notify_by_email?
          assert @project.reload.member(@user).notify_removal_by_email?
          put :update_notify, 
              :project_notify_by_email => [@project.id.to_s],
              :project_notify_removal_by_email => [@project.id.to_s]
          response.should redirect_to(edit_user_path)
          assert @project.reload.member(@user).notify_by_email?
          assert @project.reload.member(@user).notify_removal_by_email?
        end

        it 'should extract notify_by_email if project where user is member is not in project_notify_by_email params' do
          assert @project.reload.member(@user).notify_by_email?
          assert @project.reload.member(@user).notify_removal_by_email?
          put :update_notify
          response.should redirect_to(edit_user_path)
          assert !@project.reload.member(@user).notify_by_email?
          assert !@project.reload.member(@user).notify_removal_by_email?
        end

      end
    end
  end
end
