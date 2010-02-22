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

  def change_power(member)
    confirm = nil
    if member.user.id == current_user.id
      confirm =  "You are are going to loose your admin rights! Confirm?"
    end
    if member.admin?
       link_to 'Admin', admins_project_url(@project, :user_id=>member.user.id), :method => :delete, 
         :confirm => confirm, :title => "Remove admin rights"
    else
      link_to 'Not Admin', admins_project_url(@project, :user_id=>member.user.id), :method => :put,
        :title => "Make admin"
    end
  end
end
