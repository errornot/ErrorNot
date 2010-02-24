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

  describe '#update_notify' do

    before do
      @user = make_user
      @project = make_project_with_admin(@user)
      @project_2 = make_project_with_admin(@user)
      member = @project_2.member(@user)
      member.notify_by_email = false
      member.notify_removal_by_email = false
      member.notify_by_digest = false
      member.save
    end

    it 'should update notify by email' do
      @user.update_notify(:email => [@project_2.id.to_s])
      member = @project_2.reload.member(@user)
      member.notify_by_email.should be_true
      member.notify_by_digest.should be_false
      member.notify_removal_by_email.should be_false
    end
    it 'should update notify by digest' do
      @user.update_notify(:digest => [@project_2.id.to_s])
      member = @project_2.reload.member(@user)
      member.notify_by_email.should be_false
      member.notify_by_digest.should be_true
      member.notify_removal_by_email.should be_false
    end
    it 'should update notify by removal' do
      @user.update_notify(:removal => [@project_2.id.to_s])
      member = @project_2.reload.member(@user)
      member.notify_by_email.should be_false
      member.notify_by_digest.should be_false
      member.notify_removal_by_email.should be_true
    end

    it 'should set all members of the user to be notified by email on error and removal' do
      @user.update_notify(:email => [@project.id, @project_2.id].map(&:to_s),
                           :removal => [@project.id, @project_2.id].map(&:to_s))
      @project.reload.member(@user).notify_by_email.should be_true
      @project_2.reload.member(@user).notify_by_email.should be_true
      @project.reload.member(@user).notify_removal_by_email.should be_true
      @project_2.reload.member(@user).notify_removal_by_email.should be_true
    end

    it 'should set all members of the user to be notified on error (and respectively removal) on given project ids (list 1 and respectively list 2)' do
      @user.update_notify(:email => [@project_2.id.to_s],
                          :removal => [@project.id.to_s])
      @project.reload.member(@user).notify_by_email.should be_false
      @project_2.reload.member(@user).notify_by_email.should be_true
      @project.reload.member(@user).notify_removal_by_email.should be_true
      @project_2.reload.member(@user).notify_removal_by_email.should be_false
    end

    it 'should made all project with no notify if args is an empty array' do
      @user.update_notify(:email => [],
                                       :removal => [])
      @project.reload.member(@user).notify_by_email.should be_false
      @project_2.reload.member(@user).notify_by_email.should be_false
      @project.reload.member(@user).notify_removal_by_email.should be_false
      @project_2.reload.member(@user).notify_removal_by_email.should be_false
    end
  end

end
