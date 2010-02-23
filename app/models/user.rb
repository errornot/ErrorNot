class User

  include MongoMapper::Document

  ## Include default devise modules.
  ## Others available are :lockable, :timeoutable and :activatable.
  devise :authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  after_save :check_member_project
  validate :not_change_email


  def member_projects
    Project.all('members.user_id' => self.id)
  end

  ##
  # For all the user's projects:
  #   
  #  - if the project id is in the first given array,
  #    then mark the member as noticeable by email on new errors;
  #
  #  - if the project id is in the second given array,
  #    the mark the member as noticable if removed from project.
  #
  # @params[Array] a list of project id. All project_id need to be in String
  # @params[Array] idem.
  def notify_by_email_on_project(project_ids=[], project_ids2=[])
    member_projects.each do |project|
      member = project.member(self)
      if project_ids.include?(project.id.to_s)
        member.notify_by_email = true
      else
        member.notify_by_email = false
      end
      if project_ids2.include?(project.id.to_s)
        member.notify_removal_by_email = true
      else
        member.notify_removal_by_email = false
      end
      member.save
    end
  end

  ##
  # Search all project where user is member by his email.
  #
  # In each project, update user_id if member is not validate
  # or has no user_id
  #
  def check_member_project
    Project.all('members.email' => self.email).each do |project|
      member = project.members.detect{ |member| member.email == self.email }
      if member.user_id.blank? || member.status != Member::VALIDATE
        # We need save member if member not validate
        # it's member who check if user is or not validate
        member.user_id = self.id
        member.save
      end
    end
  end

  def not_change_email
    if email_changed? && !email_was.blank?
      errors.add(:email, 'user.validation.email.not_change')
    end
  end

end
