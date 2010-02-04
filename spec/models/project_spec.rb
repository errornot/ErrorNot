require File.dirname(__FILE__) + '/../spec_helper'

describe Project do
  describe 'Validation' do
    it 'should have valid factory' do
      Factory.build(:project).should be_valid
    end
    it 'should not valid if no name' do
      Factory.build(:project, :name => '').should_not be_valid
    end

    it 'should not valid if no member associate' do
      Factory.build(:project, :members => []).should_not be_valid
    end

    it 'should not valid if no admin member associate' do
      project = Factory.build(:project, :members => [])
      project.members << Member.new( :user => Factory(:user), :admin => false )
      project.should_not be_valid
    end
  end

  describe '#add_admin_member(user)' do
    before do
      @project = Factory(:project)
      @user = Factory(:user)
    end
    it 'should add a member define like admin' do
      lambda do
        @project.add_admin_member(@user)
      end.should change(@project.members, :count)
      @project.members.detect{|m| m.user_id == @user.id }.should be_admin
    end
  end

  describe '#include_member?(user)' do
    it 'should be true is user is member of project' do
      assert !Factory(:project).include_member?(Factory(:user))
    end
    it 'should not be truc is user is not member of project' do
      user = Factory(:user)
      assert make_project_with_admin(user).include_member?(user)
    end
  end

  describe 'self#access_by' do
    it 'should see limit only to project with user is member' do
      user = Factory(:user)
      project = make_project_with_admin(user)
      Factory(:project)
      assert_equal [project], Project.access_by(user)
    end
  end
end
