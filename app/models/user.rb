class User

  include MongoMapper::Document

  ## Include default devise modules.
  ## Others available are :lockable, :timeoutable and :activatable.
  devise :authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable


  def member_projects
    Project.all('members.user_id' => self.id)
  end

  ##
  # made all project with id send by array mark
  # like can be notify by email.
  #
  # @params[Array] a list of project id . All project_id need to be in String
  def notify_by_email_on_project(project_ids=[])
    member_projects.each do |project|
      if project_ids.include?(project.id.to_s)
        project.member(self).notify_by_email!
      else
        member = project.member(self)
        member.notify_by_email = false
        member.save
      end
    end
  end

end
