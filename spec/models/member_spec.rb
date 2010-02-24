require File.dirname(__FILE__) + '/../spec_helper'

describe Member do

  ['digest_send_at', 'notify_by_digest', 'notify_by_email', 'email'].each do |field|
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

  describe 'digest_send_at' do

    it 'should be nil if notify_by_digest nil' do
      make_member(:notify_by_digest => false).digest_send_at.should == nil
    end

    it 'should be define in Time.now if notify_by_digest define' do
      member = make_member(:notify_by_digest => false)
      member.notify_by_digest = true
      member.save
      member.digest_send_at.should be_close(Time.now.utc, 1.seconds)
    end

    it 'should be nil if notify_by_define become false' do
      member = make_member(:notify_by_digest => true)
      member.digest_send_at.should be_close(Time.now.utc, 1.seconds)
      member.notify_by_digest = false
      member.save
      member.digest_send_at.should be_nil
    end

    it 'should not change if already notify_by_digest' do
      member = make_member(:notify_by_digest => true)
      digest_time = member.digest_send_at
      member.notify_by_digest = true
      member.save
      member.digest_send_at.should == digest_time
    end
  end

  describe '#status' do
    it 'should be validates if member has user_id validate' do
      user = make_user
      member = Member.new(:user => user, :admin => true)
      project = Factory(:project, :members => [member])
      project.reload.member(user).status.should == Member::VALIDATE
    end
    it 'should be incomming if member has user_id unvalidate' do
      user = Factory(:user)
      member = Member.new(:user => user, :admin => true)
      project = Factory(:project, :members => [member])
      project.reload.member(user).status.should == Member::UNVALIDATE
    end
    it 'should be awaiting if member has no user_id created' do
      Member.new(:email => 'yahoo@example.com').status.should == Member::AWAITING
      member = Member.new(:email => 'yahoo@example.com', :admin => true)
      project = Factory(:project, :members => [member])
      project.reload.members.first.status.should == Member::AWAITING
    end
    it 'should be deleted if member has delete his alias'
    it 'should be unvalidate if an user add this email in alias but not validate it'
    it 'should be validate if an user add this email in alias and validate it'
  end

  describe '#send_digest' do
    it 'should made nothing if notify_by_digest false' do
      member = make_member(:notify_by_digest => false)
      member.send_digest.should be_false
    end

    it 'should send one email to user with notify_by_digest is true' do
      member = make_member(:notify_by_digest => true,
                           :digest_send_at => 1.minute.ago.utc)
      errors_not_digest_send = 2.of { Factory(:error,
                                              :project => member._root_document).reload }
      2.of { Factory(:error,
                     :unresolved_at => 2.minutes.ago.utc,
                     :project => member._root_document) }
      UserMailer.expects(:deliver_error_digest_notify).with(member.email,
                                                            errors_not_digest_send.sort_by(&:last_raised_at))
      member.send_digest.should be_true
      Project.find(member._root_document.id).member(member.user).digest_send_at.should be_close(Time.now.utc, 1.seconds)
    end

    it 'should not send email if all error already send before' do
      member = make_member(:notify_by_digest => true,
                           :digest_send_at => 1.minute.ago.utc)
      2.of { Factory(:error,
                     :unresolved_at => 2.minutes.ago.utc,
                     :project => member._root_document) }
      UserMailer.expects(:deliver_error_digest_notify).never
      member.send_digest.should be_true
      Project.find(member._root_document.id).member(member.user).digest_send_at.should be_close(Time.now.utc, 1.seconds)
    end
  end
end
