require File.dirname(__FILE__) + '/../spec_helper'

describe MLogger do

  describe "Valication" do
    it 'should have valid factory' do
      MLogger.make_unsaved.should be_valid
    end

    it 'should not valid if no application name' do
      MLogger.make_unsaved(:application => '').should_not be_valid
    end

    it 'should not valid if no composant' do
      MLogger.make_unsaved(:composant => '').should_not be_valid
    end

    it 'should not valid if no message' do
      MLogger.make_unsaved(:message => '').should_not be_valid
    end

    it 'should not valid if no severity' do
      MLogger.make_unsaved(:severity => '').should_not be_valid
    end

    it 'should not valid if severity is not an integer' do
      MLogger.make_unsaved(:severity => 'fatal').should_not be_valid
    end

    it 'should not valid if severity is not an integer in 0..5' do
      MLogger.make_unsaved(:severity => 6).should_not be_valid
    end
  end

  describe '#search_by_params' do
    before(:each) do
      @criticals = 3.of { MLogger.make(:severity => MLogger::CRITICAL) }
      @errors = 3.of { MLogger.make(:severity => MLogger::ERROR) }
      @warnings = 3.of { MLogger.make(:severity => MLogger::WARNING) }
      @infos = 3.of { MLogger.make(:severity => MLogger::INFO) }
      @alls = @criticals + @errors + @warnings + @infos
    end

    it 'should get all logger if no params' do
      MLogger.search_by_params({}).map(&:id).sort.should == @alls.map(&:id).sort
    end

    it 'should get all critical logger if params with {:severity => 0}' do
      MLogger.search_by_params({:severity => 0}).map(&:id).sort.should == @criticals.map(&:id).sort
    end

    it 'should get all critical and errors logger if params with {:severity => [0,1]}' do
      MLogger.search_by_params({:severity => [0,1]}).map(&:id).sort.should == (@criticals + @errors).map(&:id).sort
    end
  end
end
