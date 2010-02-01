require 'spec_helper'

describe ErrorsController do

  integrate_views

  describe 'GET #index' do
    before do
      @project = Project.make
    end
    it 'should render 404 if bad project_id' do
      get :index, :project_id => '123'
      response.code.should == "404"
    end

    it 'should works if no errors on this project' do
      get :index, :project_id => @project.id
      response.should be_success
    end

    it 'should works if several errors on this project' do
      2.times { Error.make(:project => @project) }
      get :index, :project_id => @project.id
      response.should be_success
    end
  end

end
