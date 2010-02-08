require File.dirname(__FILE__) + '/../spec_helper'

describe Member do

  ['notify_by_email', 'email'].each do |field|
    it "should have field #{field}" do
      assert Member.keys.keys.include?(field)
    end
  end


  describe 'validation' do
    it 'should not valid if no user_id and no email' do
      member = Member.new(:admin => true)
      project = Factory.build(:project, :members => [member])
      project.should_not be_valid
    end

    it 'should valid if member has email and not user_id' do
      member = Member.new(:email => 'foo@example.com', :admin => true)
      project = Factory.build(:project, :members => [member])
      project.should be_valid
    end
  end

  describe '#notify_by_email!' do
    it 'should made notify_by_email at true and save it if not notify_by_email' do
      user = make_user
      member = Member.new(:user => user, :notify_by_email => false, :admin => true)
      project = Factory(:project, :members => [member])
      project.reload.member(user).notify_by_email.should be_false
      project.member(user).notify_by_email!
      project.reload.member(user).notify_by_email.should be_true
    end

    it 'should keep notify_by_email at true if already notify_by_email' do
      user = make_user
      member = Member.new(:user => user, :notify_by_email => true, :admin => true)
      project = Factory(:project, :members => [member])
      project.reload.member(user).notify_by_email.should be_true
      project.member(user).notify_by_email!
      project.reload.member(user).notify_by_email.should be_true
    end
  end

  describe '#status' do
    it 'should be validates if member has user_id validate' do
      user = make_user
      member = Member.new(:user => user, :admin => true)
      project = Factory(:project, :members => [member])
      project.reload.member(user).status.should == I18n.t('member.status.validate')
    end
    it 'should be incomming if member has user_id unvalidate' do
      user = Factory(:user)
      member = Member.new(:user => user, :admin => true)
      project = Factory(:project, :members => [member])
      project.reload.member(user).status.should == I18n.t('member.status.unvalidate')
    end
    it 'should be awaiting if member has no user_id created' do
      Member.new(:email => 'yahoo@example.com').status.should == I18n.t('member.status.awaiting')
      member = Member.new(:email => 'yahoo@example.com', :admin => true)
      project = Factory(:project, :members => [member])
      project.reload.members.first.status.should == I18n.t('member.status.awaiting')
    end
  end
end
