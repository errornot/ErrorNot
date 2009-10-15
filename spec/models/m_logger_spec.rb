require File.dirname(__FILE__) + '/../spec_helper'

describe MLogger do

  describe "Valication" do
    it 'should have valid factory' do
      MLogger.make_unsaved.should be_valid
    end

    it 'should not valid if no application name' do
      MLogger.make_unsaved(:application => '').should_not be_valid
    end
  end
end
