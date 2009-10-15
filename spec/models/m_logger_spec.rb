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
end
