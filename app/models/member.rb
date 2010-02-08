class Member
  include MongoMapper::EmbeddedDocument

  key :admin, Boolean
  key :notify_by_email, Boolean, :default => true
  key :email, String

  key :user_id, ObjectId
  belongs_to :user

  validates_presence_of :user_id, :if => Proc.new { email.blank? }

  def notify_by_email!
    self.notify_by_email = true
    self.save
  end

end
