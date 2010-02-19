require File.dirname(__FILE__) + '/../spec_helper'

describe Error do

  describe "Validation" do
    it 'should have valid factory' do
      Factory.build(:error).should be_valid
    end

    it 'should not valid if no project associated' do
      Factory.build(:error, :project => nil).should_not be_valid
    end

    it 'should not valid if no message' do
      Factory.build(:error, :message => '').should_not be_valid
    end

    it 'should not valid if no raised_at' do
      Factory.build(:error, :raised_at => nil).should_not be_valid
    end

  end

  describe 'default value' do
    it 'should have resolved false by default' do
      Error.new.resolved.should == false
    end

    [:session, :request, :environment, :data].each do |hash|
      it "should have empty hash in #{hash} by default" do
        Error.new.send(hash).should == {}
      end
    end

    [:backtrace].each do |array|
      it "should have empty array in #{array} by default" do
        Error.new.send(array).should == []
      end
    end

    it 'should have count to 0' do
      Error.new.count.should == 1
    end

    it 'should have nb_comments to 0' do
      Error.new.nb_comments == 0
    end
  end

  describe '#url' do
    it 'should render url in request' do
      er = Error.new
      assert_equal er.request['url'], er.url
    end
  end

  describe '#params' do
    it 'should render params in request' do
      er = Error.new
      assert_equal er.request['params'], er.params
    end
  end


  describe '#resolved!' do
    it 'should save and mark error like resolved if unresolved' do
      error = Factory(:error, :resolved => false)
      error.resolved!
      assert Error.find(error.id).resolved
    end
    it 'should made nothing if error already resolved' do
      error = Factory(:error, :resolved => true)
      error.resolved!
      assert Error.find(error.id).resolved
    end

    it 'should not send email if mark like resolved!' do
      user = make_user
      project = make_project_with_admin(user)
      error = Factory(:error, :resolved => true,
                     :project => project)
      UserMailer.expects(:deliver_error_notify).with{ |email, error|
        email == user.email && error.kind_of?(Error)
      }.never
      error.resolved!
      assert Error.find(error.id).resolved
    end

    it 'should not send email if error mark like unresolved' do
      user = make_user
      project = make_project_with_admin(user)
      error = Factory(:error, :resolved => true,
                     :project => project)
      error.resolved!
      UserMailer.expects(:deliver_error_notify).with{ |email, error|
        email == user.email && error.kind_of?(Error)
      }.never
      error.resolved = false
      error.save!
      assert !Error.find(error.id).resolved
    end
  end

  describe '#create' do
    it 'should send email to all member with notify_by_email is true' do
      user = make_user
      project = make_project_with_admin(user)
      UserMailer.expects(:deliver_error_notify).with{ |email, error|
        email == user.email && error.kind_of?(Error)
      }
      Factory(:error, :project => project)
    end

    it 'should send only one email to member because only one want email notify' do
      user = make_user
      project = make_project_with_admin(user)
      project.members.build(:user => make_user, :notify_by_email => false)
      project.save!
      UserMailer.expects(:deliver_error_notify).with{ |email, error|
        email == user.email && error.kind_of?(Error)
      }
      Factory(:error, :project => project)
    end
  end

  describe '#last_raised_at' do
    it 'should return raised_at of error if no error_embedded' do
      error = Factory(:error)
      error.last_raised_at.should == error.raised_at
    end
    it 'should return last raised_at of error_embedded if error has error_embedded' do
      error = Factory(:error, :raised_at => 3.days.ago)
      error.same_errors.build(:raised_at => 2.days.ago)
      last_raised = error.same_errors.build(:raised_at => 1.day.ago).raised_at
      error.last_raised_at.should == last_raised
    end
  end

  describe 'keywords generation' do
    it 'should fill in the keywords correctly' do
      project = Factory(:project)
      user = project.members.first.user
      error = Factory(:error,
                      :project => project,
                      :message => "one, two: three (four, five) - six",
                      :comments => [ Comment.new(:user => user, :text => "seven, height, one: two three"),
                        Comment.new(:user => user, :text => "five; nine")])

      error._keywords.sort.should ==  ['one', 'two', 'three', 'four', 'five', 'six', 'seven', 'height', 'nine'].sort
    end
  end

end
