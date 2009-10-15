require 'spec_helper'

describe LoggersController do

  it "should use LoggersController" do
    controller.should be_an_instance_of(LoggersController)
  end

  describe 'POST' do
    it 'should create a MLogger' do
      lambda do
        post :create, :mlogger => MLogger.make_unsaved.attributes
      end.should change(MLogger, :count)
    end

  end

end
