require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do

  ['user_id', 'user_email', 'text', 'created_at'].each do |field|
    it "should have field #{field}" do
      assert Comment.keys.keys.include?(field)
    end
  end

  def make_comment_with_text(text)
    @user = make_user
    @project = make_project_with_admin(@user)
    @error = Factory(:error, :project => @project)
    @error.comments.build(:user => @user, :text => text)
  end


  describe 'validation' do
    it 'should not valid if no text' do
      make_comment_with_text('')
      @error.should_not be_valid
    end

    it 'should not valid if user is not member of error in root' do
      error = Factory(:error)
      error.comments.build(:user => make_user, :text => 'hello')
      error.should_not be_valid
    end
  end

  describe '#save' do
    it 'should fill user_email with email of user_id' do
      make_comment_with_text('foo')
      @error.save!
      @error.reload.comments.first.user_email.should == @user.email
    end

    it 'should add created_at during creation' do
      make_comment_with_text('foo')
      @error.save!
      @error.comments.first.created_at.should_not be_nil
      create = @error.comments.first.created_at
      @error.comments.first.created_at = Time.now
      @error.save!
      @error.comments.first.created_at.should == create
    end
  end
end
