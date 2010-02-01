require File.dirname(__FILE__) + '/../spec_helper'

describe Project do
  describe 'Validation' do
    it 'should have valid factory' do
      Project.make_unsaved.should be_valid
    end
    it 'should not valid if no name' do
      Project.make_unsaved(:name => '').should_not be_valid
    end
  end
end
