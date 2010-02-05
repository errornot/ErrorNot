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

  describe '#notify_by_email_on_project(project_ids)' do
    before do
      @user = make_user
      @project = make_project_with_admin(@user)
      @project_2 = make_project_with_admin(@user)
      member = @project_2.member(@user)
      member.notify_by_email = false
      member.save
    end
    it 'should puts member of this user in all project with id notify by email' do
      @user.notify_by_email_on_project([@project.id, @project_2.id].map(&:to_s))
      @project.reload.member(@user).notify_by_email.should be_true
      @project_2.reload.member(@user).notify_by_email.should be_true
    end

    it 'should define member of all project with user but not in params with not a notify_b y_email' do
      @user.notify_by_email_on_project([@project_2.id.to_s])
      @project.reload.member(@user).notify_by_email.should be_false
      @project_2.reload.member(@user).notify_by_email.should be_true
    end

    it 'should made all project with no notify if args is an empty array' do
      @user.notify_by_email_on_project([])
      @project.reload.member(@user).notify_by_email.should be_false
      @project_2.reload.member(@user).notify_by_email.should be_false
    end
  end

end
