class Member
  include MongoMapper::EmbeddedDocument

  key :admin, Boolean
  key :notify_by_email, Boolean, :default => true

  key :user_id, ObjectId, :required => true
  belongs_to :user

  def notify_by_email!
    self.notify_by_email = true
    self.save
  end

end
