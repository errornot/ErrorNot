require File.dirname(__FILE__) + '/../spec_helper'

describe Project do

  describe 'Field' do
    ['nb_errors_reported', 'nb_errors_resolved', 'nb_errors_unresolved'].each do |field|
      it "should have field #{field}" do
        assert Project.keys.keys.include?(field)
      end
    end
  end

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

    it 'should have a api_key in creation' do
      project = Factory.build(:project)
      project.api_key.should be_blank
      project.save
      project.api_key.should_not be_blank
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

  describe '#make_user_admin!(user)' do
     before do
      @users = [make_user, make_user, Factory(:user)] # two validated users, one not validated
      @project = saved_project_with_admins_and_users([@users[0]], [@users[1], @users[2]])
      @members = @users.map{|u| @project.member u}
    end
    it 'should make a validated non admin member as admin' do
      lambda do
        assert_equal @project.make_user_admin!(@users[1]), true
      end.should change(@members[1], :admin)
    end
    it 'should not make a non validated member as admin' do
      lambda do
        assert_equal @project.make_user_admin!(@users[2]), false
      end.should_not change(@members[2], :admin?)
    end
    it 'should not change an already admin user' do
      lambda do
        assert_equal @project.make_user_admin!(@users[0]), true
      end.should_not change(@members[0], :admin?)
    end
  end

  describe '#unmake_user_admin!(user)' do
   before do
      @user = make_user
      @project = saved_project_with_admins_and_users([@user])
      @member = @project.member @user
    end
    describe 'with only one user as admin' do
      it 'should not remove admin rights of the only admin' do
        @member.should be_admin
        assert_equal @project.unmake_user_admin!(@user), false
        @project.reload.member(@user).should be_admin
      end
    end
    describe 'with two users as admin' do
      before do
        @project = saved_project_with_admins_and_users([@user, make_user])
        @member = @project.member @user
      end
      it 'should success if more than one admin in the project' do
        lambda do
          assert_equal @project.unmake_user_admin!(@user), true
        end.should change(@member, :admin?)
      end
    end
  end

  describe '#member_include?(user)' do
    it 'should be true is user is member of project' do
      assert !Factory(:project).member_include?(Factory(:user))
    end
    it 'should not be truc is user is not member of project' do
      user = Factory(:user)
      assert make_project_with_admin(user).member_include?(user)
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

  describe '#nb_errors_reported' do
    it 'should save nb of all errors save in this project' do
      project = Factory(:project)
      assert_equal 0, project.nb_errors_reported
      3.times { |nb|
        Factory(:error, :project => project)
        assert_equal (nb + 1), project.reload.nb_errors_reported
      }
    end
  end

  describe '#nb_errors_resolved' do
    it 'should save nb of all errors resolved save in this project' do
      project = Factory(:project)
      assert_equal 0, project.nb_errors_resolved
      errors = []
      3.times { |nb|
        errors << Factory(:error, :project => project)
        assert_equal 0, project.reload.nb_errors_resolved
      }
      errors.each_with_index do |error, index|
        error.resolved!
        assert_equal (index + 1), project.reload.nb_errors_resolved
      end
    end
  end

  describe '#nb_errors_unresolved' do
    it 'should save nb of all errors resolved save in this project' do
      project = Factory(:project)
      assert_equal 0, project.reload.nb_errors_unresolved
      errors = []
      3.times { |nb|
        errors << Factory(:error, :project => project)
        assert_equal (nb + 1), project.reload.nb_errors_unresolved
      }
      errors.each_with_index do |error, index|
        error.resolved!
        assert_equal (3 - (index + 1)) , project.reload.nb_errors_unresolved
      end
    end
  end

  describe '#member(user)' do
    it 'return nil if user is not member of this project' do
      user = Factory(:user)
      Factory(:project).member(user).should == nil
    end
    it 'return the member object where user is in this project' do
      user = Factory(:user)
      project = make_project_with_admin(user)
      member = project.members.first
      project.members.build(:user => Factory(:user))
      project.save!
      project.reload.member(user).should == member
    end
  end

  describe '#admin_member?(user)' do
    before do
      @user = Factory(:user)
    end

    it 'return true if user is member and admin of this project' do
      project = make_project_with_admin(@user)
      project.admin_member?(@user).should be_true
    end

    it 'return false if user is member but not admin of this project' do
      project = Factory(:project)
      project.members.build(:user => @user, :admin => false)
      project.save!
      project.admin_member?(@user).should be_false
    end

    it 'should return false if user is not member of this project' do
      Factory(:project).admin_member?(@user).should be_false
    end
  end


  describe '#add_member_by_email(emails)' do
    before do
      @user_1 = make_user(:email => 'foo@example.com')
      @user_2 = make_user(:email => 'bar@example.com')
      @user_3 = make_user(:email => 'baz@example.com')
      @project = Factory(:project)
    end

    it 'should add member if only one emails send and email is on a user' do
      UserMailer.expects(:project_invitation).never
      @project.add_member_by_email(' foo@example.com ')
      @project.reload
      @project.member_include?(@user_1).should be_true
      @project.member_include?(@user_2).should be_false
      @project.member_include?(@user_3).should be_false
    end
    it 'should add member if all emails separate by comma send and email is on users' do
      UserMailer.expects(:project_invitation).never
      @project.add_member_by_email(' foo@example.com , bar@example.com ')
      @project.reload
      @project.member_include?(@user_1).should be_true
      @project.member_include?(@user_2).should be_true
      @project.member_include?(@user_3).should be_false
    end

    it 'should send an email to email which no in register' do
      UserMailer.expects(:project_invitation).with("yahoo@yahoo.org", @project).returns UserMailer
      UserMailer.expects(:deliver)
      @project.add_member_by_email(' foo@example.com, yahoo@yahoo.org ')
      @project.reload
      @project.member_include?(@user_1).should be_true
      @project.member_include?(@user_2).should be_false
      @project.member_include?(@user_3).should be_false
    end

    it "should create member object with only email data in member's project" do
      UserMailer.expects(:project_invitation).with('yahoo@yahoo.org', @project).returns UserMailer
      UserMailer.expects(:deliver)
      lambda do
        @project.add_member_by_email('yahoo@yahoo.org')
      end.should change(@project.members, :size)
      @project.reload.members.last.admin.should == false
      @project.reload.members.last.email.should == 'yahoo@yahoo.org'
      @project.reload.members.last.user_id.should == nil
    end
  end

  describe '#remove_member!' do
    [:user, :email].each{ |by|
      it 'should delete member if not admin' do
        project = Factory(:project)
        user = make_user
        project.members.build(:user => user, :admin => false)
        project.save!
        lambda do
          project.remove_member!(:user => user).should == true if by == :user
          project.remove_member!(:email => user.email).should == true if by == :email
          project.member(user).should be_nil
        end.should change(project.reload.members, :size).by(-1)
      end

      it 'should delete member even if admin (and there is at least one other admin)' do
        user = make_user
        project = saved_project_with_admins_and_users([user, make_user])
        lambda do
          project.remove_member!(:user => user).should == true if by == :user
          project.remove_member!(:email => user.email).should == true if by == :email
          project.member(user).should be_nil
        end.should change(project.reload.members, :size).by(-1)
      end

      it 'should not delete member if admin (and no other admin)' do
        user = make_user
        project = saved_project_with_admins_and_users([user], [make_user, make_user])
        project.member(user).should_not be_nil
        lambda do
          project.remove_member!(:user => user).should == false if by == :user
          project.remove_member!(:email => user.email).should == false if by == :email
          project.reload
          project.member(user).should_not be_nil
        end.should_not change(project.reload.members, :size).by(-1)
      end
    }
  end

  describe '#error_with_message_and_backtrace' do
    it 'should render new error if no error with same message and backtrace' do
      error = Factory.build(:error)
      project = make_project_with_admin(make_user)
      new_error = project.error_with_message_and_backtrace(error.message,
                                                            error.backtrace)
      new_error.should be_kind_of(Error)
      new_error.project_id.should == project.id
    end

    it 'should render new embedded error on same error if error who want create has same message and backtrace' do
      project = make_project_with_admin(make_user)
      error = Factory(:error, :project => project)
      error_2 = Factory.build(:error, :message => error.message,
                              :backtrace => error.backtrace,
                              :project => project)
      new_error = project.error_with_message_and_backtrace(error_2.message,
                                                            error_2.backtrace)
      new_error.should be_kind_of(ErrorEmbedded)
      new_error.root_error.should == error
    end
  end

  describe '#gen_api_key' do
    project = make_project_with_admin(make_user)
    it 'should set/change the api key' do
      lambda do
        project.gen_api_key
      end.should change(project, :api_key)
    end
    it 'should not save the object' do
      lambda do
        project.save
        project.gen_api_key
        project.reload
      end.should_not change(project, :api_key)
    end
  end

  describe '#gen_api_key!' do
    it 'should change the api key and save the project' do
      project = make_project_with_admin(make_user)
      lambda do
        project.gen_api_key!
        project.reload
      end.should change(project, :api_key)
    end
  end

  describe "#paginate_errors_with_search" do
    before do
      @project = make_project_with_admin
    end
    it 'should extract all search params' do
      @project.error_reports.expects(:paginate).with(:conditions => {:_keywords => {'$in' => ['xx', 'yy']}},
                                                    :page => 1,
                                                    :per_page => 10,
                                                    :sort => [['last_raised_at', -1]])
      @project.paginate_errors_with_search(:search => 'xx yy')
    end

    it "should change :resolved = 'y' by :resolved => true" do
      @project.error_reports.expects(:paginate).with(:conditions => {:resolved => true},
                                                    :page => 1,
                                                    :per_page => 10,
                                                    :sort => [['last_raised_at', -1]])
      @project.paginate_errors_with_search(:resolved => 'y')
    end

    it "should change :resolved = 'y' by :resolved => true and extract search params" do
      @project.error_reports.expects(:paginate).with(:conditions => {:resolved => true, :_keywords => { '$in' => ['xx', 'yy']}},
                                                    :page => 1,
                                                    :per_page => 10,
                                                    :sort => [['last_raised_at', -1]])
      @project.paginate_errors_with_search(:resolved => 'y', :search => 'xx yy')
    end

    it 'should push page and per_page with search and resolved params' do
      @project.error_reports.expects(:paginate).with(:conditions => {:resolved => true, :_keywords => { '$in' => ['xx', 'yy']}},
                                                    :page => 3,
                                                    :per_page => 20,
                                                    :sort => [['last_raised_at', -1]])
      @project.paginate_errors_with_search(:resolved => 'y', :search => 'xx yy', :page => 3, :per_page => 20)
    end

    it "should extract all sorting params" do
      @project.error_reports.expects(:paginate).with(:conditions => {},
                                                     :page => 1,
                                                     :per_page => 10,
                                                     :sort => [['count', 1], ['last_raised_at', -1]])
      @project.paginate_errors_with_search(:sort_by => 'count', :asc_order => 1)
    end

    ['last_raised_at', 'nb_comments', 'count'].each{ |sorting_by|
      it "should accept #{sorting_by} as sorting parameter" do
        @project.error_reports.expects(:paginate)
        @project.paginate_errors_with_search(:sort_by => sorting_by)
      end
    }

    it 'should ignore bad sorting parameters' do
      @project.error_reports.expects(:paginate).with(:conditions => {},
                                                     :page => 1,
                                                     :per_page => 10,
                                                     :sort => [['last_raised_at', -1]])
      @project.paginate_errors_with_search(:sort_by => :other_param)
    end
  end

  describe '#error_reports.not_send_by_digest' do
    it 'should limit only to error not send by digest alread' do
      project = make_project_with_admin
      2.of { Factory(:error, :unresolved_at => 4.minutes.ago.utc,
                     :project => project) }
      2.of { Factory(:error, :unresolved_at => 2.minutes.ago.utc,
                     :resolved => true,
                     :project => project) }
      error_not_send = 2.of { Factory(:error, :unresolved_at => 2.minutes.ago.utc, :project => project).reload }
      project.reload
      project.error_reports.not_send_by_digest_since(3.minutes.ago.utc).should == error_not_send.sort_by(&:last_raised_at)
    end
  end

  describe 'Project#with_digest_request' do
    it 'should return nil if no member with digest request'
    it 'should return Project with a leat one member with digest request'
  end

end
