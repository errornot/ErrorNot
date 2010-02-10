class UserMailer < ActionMailer::Base

  def project_invitation(email, project)
    recipients email
    subject "[#{APP_NAME}] invitation on project #{project.name}"
    body :email => email, :project => project
  end

  def error_notify(email, error)
    recipients email
    subject "[#{error.project.name}] #{error.message}"
    body :error => error
  end


end
