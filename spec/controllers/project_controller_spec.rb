require 'spec_helper'

describe ProjectsController do

  describe 'GET #index' do
    it 'should success without project' do
      get :index
      response.should be_success
    end

    it 'should success with a lot of project' do
      2.times { Project.make }
      get :index
      response.should be_success
    end
  end

  describe 'GET #new' do
    it 'should be success' do
      get :new
      response.should be_success
    end
  end

  describe 'POST #create' do
    it 'should be create a project and redirect' do
      lambda do
        post :create, :project => { :name => 'My big project' }
      end.should change(Project, :count)
      response.should redirect_to(projects_path)
      flash[:notice].should == 'Your project is create'
    end

    it 'should not redirect if bad project post' do
      lambda do
        post :create, :project => { :name => '' }
      end.should_not change(Project, :count)
      response.should be_success
    end
  end

end
