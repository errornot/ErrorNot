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

    it 'should render status 201 if log create' do
      post :create, :m_logger => MLogger.make_unsaved.attributes
      response.code.should == "201"
    end

    it 'should render status 400' do
      post :create, :m_logger => {:severity => 'ok'}
      response.code.should == "400"
    end
  end

  describe 'NEW' do
    before :each do
      get :new
    end

    it { response.should be_success }

  end

  describe 'INDEX' do
    describe 'without argument' do
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

    describe 'like search' do
      before :each do
        @criticals = 3.of { MLogger.make(:severity => MLogger::CRITICAL) }
        @errors = 3.of { MLogger.make(:severity => MLogger::ERROR) }
        @warnings = 3.of { MLogger.make(:severity => MLogger::WARNING) }
        @infos = 3.of { MLogger.make(:severity => MLogger::INFO) }
      end

      it 'should limit to only critical' do
        get :index, :severity => 0
        assigns(:mloggers).group_by(&:id).should == @criticals.group_by(&:id)
      end

      it 'should limit to criticals and errors' do
        get :index, :severity => [0,1]
        assigns(:mloggers).map(&:id).sort.should == (@criticals + @errors).map(&:id).sort
      end

      it 'should get no result if bad argument' do
        get :index, :error_args => 'foo'
        assigns(:mloggers).should == []
      end
    end
  end

end
