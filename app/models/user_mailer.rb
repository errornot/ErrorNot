class UserMailer < ActionMailer::Base

  def project_invitation(email, project)
    @email = email
    @project = project
    mail(
      :to => email, 
      :subject => "[#{APP_NAME}] invitation on project #{project.name}",
    )
  end

  def project_removal(removed_email, remover_email, project)
    @project = project
    @remover_email = remover_email
    mail(
      :to => removed_email, 
      :subject => "[#{project.name}] Good bye",
    )
  end

  def error_notify(email, error)
    @error = error
    mail(
      :to => email, 
      :subject => "[#{error.project.name}] #{error.message}",
    )
  end

  def error_digest_notify(email, errors)
    @errors = errors
    mail(
      :to => email, 
      :subject => "[DIGEST] [#{errors.first.project.name}] error report #{I18n.l(Time.now)}",
    )
  end

end
