require File.dirname(__FILE__) + '/../spec_helper'

describe MLogger do

  describe "Valication" do
    it 'should have valid factory' do
      MLogger.make
    end
  end
end
