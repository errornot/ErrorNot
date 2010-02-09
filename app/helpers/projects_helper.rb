module ProjectsHelper
  def member_status(member_status)
    case member_status
    when Member::AWAITING
      I18n.t('member.status.awaiting')
    when Member::UNVALIDATE
      I18n.t('member.status.unvalidate')
    when Member::VALIDATE
      I18n.t('member.status.validate')
    end
  end
end
