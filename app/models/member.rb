class Member
  include MongoMapper::EmbeddedDocument

  key :admin, Boolean

  key :user_id, ObjectId
  belongs_to :user

end
