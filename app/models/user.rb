class User

  include MongoMapper::Document

  ## Include default devise modules.
  ## Others available are :lockable, :timeoutable and :activatable.
  plugin MongoMapper::Devise
  devise :authenticatable, :database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  after_save :check_member_project
  validate :not_change_email


  def member_projects
    Project.all('members.user_id' => self.id)
  end

  ##
  # Change all notification of this user to all project
  # where he is member
  #
  # You can has notify :
  #  - :email => one email by error
  #  - :digest => one digest by time
  #  - :removal => one email when he is deleted
  #
  # @params[Hash] key are type of nofication, and value is a Array of
  # all project_id where notification is OK
  #
  def update_notify(notify={})
    member_projects.each do |project|
      member = project.member(self)
      member.notify_by_email =  (notify[:email]||[]).include?(project.id.to_s)
      member.notify_removal_by_email = (notify[:removal] || []).include?(project.id.to_s)
      member.notify_by_digest = (notify[:digest] || []).include?(project.id.to_s)
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
