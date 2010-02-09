require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do

  ['user_id', 'user_email', 'text', 'created_at'].each do |field|
    it "should have field #{field}" do
      assert Comment.keys.keys.include?(field)
    end
  end


  describe 'validation' do
    it 'should not valid if no text' do
      error = Factory(:error)
      error.comments.build(:user => make_user, :text => '')
      error.should_not be_valid
    end
  end

  describe '#save' do
    it 'should fill user_email with email of user_id' do
      error = Factory(:error)
      user = make_user
      error.comments.build(:user => user, :text => 'foo')
      error.save!
      error.reload.comments.first.user_email.should == user.email
    end

    it 'should add created_at during creation' do
      error = Factory(:error)
      user = make_user
      error.comments.build(:user => user, :text => 'foo')
      error.save!
      error.comments.first.created_at.should_not be_nil
      create = error.comments.first.created_at
      error.comments.first.created_at = Time.now
      error.save!
      error.comments.first.created_at.should == create
    end
  end
end
