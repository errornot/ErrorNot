require File.dirname(__FILE__) + '/../spec_helper'

describe Error do

  describe "Valication" do
    it 'should have valid factory' do
      Error.make_unsaved.should be_valid
    end

    it 'should not valid if no project associated' do
      Error.make_unsaved(:project => nil).should_not be_valid
    end

    it 'should not valid if no message' do
      Error.make_unsaved(:message => '').should_not be_valid
    end

    it 'should not valid if no raised_at' do
      Error.make_unsaved(:raised_at => nil).should_not be_valid
    end

  end

  describe 'default value' do
    it 'should have resolved false by default' do
      Error.new.resolved.should == false
    end

    [:session, :backtrace, :request, :environment, :data].each do |hash|
      it "should have empty hash in #{hash} by default" do
        Error.new.send(hash).should == {}
      end
    end
  end

end
