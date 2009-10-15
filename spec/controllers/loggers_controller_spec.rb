require 'spec_helper'

describe LoggersController do

  it "should use LoggersController" do
    controller.should be_an_instance_of(LoggersController)
  end

  describe 'POST' do
    it 'should create a MLogger' do
      lambda do
        post :create, :m_logger => MLogger.make_unsaved.attributes
      end.should change(MLogger, :count)
    end
  end

  describe 'NEW' do
    before :each do
      get :new
    end

    it { response.should be_success }

  end

  describe 'INDEX' do
    before :each do
      @loggers = 3.of { MLogger.make }
      get :index
    end

    it { response.should be_success }
    it { response.should render_template('index') }
    it 'should get all Logger information' do
      assigns(:mloggers).group_by(&:id).should == @loggers.group_by(&:id)
    end
  end

end
