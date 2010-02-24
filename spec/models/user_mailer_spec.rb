require File.dirname(__FILE__) + '/../spec_helper'

describe UserMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include ActionController::UrlWriter

  describe '#project_invitation' do
    before do
      @project = Factory(:project)
      @email  = UserMailer.create_project_invitation('yahoo@yahoo.org', @project)
    end

    it 'should deliver to email send in params' do
      @email.should deliver_to('yahoo@yahoo.org')
    end

    it 'should have a subject with project name' do
      @email.should have_subject(/invitation on project #{@project.name}/)
    end

    it 'should have link to create account with email in params' do
      @email.should have_text(/#{new_user_url(:host => 'localhost:3000', :email => 'yahoo@yahoo.org').gsub('?', '\?')}/)
    end
  end

  describe '#project_removal' do
    before do
      @project = Factory(:project)
      @email = UserMailer.create_project_removal('removed@toto.com', 'remover@toto.com', @project)
    end
    it 'should deliver to removed guy' do
      @email.should deliver_to('removed@toto.com')
    end
    it 'should have subject with project name' do
      @email.should have_subject(/[#{@project.name}]/)
    end
    it 'should contain the address of the remover' do
      @email.should have_text(/remover@toto.com/)
    end
  end

  describe '#error_notify' do
    before do
      @project = make_project_with_admin(make_user)
      @error = Factory(:error, :project => @project)
      @email  = UserMailer.create_error_notify('yahoo@yahoo.org', @error)
    end

    it 'should deliver email send in params' do
      @email.should deliver_to('yahoo@yahoo.org')
    end
    it 'should have subject with project name' do
      @email.should have_subject(/\[#{@project.name}\] #{@error.message}/)
    end
    it 'should have link to error in body' do
      @email.should have_text(/#{project_error_url(@project, @error, :host => 'localhost:3000').gsub('?', '\?')}/)
    end
  end

  describe '#error_digest_notify' do
    before do
      @project = make_project_with_admin(make_user)
      @errors = 2.of{ Factory(:error, :project => @project) }
      @email  = UserMailer.create_error_digest_notify('yahoo@yahoo.org', @errors)
    end

    it 'should deliver email send in params' do
      @email.should deliver_to('yahoo@yahoo.org')
    end
    it 'should have subject with project name' do
      @email.should have_subject(/\[DIGEST\] \[#{@project.name}\] error report/)
    end
    it 'should have link to error in body' do
      @email.should have_text(/#{project_error_url(@project, @errors.first, :host => 'localhost:3000').gsub('?', '\?')}/)
    end

  end
end
