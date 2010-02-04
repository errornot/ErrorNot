class Member
  include MongoMapper::EmbeddedDocument

  key :admin, Boolean

  key :user_id, ObjectId, :required => true
  belongs_to :user

end
