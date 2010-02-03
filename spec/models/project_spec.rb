require File.dirname(__FILE__) + '/../spec_helper'

describe Project do
  describe 'Validation' do
    it 'should have valid factory' do
      Project.make_unsaved.should be_valid
    end
    it 'should not valid if no name' do
      Project.make_unsaved(:name => '').should_not be_valid
    end

    it 'should not valid if no member associate' do
      Project.make_unsaved(:members => []).should_not be_valid
    end

    it 'should not valid if no admin member associate' do
      project = Project.make_unsaved(:members => [])
      project.members << Member.new( :user => User.make, :admin => false )
      project.should_not be_valid
    end
  end

  describe '#add_admin_member(user)' do
    before do
      @project = Project.make
      @user = User.make
    end
    it 'should add a member define like admin' do
      lambda do
        @project.add_admin_member(@user)
      end.should change(@project.members, :count)
      @project.members.detect{|m| m.user_id == @user.id }.should be_admin
    end
  end
end
