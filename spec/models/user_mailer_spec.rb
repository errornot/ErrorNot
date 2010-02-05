require File.dirname(__FILE__) + '/../spec_helper'

describe UserMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include ActionController::UrlWriter

  describe 'project_invitation' do
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
end
