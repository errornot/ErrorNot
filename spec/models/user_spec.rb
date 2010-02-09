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

  describe '#update' do
    it 'should not update his email' do
      user = make_user
      user.email = 'change@example.com'
      user.should_not be_valid
    end
    it 'should add some alias email un validate in first'
    it 'should send an email with token to all email add to be alias'
    it 'should validate his email by token send to this email'
    it 'should not update an email alias'
    it 'should delete an email alias'
    it 'should after deleting an email alias mark all member like DELETED'
  end

  describe '#save' do
    it 'should check if his email need to be associated to other project' do
      project = make_project_with_admin(make_user)
      project.add_member_by_email('foo@example.com')
      user = Factory(:user, :email => 'foo@example.com')
      project.reload.member(user).status.should == Member::UNVALIDATE
      user.confirmed_at = Time.now
      user.save!
      project.reload.member(user).status.should == Member::VALIDATE
    end
  end

end
