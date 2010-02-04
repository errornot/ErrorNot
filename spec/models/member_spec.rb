require File.dirname(__FILE__) + '/../spec_helper'

describe Member do
  describe 'validation' do
    it 'should not valid if no user_id' do
      member = Member.new(:admin => true)
      project = Factory.build(:project, :members => [member])
      project.should_not be_valid
    end
  end
end
