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
    @project = Project.make
  end

  describe 'GET #index' do
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

  describe 'POST #create' do
    it 'should success with a good request' do
      lambda do
        post :create, error_request(@project.id.to_s)
      end.should change(Error, :count)
      response.should be_success
    end

    it 'should render 404 if bad API_KEY' do
      post :create, error_request("123")
      response.code.should == "404"
    end

    it 'should render 422 if avoid raised_at' do
      post :create, error_request(@project.id.to_s, :raised_at => nil)
      response.code.should == "422"
      response.body.should == "Raised at can't be empty"
    end
  end

end
