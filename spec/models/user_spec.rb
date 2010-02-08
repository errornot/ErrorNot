require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  describe 'validation' do
    it 'should have a valid user by factory' do
      Factory.build(:user).should be_valid
    end
  end

  describe '#member_project' do
    it 'should render [] if user not member of project' do
      assert_equal [], Factory(:user).member_projects
    end

    it 'should render list of project where user is member' do
      user = Factory(:user)
      project = make_project_with_admin(user)
      assert_equal [project], user.reload.member_projects
      project_2 = make_project_with_admin(user)
      assert_equal [project, project_2].sort_by(&:id), user.reload.member_projects.sort_by(&:id)
    end
  end

end
