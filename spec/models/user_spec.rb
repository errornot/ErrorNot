require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  describe 'validation' do
    it 'should have a valid user by factory' do
      User.make_unsaved.should be_valid
    end
  end
end
