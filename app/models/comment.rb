class Comment

  include MongoMapper::EmbeddedDocument

  key :user_id, ObjectId
  key :text, String, :required => true
  # generate data
  key :user_email, String
  key :created_at, Time

  belongs_to :user

  def update_informations
    self.user_email = self.user.email
    self.created_at ||= Time.now
  end


end
