class UserMailer < ActionMailer::Base

  def project_invitation(email, project)
    recipients email
    subject "[#{APP_NAME}] invitation on project #{project.name}"
    body :email => email, :project => project
  end

  def project_removal(removed_email, remover_email, project)
    recipients removed_email
    subject "[#{project.name}] Good bye"
    body :project => project, :remover_email => remover_email
  end

  def error_notify(email, error)
    recipients email
    subject "[#{error.project.name}] #{error.message}"
    body :error => error
  end

  def error_digest_notify(email, errors)
    recipients email
    subject "[DIGEST] [#{errors.first.project.name}] error report #{I18n.l(Time.now)}"
    body :errors => errors
  end


end
