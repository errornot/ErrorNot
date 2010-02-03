class Project
  include MongoMapper::Document

  key :name, String, :required => true

  has_many :error_reports, :class_name => 'Error'

  has_many :members

  validate :need_members
  validate :need_admin_members

  def add_admin_member(user)
    members.build(:user => user, :admin => true)
  end

  def include_member?(user)
    members.any?{|member| member.user_id == user.id}
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
end
