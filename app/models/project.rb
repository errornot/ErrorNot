class Project
  include MongoMapper::Document

  key :name, String, :required => true

  key :nb_errors_reported, Integer, :default => 0
  key :nb_errors_resolved, Integer, :default => 0
  key :nb_errors_unresolved, Integer, :default => 0

  has_many :error_reports, :class_name => 'Error'

  has_many :members

  validate :need_members
  validate :need_admin_members

  include_errors_from :members

  ## CALLBACK
  before_save :update_members_data

  def add_admin_member(user)
    members.build(:user => user, :admin => true)
  end

  def member_include?(user)
    members.any?{|member| member.user_id == user.id}
  end

  def admin_member?(user)
    members.any?{|member| member.user_id == user.id && member.admin? }
  end

  def remove_member!(user)
    members.delete_if{|member| member.user_id.to_s == user.id.to_s && !member.admin? }
    save!
  end

  def update_nb_errors
    self.nb_errors_reported = error_reports.count
    self.nb_errors_unresolved = error_reports.count(:resolved => false)
    self.nb_errors_resolved = error_reports.count(:resolved => true)
    self.save!
  end

  ##
  # Add member to this project by emails.
  #
  # If user already exist with this email. Add it.
  # instead send an email to create his account
  #
  # @params[String] list of emails separate by comma
  # @return true if works
  def add_member_by_email(emails)
    emails.split(',').each do |email|
      user = User.first(:email => email.strip)
      if user
        members.build(:user => user,
                      :admin => false)
      else
        members.build(:email => email.strip,
                      :admin => false)
        UserMailer.deliver_project_invitation(email.strip, self)
      end
    end
    save!
  end

  def member(user)
    members.detect{|member| member.user_id == user.id }
  end

  class << self
    def access_by(user)
      Project.all('members.user_id' => user.id)
    end
  end

  private

  def need_members
    errors.add(:members, 'need_member') if members.empty?
  end

  def need_admin_members
    errors.add(:members, 'need_admin_member') unless members.any?{ |m| m.admin }
  end

  def update_members_data
    members.each do |member|
      member.update_data
    end
  end
end
