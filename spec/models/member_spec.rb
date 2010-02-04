require File.dirname(__FILE__) + '/../spec_helper'

describe Member do

  ['notify_by_email'].each do |field|
    it "should have field #{field}" do
      assert Member.keys.keys.include?(field)
    end
  end


  describe 'validation' do
    it 'should not valid if no user_id' do
      member = Member.new(:admin => true)
      project = Factory.build(:project, :members => [member])
      project.should_not be_valid
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
end
